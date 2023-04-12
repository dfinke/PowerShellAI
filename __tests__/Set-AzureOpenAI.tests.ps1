Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe 'Set-AzureOpenAI' -Tag SetAzureOpenAI {

    BeforeEach {
        $savedAzureOpenAIKey = $env:AzureOpenAIKey
    }

    AfterEach {
        $env:AzureOpenAIKey = $savedAzureOpenAIKey
    }

    It 'Test if Set-AzureOpenAI function exists' {
        $actual = Get-Command Set-AzureOpenAI -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Set-AzureOpenAI has these parameters' {
        $actual = Get-Command Set-AzureOpenAI -ErrorAction SilentlyContinue
        
        $keys = $actual.Parameters.keys

        $keys.Contains("Endpoint") | Should -BeTrue
        $keys.Contains("DeploymentName") | Should -BeTrue
        $keys.Contains("ApiVersion") | Should -BeTrue
        $keys.Contains("ApiKey") | Should -BeTrue
    }

    It 'Test if Set-AzureOpenAI parameter attributes' {
        $actual = Get-Command Set-AzureOpenAI | Select-Object -ExpandProperty Parameters

        $actual.Endpoint.Attributes.Mandatory | Should -BeTrue
        $actual.DeploymentName.Attributes.Mandatory | Should -BeTrue
        $actual.ApiVersion.Attributes.Mandatory | Should -BeTrue
        $actual.ApiKey.Attributes.Mandatory | Should -BeTrue
    }

    It 'Test passing in data to Set-AzureOpenAI' {
        Set-AzureOpenAI `
            -Endpoint https://myopenaiinstance.openai.azure.com `
            -DeploymentName myopenaiinstance `
            -ApiVersion 2023-03-15-preview `
            -ApiKey aayyzzbbcc

        $actual = Get-AzureOpenAIOptions

        $actual.Endpoint | Should -Be "https://myopenaiinstance.openai.azure.com"
        $actual.DeploymentName | Should -Be "myopenaiinstance"
        $actual.ApiVersion | Should -Be "2023-03-15-preview"

        Test-AzureOpenAIKey | Should -BeTrue
        Get-ChatAPIProvider | Should -Be "AzureOpenAI"
        
        $env:AzureOpenAIKey | Should -BeExactly "aayyzzbbcc"
    }
}