Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe "Invoke-RestMethodWithProgress" -Tag InvokeRestMethodWithProgress {

    InModuleScope 'PowerShellAI' {

        $script:StartJobCommand = Get-Command "Start-Job"

        BeforeEach {
            Reset-APIEstimatedResponseTimes
            Push-Location -StackName "MOCK-IRMWP" -Path $PSScriptRoot
            New-PSDrive -Name "MOCK-IRMWP" -PSProvider "FileSystem" -Root $PSScriptRoot
        }

        AfterEach {
            Pop-Location -StackName "MOCK-IRMWP" -ErrorAction "SilentlyContinue"
            Remove-PSDrive -Name "MOCK-IRMWP" -ErrorAction "SilentlyContinue"
        }

        It "should return the known response if the API call is successful" {
            
            Mock Start-Job {
                return & $script:StartJobCommand { }
            }
            
            Mock Receive-Job {
                return @{
                    Response = "a happy web response from a web server"
                }
            }

            $params = @{
                "Method" = "GET";
                "Uri" = "http://localhost";
            }
            
            $response = Invoke-RestMethodWithProgress -Params $params
            $response | Should -BeExactly "a happy web response from a web server"
        }

        It "should work when run from a psdrive" {

            Mock Start-Job {
                return & $script:StartJobCommand { }
            }
            
            Mock Receive-Job {
                return @{
                    Response = "a happy web response from a web server"
                }
            }

            $params = @{
                "Method" = "GET";
                "Uri" = "http://localhost";
            }

            Set-Location "MOCK-IRMWP:\"
            
            $response = Invoke-RestMethodWithProgress -Params $params
            $response | Should -BeExactly "a happy web response from a web server"
        }

        It "should work when run from a non-filesystem provider" {
            
            Mock Invoke-RestMethod {
                return "a happy web response from a web server"
            }

            Mock Start-Job { }

            $params = @{
                "Method" = "GET";
                "Uri" = "http://localhost";
            }

            Push-Location -StackName "MOCK-IRMWP"
            Set-Location "Env:\"
            
            $response = Invoke-RestMethodWithProgress -Params $params
            $response | Should -BeExactly "a happy web response from a web server"
            Should -Invoke -CommandName Invoke-RestMethod -Times 1
            Should -Invoke -CommandName Start-Job -Times 0
        }

        It "should throw if the API call fails" {
            
            $params = @{
                "Method" = "GET"
                "Uri" = "yeet://the.yeet.scheme.is.not.supported"
            }

            Mock Start-Job {
                return & $script:StartJobCommand {
                    Invoke-RestMethod $using:params.Uri
                }
            }

            $errorRecord = { Invoke-RestMethodWithProgress -Params $params } | Should -Throw -PassThru
            $errorRecord.Exception.Message | Should -BeLike "*'yeet' scheme is not supported*"
        }

        It "should not use a background job in unsupported hosts" {
            Mock Get-Host {
                return @{
                    Name = "UnitTestHost"
                }
            }

            Mock Invoke-RestMethod {
                return "a happy web response from a web server"
            }

            Mock Start-Job { }

            $params = @{
                "Method" = "GET";
                "Uri" = "http://localhost";
            }
            
            $response = Invoke-RestMethodWithProgress -Params $params
            $response | Should -BeExactly "a happy web response from a web server"

            Should -Invoke -CommandName Invoke-RestMethod -Times 1
            Should -Invoke -CommandName Start-Job -Times 0
        }
        
        It "should not use a background job if a proxy is configured by env var" {
            Mock Get-Host {
                return @{
                    Name = "ConsoleHost"
                }
            }

            Mock Invoke-RestMethod {
                return "a happy web response from a web server"
            }

            Mock Start-Job { }

            $params = @{
                "Method" = "GET";
                "Uri" = "http://localhost";
            }
            
            $previousProxySettings = $env:HTTP_PROXY
            $env:HTTP_PROXY = "http://example.com:3128"
            $response = Invoke-RestMethodWithProgress -Params $params
            $env:HTTP_PROXY = $previousProxySettings
            
            $response | Should -BeExactly "a happy web response from a web server"

            Should -Invoke -CommandName Invoke-RestMethod -Times 1
            Should -Invoke -CommandName Start-Job -Times 0
        }

        It "should not use a background job if a defaultproxy is configured for the current session" {
            Mock Get-Host {
                return @{
                    Name = "ConsoleHost"
                }
            }

            Mock Invoke-RestMethod {
                return "a happy web response from a web server"
            }

            Mock Start-Job { }

            $params = @{
                "Method" = "GET";
                "Uri" = "http://localhost";
            }
            
            $previousProxySettings = [System.Net.WebRequest]::DefaultWebProxy
            $proxyUri = New-Object System.Uri("http://example.com:3128")
            $proxy = New-Object System.Net.WebProxy($proxyUri)
            [System.Net.WebRequest]::DefaultWebProxy = $proxy
            $response = Invoke-RestMethodWithProgress -Params $params
            [System.Net.WebRequest]::DefaultWebProxy = $previousProxySettings
            
            $response | Should -BeExactly "a happy web response from a web server"

            Should -Invoke -CommandName Invoke-RestMethod -Times 1
            Should -Invoke -CommandName Start-Job -Times 0
        }

        Describe "Get-APIEstimatedResponseTime Tests" {
            It "should return default response time when there's no record for a specific endpoint" {
                $responseTime = Get-APIEstimatedResponseTime -Method "POST" -Uri "http://localhost/new-endpoint"
                $responseTime | Should -Be 10
            }
        }
        
        Describe "Set-APIResponseTime Tests" {
            It "should record response time for a specific endpoint" {
                Set-APIResponseTime -Method "PUT" -Uri "http://localhost/new-endpoint" -ResponseTimeSeconds 30
                $responseTime = Get-APIEstimatedResponseTime -Method "PUT" -Uri "http://localhost/new-endpoint"
                $responseTime | Should -Be 30
            }
        }
    }
}