Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe "ChatSessionOptions" -Tag ChatSessionOptions {

    AfterEach {
        Reset-ChatSessionOptions
        Reset-AzureOpenAIOptions
        Set-ChatAPIProvider -Provider 'OpenAI'
    }
    
    It "Test Get-ChatSessionOptions function exists" {
        $actual = Get-Command Get-ChatSessionOptions -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Tests default Get-ChatSessionOptions' {
        $actual = Get-ChatSessionOptions
        
        $actual | Should -Not -BeNullOrEmpty

        $actual.model | Should -BeExactly 'gpt-4'
        $actual.temperature | Should -Be 0.0
        $actual.max_tokens | Should -Be 256
        $actual.top_p | Should -Be 1.0
        $actual.frequency_penalty | Should -Be 0
        $actual.presence_penalty | Should -Be 0
        $actual.stop | Should -BeNullOrEmpty
    }

    It 'Test Set-ChatSessionOption' {
        $actual = Get-Command Set-ChatSessionOption -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Set-ChatSessionOption model' {
        Set-ChatSessionOption -model 'gpt-4'
        $actual = Get-ChatSessionOptions
        
        $actual | Should -Not -BeNullOrEmpty

        $actual.model | Should -BeExactly 'gpt-4'
        $actual.temperature | Should -Be 0.0
        $actual.max_tokens | Should -Be 256
        $actual.top_p | Should -Be 1.0
        $actual.frequency_penalty | Should -Be 0
        $actual.presence_penalty | Should -Be 0
        $actual.stop | Should -BeNullOrEmpty
    }

    It 'Test Set-ChatsessionOption max_tokens' {
        Set-ChatSessionOption -max_tokens 512
        $actual = Get-ChatSessionOptions
        
        $actual | Should -Not -BeNullOrEmpty

        $actual.model | Should -BeExactly 'gpt-4'
        $actual.temperature | Should -Be 0.0
        $actual.max_tokens | Should -Be 512
        $actual.top_p | Should -Be 1.0
        $actual.frequency_penalty | Should -Be 0
        $actual.presence_penalty | Should -Be 0
        $actual.stop | Should -BeNullOrEmpty
    }

    It 'Test Set-ChatSessionOption temperature' {
        Set-ChatSessionOption -temperature 0.5
        $actual = Get-ChatSessionOptions
        
        $actual | Should -Not -BeNullOrEmpty

        $actual.model | Should -BeExactly 'gpt-4'
        $actual.temperature | Should -Be 0.5
        $actual.max_tokens | Should -Be 256
        $actual.top_p | Should -Be 1.0
        $actual.frequency_penalty | Should -Be 0
        $actual.presence_penalty | Should -Be 0
        $actual.stop | Should -BeNullOrEmpty
    }

    It 'Test set-ChatSessionOption top_p' {
        Set-ChatSessionOption -top_p 0.5
        $actual = Get-ChatSessionOptions
        
        $actual | Should -Not -BeNullOrEmpty

        $actual.model | Should -BeExactly 'gpt-4'
        $actual.temperature | Should -Be 0.0
        $actual.max_tokens | Should -Be 256
        $actual.top_p | Should -Be 0.5
        $actual.frequency_penalty | Should -Be 0
        $actual.presence_penalty | Should -Be 0
        $actual.stop | Should -BeNullOrEmpty
    }

    It 'Test Set-ChatSessionOption frequency_penalty' {
        Set-ChatSessionOption -frequency_penalty 0.5
        $actual = Get-ChatSessionOptions
        
        $actual | Should -Not -BeNullOrEmpty

        $actual.model | Should -BeExactly 'gpt-4'
        $actual.temperature | Should -Be 0.0
        $actual.max_tokens | Should -Be 256
        $actual.top_p | Should -Be 1.0
        $actual.frequency_penalty | Should -Be 0.5
        $actual.presence_penalty | Should -Be 0
        $actual.stop | Should -BeNullOrEmpty
    }

    It 'Test Set-ChatSessionOption presence_penalty' {
        Set-ChatSessionOption -presence_penalty 0.5
        $actual = Get-ChatSessionOptions
        
        $actual | Should -Not -BeNullOrEmpty

        $actual.model | Should -BeExactly 'gpt-4'
        $actual.temperature | Should -Be 0.0
        $actual.max_tokens | Should -Be 256
        $actual.top_p | Should -Be 1.0
        $actual.frequency_penalty | Should -Be 0
        $actual.presence_penalty | Should -Be 0.5
        $actual.stop | Should -BeNullOrEmpty
    }

    It 'Test Set-ChatSessionOption stop' {
        Set-ChatSessionOption -stop '!'
        $actual = Get-ChatSessionOptions
        
        $actual | Should -Not -BeNullOrEmpty

        $actual.model | Should -BeExactly 'gpt-4'
        $actual.temperature | Should -Be 0.0
        $actual.max_tokens | Should -Be 256
        $actual.top_p | Should -Be 1.0
        $actual.frequency_penalty | Should -Be 0
        $actual.presence_penalty | Should -Be 0
        $actual.stop | Should -BeExactly '!'
    }

    It 'Test Reset-ChatSessionOptions function exists' {
        $actual = Get-Command Reset-ChatSessionOptions -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Reset-ChatSessionOptions' {
        Reset-ChatSessionOptions
        $actual = Get-ChatSessionOptions
        
        $actual | Should -Not -BeNullOrEmpty

        $actual.model | Should -BeExactly 'gpt-4'
        $actual.temperature | Should -Be 0.0
        $actual.max_tokens | Should -Be 256
        $actual.top_p | Should -Be 1.0
        $actual.frequency_penalty | Should -Be 0
        $actual.presence_penalty | Should -Be 0
        $actual.stop | Should -BeNullOrEmpty
    }

    It 'Test Get-AzureOpenAIOptions function exists' {
        $actual = Get-Command Get-AzureOpenAIOptions -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Get-AzureOpenAIOptions' {
        $actual = Get-AzureOpenAIOptions
        
        $actual | Should -Not -BeNullOrEmpty
        $actual.Endpoint | Should -BeExactly 'not set'
        $actual.DeploymentName | Should -BeExactly 'not set'
        $actual.ApiVersion | Should -BeExactly 'not set'
    }

    It 'Test Get-ChatAzureOpenAIURI function exists' {
        $actual = Get-Command Get-ChatAzureOpenAIURI -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Set-AzureOpenAIOptions function exists' {
        $actual = Get-Command Set-AzureOpenAIOptions -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Set-AzureOpenAIOptions' {
        Set-AzureOpenAIOptions -Endpoint 'https://westus.api.cognitive.microsoft.com' -DeploymentName 'openai' -ApiVersion '2021-05-01'
        $actual = Get-AzureOpenAIOptions
        
        $actual | Should -Not -BeNullOrEmpty
        $actual.Endpoint | Should -BeExactly 'https://westus.api.cognitive.microsoft.com'
        $actual.DeploymentName | Should -BeExactly 'openai'
        $actual.ApiVersion | Should -BeExactly '2021-05-01'
    }

    It 'Test Get-ChatAzureOpenAIURI' {
        Set-AzureOpenAIOptions -Endpoint 'https://westus.api.cognitive.microsoft.com' -DeploymentName 'openai' -ApiVersion '2021-05-01'

        $actual = Get-ChatAzureOpenAIURI
        
        $actual | Should -Not -BeNullOrEmpty

        $actual | Should -BeExactly 'https://westus.api.cognitive.microsoft.com/openai/deployments/openai/chat/completions?api-version=2021-05-01'
    }

    It 'Test Reset-AzureOpenAIOptions function exists' {
        $actual = Get-Command Reset-AzureOpenAIOptions -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Reset-AzureOpenAIOptions' {
        Set-AzureOpenAIOptions -Endpoint 'https://westus.api.cognitive.microsoft.com' -DeploymentName 'openai' -ApiVersion '2021-05-01'

        $actual = Get-AzureOpenAIOptions

        $actual | Should -Not -BeNullOrEmpty
        $actual.Endpoint | Should -BeExactly 'https://westus.api.cognitive.microsoft.com'
        $actual.DeploymentName | Should -BeExactly 'openai'
        $actual.ApiVersion | Should -BeExactly '2021-05-01'

        Reset-AzureOpenAIOptions

        $actual = Get-AzureOpenAIOptions

        $actual | Should -Not -BeNullOrEmpty
        $actual.Endpoint | Should -BeExactly 'not set'
        $actual.DeploymentName | Should -BeExactly 'not set'
        $actual.ApiVersion | Should -BeExactly 'not set'        
    }

    It 'Test Get-ChatAzureOpenAIURI throws if Endpoint is not set' {
        Set-AzureOpenAIOptions -DeploymentName 'openai' -ApiVersion '2021-05-01'

        {Get-ChatAzureOpenAIURI} | Should -Throw -ExpectedMessage 'Azure Open AI Endpoint not set'
    }

    It 'Test Get-ChatAzureOpenAIURI throws if DeploymentName is not set' {
        Set-AzureOpenAIOptions -Endpoint 'https://westus.api.cognitive.microsoft.com' -ApiVersion '2021-05-01'

        {Get-ChatAzureOpenAIURI} | Should -Throw -ExpectedMessage 'Azure Open AI DeploymentName not set'
    }

    It 'Test Get-ChatAzureOpenAIURI throws if ApiVersion is not set' {
        Set-AzureOpenAIOptions -Endpoint 'https://westus.api.cognitive.microsoft.com' -DeploymentName 'openai'

        {Get-ChatAzureOpenAIURI} | Should -Throw -ExpectedMessage 'Azure Open AI ApiVersion not set'
    }

    It 'Test Set-ChatAPIProvider function exists' {
        $actual = Get-Command Set-ChatAPIProvider -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Get-ChatAPIProvider function exists' {
        $actual = Get-Command Get-ChatAPIProvider -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Get-ChatAPIProvider returns OpenAI by default' {
        $actual = Get-ChatAPIProvider
        
        $actual | Should -Not -BeNullOrEmpty
        $actual | Should -BeExactly 'OpenAI'
    }

    It 'Test Set-ChatAPIProvider to AzureOpenAI' {
        Set-ChatAPIProvider -Provider AzureOpenAI
        $actual = Get-ChatAPIProvider
        
        $actual | Should -Not -BeNullOrEmpty
        $actual | Should -BeExactly 'AzureOpenAI'
    }

    It 'Test Set-ChatAPIProvider to OpenAI' {
        Set-ChatAPIProvider -Provider OpenAI
        $actual = Get-ChatAPIProvider
        
        $actual | Should -Not -BeNullOrEmpty
        $actual | Should -BeExactly 'OpenAI'
    }
}