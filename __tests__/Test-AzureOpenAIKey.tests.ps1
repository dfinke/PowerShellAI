Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe "AzureOpenAIKey" -Tag AzureOpenAIKey {
    BeforeAll {
        $script:savedKey = $env:AzureOpenAIKey
        $env:AzureOpenAIKey = 'a7duejdnekhdl'

        Mock Invoke-RestMethod -ModuleName PowerShellAI -ParameterFilter { 
            $Method -eq 'Post' -and $Uri -eq (Get-OpenAIChatCompletionUri) 
        } -MockWith {
            [PSCustomObject]@{
                choices = @(
                    [PSCustomObject]@{
                        message = [PSCustomObject]@{
                            content = 'Mocked Get-GPT4Completion call'
                        }
                    }
                )
            }
        } 
    }

    BeforeEach {
        Stop-Chat
        Clear-ChatMessages
        Get-ChatSessionPath | Get-ChildItem -ErrorAction SilentlyContinue | Remove-Item -Force
    }

    AfterAll {
        $env:AzureOpenAIKey = $savedKey
    }

    It 'Test Test-AzureOpenAIKey function exists' {
        $actual = Get-Command Test-AzureOpenAIKey -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Test-AzureOpenAIKey returns true if AzureOpenAIKey is set' {
        $actual = Test-AzureOpenAIKey
        $actual | Should -BeTrue
    }
}