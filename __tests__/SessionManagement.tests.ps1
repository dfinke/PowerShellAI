Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe "Session Management" -Tag SessionManagement {
    BeforeAll {
        function Test-ChatSessionTimeStamp {
            param(
                [Parameter(Mandatory)]
                [string]$expected
            )

            ($expected.Length -eq 14) -and ($expected -match "^[0-9]+$")
        }
    }

    BeforeEach {
        # Set-ChatSessionPath "TestDrive:\PowerShell\ChatGPT"
    }

    AfterEach {
        Reset-ChatSessionPath
        Clear-ChatMessages
        # Get-ChatSessionPath | Remove-Item -Recurse -force
    }

    AfterAll {
        Clear-ChatMessages
    }

    It 'Test Get-ChatSessionTimeStamp function exists' {
        $actual = Get-Command Get-ChatSessionTimeStamp -ErrorAction SilentlyContinue

        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Reset-ChatSessionTimeStamp function exists' {
        $actual = Get-Command Reset-ChatSessionTimeStamp -ErrorAction SilentlyContinue

        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Get-ChatSessionPath function exists' {
        $actual = Get-Command Get-ChatSessionPath -ErrorAction SilentlyContinue

        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Set-ChatSessionPath function exists' {
        $actual = Get-Command Set-ChatSessionPath -ErrorAction SilentlyContinue

        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Get-ChatSessionFile function exists' {
        $actual = Get-Command Get-ChatSessionFile -ErrorAction SilentlyContinue

        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Export-ChatSession function exists' {
        $actual = Get-Command Export-ChatSession -ErrorAction SilentlyContinue

        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Reset-ChatSessionPath function exists' {
        $actual = Get-Command Reset-ChatSessionPath -ErrorAction SilentlyContinue

        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Get-ChatSessionContent function exists' {
        $actual = Get-Command Get-ChatSessionContent -ErrorAction SilentlyContinue

        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Get-ChatSessionTimeStamp returns a string in the correct format' {
        $actual = Get-ChatSessionTimeStamp

        Test-ChatSessionTimeStamp $actual | Should -BeTrue
    }

    It 'Test Reset-ChatSessionTimeStamp resets the session timestamp' {
        $expected = Get-ChatSessionTimeStamp
        Reset-ChatSessionTimeStamp

        # need to wait a second to ensure the timestamp is different
        Start-Sleep 1
        $actual = Get-ChatSessionTimeStamp

        $actual | Should -Not -Be $expected
    }

    It 'Test Get-ChatSessionPath returns correct path for Windows' {
        $actual = Get-ChatSessionPath

        if ($PSVersionTable.PSVersion.Major -lt 6 -or $IsWindows) {
            $actual | Should -BeExactly "$env:APPDATA\PowerShellAI\ChatGPT"
        }
    }

    # It 'Test Get-ChatSessionPath returns correct path for Linux' -Skip {
    #     $actual = Get-ChatSessionPath
    #     $actual | Should -Be ($env:HOME + "~/PowerShellAI/ChatGPT")
    # }

    It 'Test Get-ChatSessionFile returns correct file name for Linux' {

        if ($PSVersionTable.PSVersion.Major -gt 5 -and ($IsLinux -or $IsMacOS)) {
            # skip
            return
        }

        Reset-ChatSessionTimeStamp
        $timeStamp = Get-ChatSessionTimeStamp

        $actual = Get-ChatSessionFile

        $expected = "$(Get-ChatSessionPath)\$($timeStamp)-ChatGPTSession.xml"

        $actual | Should -BeExactly $expected
    }

    It 'Test exporting chat messages' {
        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'system'
                content = 'system test'
            })

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'user'
                content = 'user test'
            })

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'assistant'
                content = 'assistant test'
            })

        Set-chatSessionPath -Path 'TestDrive:\PowerShell\ChatGPT'

        Export-ChatSession

        $totalChats = @(Get-ChatSession)

        $totalChats.Count | Should -Be 1
    }

    It 'Test Get-ChatSession function exists' {
        $actual = Get-Command Get-ChatSession -ErrorAction SilentlyContinue

        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test setting and resetting the chat session path' {

        if ($PSVersionTable.PSVersion.Major -gt 5 -and ($IsLinux -or $IsMacOS)) {
            # skip
            return
        }

        $expected = 'TestDrive:\PowerShell\ChatGPT'
        Set-ChatSessionPath -Path $expected

        $actual = Get-ChatSessionPath
        $actual | Should -BeExactly $expected

        Reset-ChatSessionPath

        $actual = Get-ChatSessionPath

        if ($PSVersionTable.PSVersion.Major -lt 6 -or $IsWindows) {
            $actual | Should -BeExactly "$env:APPDATA\PowerShellAI\ChatGPT"
        }
    }

    It 'Test Get-ChatSessionContent returns correct content' {

        Set-ChatSessionPath "TestDrive:\PowerShell\ChatGPT"

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'system'
                content = 'system test'
            })

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'user'
                content = 'user test'
            })

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'assistant'
                content = 'assistant test'
            })

        Export-ChatSession

        $sessions = @(Get-ChatSession)
        $sessions.Count | Should -Be 1

        $content = @(Get-ChatSessionContent $sessions.FullName)

        $content | Should -Not -BeNullOrEmpty
        $content.Count | Should -Be 3

        $content[0].role | Should -BeExactly 'system'
        $content[0].content | Should -BeExactly 'system test'

        $content[1].role | Should -BeExactly 'user'
        $content[1].content | Should -BeExactly 'user test'

        $content[2].role | Should -BeExactly 'assistant'
        $content[2].content | Should -BeExactly 'assistant test'
    }

    It 'Test Get-ChatSessionContent returns correct content with multiple sessions' {
        Set-ChatSessionPath "TestDrive:\PowerShell\ChatGPT"
        Get-ChatSessionPath | Get-ChildItem | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'system'
                content = 'system test'
            })

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'user'
                content = 'user test'
            })

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'assistant'
                content = 'assistant test'
            })

        Export-ChatSession

        Stop-Chat
        Reset-ChatSessionTimeStamp
        Start-Sleep 1

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'system'
                content = 'system test 2'
            })

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'user'
                content = 'user test 2'
            })

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'assistant'
                content = 'assistant test 2'
            })

        Export-ChatSession

        Stop-Chat
        Reset-ChatSessionTimeStamp

        $sessions = @(Get-ChatSession)
        $sessions = Get-ChatSession
        $sessions.Count | Should -Be 2

        $result = $sessions | Get-ChatSessionContent

        $result.Count | Should -Be 6

        $result[0].role | Should -BeExactly 'system'
        $result[0].content | Should -BeExactly 'system test'

        $result[1].role | Should -BeExactly 'user'
        $result[1].content | Should -BeExactly 'user test'

        $result[2].role | Should -BeExactly 'assistant'
        $result[2].content | Should -BeExactly 'assistant test'

        $result[3].role | Should -BeExactly 'system'
        $result[3].content | Should -BeExactly 'system test 2'

        $result[4].role | Should -BeExactly 'user'
        $result[4].content | Should -BeExactly 'user test 2'

        $result[5].role | Should -BeExactly 'assistant'
        $result[5].content | Should -BeExactly 'assistant test 2'
    }

    It 'Test Get-ChatSessionContent piping sessions to it' {
        Set-ChatSessionPath "TestDrive:\PowerShell\ChatGPT"
        Get-ChatSessionPath | Get-ChildItem | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'system'
                content = 'system test'
            })

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'user'
                content = 'user test'
            })

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'assistant'
                content = 'assistant test'
            })

        Export-ChatSession

        Stop-Chat
        Reset-ChatSessionTimeStamp
        Start-Sleep 1

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'system'
                content = 'system test 2'
            })

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'user'
                content = 'user test 2'
            })

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'assistant'
                content = 'assistant test 2'
            })

        Export-ChatSession

        Stop-Chat
        Reset-ChatSessionTimeStamp
        Start-Sleep 1

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'system'
                content = 'system test 3'
            })

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'user'
                content = 'user test 3'
            })

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'assistant'
                content = 'assistant test 3'
            })

        Export-ChatSession

        Stop-Chat
        Reset-ChatSessionTimeStamp

        $sessions = Get-ChatSession
        $sessions.Count | Should -Be 3

        $result = $sessions | Get-ChatSessionContent

        $result.Count | Should -Be 9

        $result[0].role | Should -BeExactly 'system'
        $result[0].content | Should -BeExactly 'system test'

        $result[1].role | Should -BeExactly 'user'
        $result[1].content | Should -BeExactly 'user test'

        $result[2].role | Should -BeExactly 'assistant'
        $result[2].content | Should -BeExactly 'assistant test'

        $result[3].role | Should -BeExactly 'system'
        $result[3].content | Should -BeExactly 'system test 2'

        $result[4].role | Should -BeExactly 'user'
        $result[4].content | Should -BeExactly 'user test 2'

        $result[5].role | Should -BeExactly 'assistant'
        $result[5].content | Should -BeExactly 'assistant test 2'

        $result[6].role | Should -BeExactly 'system'
        $result[6].content | Should -BeExactly 'system test 3'

        $result[7].role | Should -BeExactly 'user'
        $result[7].content | Should -BeExactly 'user test 3'

        $result[8].role | Should -BeExactly 'assistant'
        $result[8].content | Should -BeExactly 'assistant test 3'
    }
}