Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe "Chat Messages" -Tag ChatMessages {
    BeforeAll {
        $script:savedKey = $env:OpenAIKey
        $env:OpenAIKey = 'sk-1234567890'
    }

    AfterAll {
        $env:OpenAIKey = $savedKey
    }

    BeforeEach {
        Clear-ChatMessages
    }

    It 'Tests New-ChatUserMessage exists' {
        $actual = Get-Command New-ChatUserMessage -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Tests New-ChatSystemMessage exists' {
        $actual = Get-Command New-ChatSystemMessage -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Tests New-ChatAssistantMessage exists' {
        $actual = Get-Command New-ChatAssistantMessage -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Tests Get-ChatMessages exists' {
        $actual = Get-Command Get-ChatMessages -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Tests Clear-ChatMessages exists' {
        $actual = Get-Command Clear-ChatMessages -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Tests Get-ChatMessages is null as default' {
        $actual = Get-ChatMessages
        $actual | Should -BeNullOrEmpty
    }

    It 'Tests New-ChatMessage exists' {
        $actual = Get-Command New-ChatMessage -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Tests New-Chat exists' {
        $actual = Get-Command New-Chat -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Clear-ChatMessages clears messages' {
        New-ChatMessage -Role 'user' -Content "Hello"
        New-ChatUserMessage -Content "Hello message 2"

        $actual = Get-ChatMessages
        $actual.Count | Should -Be 2

        Clear-ChatMessages
        $actual = Get-ChatMessages
        @($actual).Count | Should -Be 0
    }

    It 'Tests Get-ChatMessages returns messages with proper cased keys' {
        New-ChatMessage -Role 'user' -Content "Hello"

        $actual = Get-ChatMessages

        $names = $actual[0].PSObject.Properties.Name

        $names[0] | Should -BeExactly "role"
        $names[1] | Should -BeExactly "content"
    }

    It 'Tests New-ChatMessage has these parameters' {
        $actual = Get-Command New-ChatMessage -ErrorAction SilentlyContinue

        $keys = $actual.Parameters.keys

        $keys.Contains("role") | Should -BeTrue
        $keys.Contains("content") | Should -BeTrue
    }

    It 'Tests New-ChatUserMessage has these parameters' {
        $actual = Get-Command New-ChatUserMessage -ErrorAction SilentlyContinue

        $keys = $actual.Parameters.keys

        $keys.Contains("content") | Should -BeTrue
    }

    It 'Tests New-ChatSystemMessage has these parameters' {
        $actual = Get-Command New-ChatSystemMessage -ErrorAction SilentlyContinue

        $keys = $actual.Parameters.keys

        $keys.Contains("content") | Should -BeTrue
    }

    It 'Tests adding a user message with New-ChatMessage' {

        New-ChatMessage -Role 'user' -Content "Hello"

        $actual = @(Get-ChatMessages)

        $actual.Count | Should -Be 1
        $actual[0].Role | Should -Be "user"
        $actual[0].Content | Should -Be "Hello"
    }

    It 'Tests adding a user message with New-ChatUserMessage' {
        Clear-ChatMessages
        New-ChatUserMessage -content "Hello"

        $actual = @(Get-ChatMessages)

        $actual.Count | Should -Be 1
        $actual[0].Role | Should -Be "user"
        $actual[0].Content | Should -Be "Hello"
    }

    It 'Tests state gets reset after New-Chat' {
        New-ChatUserMessage -content "Hello"
        @(Get-ChatMessages).Count | Should -Be 1

        New-Chat
        Get-ChatMessages | Should -BeNullOrEmpty
    }

    It 'Tests adding new chat system messages' {
        New-ChatSystemMessage -Content "Hello"
        New-ChatMessage -Role 'system' -Content "World"

        $actual = Get-ChatMessages

        $actual.Count | Should -Be 2

        $actual[0].Role | Should -Be "system"
        $actual[0].Content | Should -Be "Hello"

        $actual[1].Role | Should -Be "system"
        $actual[1].Content | Should -Be "World"
    }

    It 'Tests adding new chat assistant messages' {
        New-ChatAssistantMessage -Content "Hello"
        New-ChatMessage -Role 'assistant' -Content "World"

        $actual = Get-ChatMessages

        $actual.Count | Should -Be 2

        $actual[0].Role | Should -Be "assistant"
        $actual[0].Content | Should -Be "Hello"

        $actual[1].Role | Should -Be "assistant"
        $actual[1].Content | Should -Be "World"
    }

    It 'Tests New-Chat with a starting message' {
        New-Chat -Content "You are a powershell bot"

        $actual = @(Get-ChatMessages)

        $actual.Count | Should -Be 1
        $actual[0].Role | Should -BeExactly 'system'
        $actual[0].Content | Should -BeExactly 'You are a powershell bot'
    }

    It 'Tests creating a chat and sending a message' {
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

        New-Chat -Content "You are a powershell bot"
        $result = chat "Hello"

        $result | Should -BeExactly "Mocked Get-GPT4Completion call"

        $actual = Get-ChatMessages

        $actual.Count | Should -Be 3
        $actual[0].Role | Should -BeExactly 'system'
        $actual[0].Content | Should -BeExactly 'You are a powershell bot'

        $actual[1].Role | Should -BeExactly 'user'
        $actual[1].Content | Should -BeExactly 'Hello'

        $actual[2].Role | Should -BeExactly 'assistant'
        $actual[2].Content | Should -BeExactly 'Mocked Get-GPT4Completion call'
    }
}