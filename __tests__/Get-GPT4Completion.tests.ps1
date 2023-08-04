Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe "Get-GPT4Completion" -Tag GPT4Completion {

    BeforeAll {
        $script:savedKey = $env:OpenAIKey
        $env:OpenAIKey = 'sk-1234567890'
        Set-chatSessionPath -Path 'TestDrive:\PowerShell\ChatGPT'

        Mock Invoke-RestMethodWithProgress -ModuleName PowerShellAI -ParameterFilter { 
            $Params.Method -eq 'Post' -and $Params.Uri -eq (Get-OpenAIChatCompletionUri) 
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
        $env:OpenAIKey = $savedKey
        Stop-Chat
    }

    It 'Test if chat is in progress initially' {
        $actual = Test-ChatInProgress
        $actual | Should -BeFalse
    }

    It "Test Get-GPT4Completion function exists" {
        $actual = Get-Command Get-GPT4Completion -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Test-ChatInProgress function exists' {
        $actual = Get-Command Test-ChatInProgress -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Stop-Chat function exists' {
        $actual = Get-Command Stop-Chat -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    } 
    
    It "Test chat alias exists" {
        $actual = Get-Alias chat -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
        $actual.Definition | Should -Be Get-GPT4Completion
    }

    It 'Test Add-ChatMessage function exists' {
        $actual = Get-Command Add-ChatMessage -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test New-ChatMessageTemplate function exists' {
        $actual = Get-Command New-ChatMessageTemplate -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test if chat is in progress after message' {
        $null = Get-GPT4Completion 'test'

        $actual = Test-ChatInProgress
        $actual | Should -BeTrue
    }

    It 'Test if chat is in progress after New-Chat' {
        $null = New-Chat

        $actual = Test-ChatInProgress
        $actual | Should -BeTrue
    }

    It 'Test if chat is in progress after New-ChatMessage and then New-Chat' {
        $null = New-ChatMessage -Role user -Content 'test'

        $actual = Test-ChatInProgress
        $actual | Should -BeTrue

        New-Chat

        $actual = Test-ChatInProgress
        $actual | Should -BeTrue
    }

    It 'Test New-ChatMessageTemplate function exists' {
        $actual = Get-Command New-ChatMessageTemplate -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }
    
    It 'Test New-ChatMessageTemplate has these parameters' {
        $actual = Get-Command New-ChatMessageTemplate

        $keys = $actual.Parameters.keys

        $keys.Contains("Role") | Should -BeTrue
        $keys.Contains("Content") | Should -BeTrue
        $keys.Contains("Name") | Should -BeTrue
    }

    It 'Test New-ChatMessageTemplate Role paramater has this set' {
        $actual = Get-Command New-ChatMessageTemplate

        $validateSet = $actual.Parameters.Role.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }
        $validateSet | Should -Not -BeNullOrEmpty
        $validateSet.ValidValues.Count | Should -Be 4

        $validateSet.ValidValues[0] | Should -BeExactly 'user'
        $validateSet.ValidValues[1] | Should -BeExactly 'system'
        $validateSet.ValidValues[2] | Should -BeExactly 'assistant'
        $validateSet.ValidValues[3] | Should -BeExactly 'function'
    }

    It 'Test New-ChatMessageTemplate throws when role=function and name=null' {
        {New-ChatMessageTemplate -Role function} | Should -Throw "Name is required if role is function"
    }

    It 'Test New-ChatMessageTemplate role is function and name provided' {
        $actual = New-ChatMessageTemplate -Role function -Content 'It is hot!' -Name 'Get-Weather'

        $actual | Should -Not -BeNullOrEmpty
        $actual.role | Should -Be 'function'
        $actual.name | Should -BeExactly 'Get-Weather'
        $actual.content | Should -BeExactly 'It is hot!'
    }

    It 'Test if Add-ChatMessage has these parameters' {
        $actual = Get-Command Add-ChatMessage
        
        $keys = $actual.Parameters.keys
        $keys.Contains("Message") | Should -BeTrue
    }

    It "Tests Get-GPT4Completion has these parameters" {
        $actual = Get-Command Get-GPT4Completion -ErrorAction SilentlyContinue
        
        $keys = $actual.Parameters.keys

        $keys.Contains("Content") | Should -BeTrue
    }

    It 'Test Add-ChatMessage adds message' {

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

        Add-ChatMessage -Message ([PSCustomObject]@{
                role    = 'function'
                content = 'function test'
            })

        $actual = Get-ChatMessages
        $actual.Count | Should -Be 4

        $actual[0].role | Should -Be 'system'
        $actual[0].content | Should -Be 'system test'

        $actual[1].role | Should -Be 'user'
        $actual[1].content | Should -Be 'user test'

        $actual[2].role | Should -Be 'assistant'
        $actual[2].content | Should -Be 'assistant test'

        $actual[3].role | Should -Be 'function'
        $actual[3].content | Should -Be 'function test'
    }

    It 'Test New-ChatMessageTemplate creates and populates template' {
        $actual = New-ChatMessageTemplate -Role user -Content 'test'

        $actual.role | Should -Be 'user'
        $actual.content | Should -Be 'test'
    }

    It 'Test New-ChatMessageTemplate creates empty template' {
        $actual = New-ChatMessageTemplate

        $actual.role | Should -BeNullOrEmpty
        $actual.content | Should -BeNullOrEmpty
    }

    It 'Test if Stop-Chat stops chat and resets messages' {
        $null = New-Chat 'test'

        $actual = Test-ChatInProgress
        $actual | Should -BeTrue

        Stop-Chat

        $actual = Test-ChatInProgress
        $actual | Should -BeFalse

        (Get-ChatMessages).Count | Should -Be 0
    }

    It 'Test message is added via New-Chat' {
        $actual = New-Chat 'test system message'

        $actual | Should -BeExactly 'Mocked Get-GPT4Completion call'

        $messages = Get-ChatMessages
        $messages.Count | Should -Be 2

        $messages[0].role | Should -BeExactly 'system'
        $messages[0].content | Should -BeExactly 'test system message'

        $messages[1].role | Should -BeExactly 'assistant'
        $messages[1].content | Should -BeExactly 'Mocked Get-GPT4Completion call'
    }

    It 'Test message is added via chat' {
        $actual = Get-GPT4Completion 'test user message'

        $actual | Should -BeExactly 'Mocked Get-GPT4Completion call'

        $messages = Get-ChatMessages
        $messages.Count | Should -Be 2

        $messages[0].role | Should -BeExactly 'user'
        $messages[0].content | Should -BeExactly 'test user message'

        $messages[1].role | Should -BeExactly 'assistant'
        $messages[1].content | Should -BeExactly 'Mocked Get-GPT4Completion call'
    }

    It 'Test message is added via New-Chat and Test-ChatInProgress' {
        Test-ChatInProgress | Should -BeFalse

        $actual = New-Chat 'test system message'

        $actual | Should -BeExactly 'Mocked Get-GPT4Completion call'

        Test-ChatInProgress | Should -BeTrue

        Stop-Chat
        Test-ChatinProgress | Should -BeFalse
    }
    
    It 'Test message is added via chat and Test-ChatInProgress' {
        Test-ChatInProgress | Should -BeFalse

        $actual = Get-GPT4Completion 'test user message'

        $actual | Should -BeExactly 'Mocked Get-GPT4Completion call'

        Test-ChatInProgress | Should -BeTrue

        Stop-Chat
        Test-ChatinProgress | Should -BeFalse
    }

    It 'Test system message is added via New-Chat and Export works' {
        $actual = New-Chat 'test system message'

        $actual | Should -BeExactly 'Mocked Get-GPT4Completion call'

        $sessions = Get-ChatSession
        $sessions.Count | Should -Be 1

        $content = $sessions | Get-ChatSessionContent
        $content.Count | Should -Be 2

        $content[0].role | Should -BeExactly 'system'
        $content[0].content | Should -BeExactly 'test system message'

        $content[1].role | Should -BeExactly 'assistant'
        $content[1].content | Should -BeExactly 'Mocked Get-GPT4Completion call'
    }

    It 'Test user message is added via chat and Export works' {
        $actual = Get-GPT4Completion 'test user message'

        $actual | Should -BeExactly 'Mocked Get-GPT4Completion call'

        $sessions = Get-ChatSession
        $sessions.Count | Should -Be 1

        $content = $sessions | Get-ChatSessionContent
        $content.Count | Should -Be 2

        $content[0].role | Should -BeExactly 'user'
        $content[0].content | Should -BeExactly 'test user message'

        $content[1].role | Should -BeExactly 'assistant'
        $content[1].content | Should -BeExactly 'Mocked Get-GPT4Completion call'
    }

    It 'Test temperature is set calling chat' {        
        $actual = Get-GPT4Completion 'test user message' -temperature 1

        (Get-ChatSessionOptions)['temperature'] | Should -Be 1
        $actual | Should -BeExactly 'Mocked Get-GPT4Completion call'

        Reset-ChatSessionOptions
        
        (Get-ChatSessionOptions)['temperature'] | Should -Be 0.0
    }
}