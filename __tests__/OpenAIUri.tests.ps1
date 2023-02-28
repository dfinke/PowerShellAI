Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe "OpenAIUri" -Tag 'OpenAIUri' {
    InModuleScope 'PowerShellAI' {
        It "OpenAI URI is valid" {
            $Script:OpenAIBaseURI | Should -BeExactly 'https://api.openai.com/v1'
        }

        It "OpenAI Models URI is valid" {
            $Script:OpenAIModelsURI | Should -BeExactly 'https://api.openai.com/v1/models'
        }

        It "OpenAI Moderations URI is valid" {
            $Script:OpenAIModerationsURI | Should -BeExactly 'https://api.openai.com/v1/moderations'
        }

        It "OpenAI Completions URI is valid" {
            $Script:OpenAICompletionsURI | Should -BeExactly 'https://api.openai.com/v1/completions'
        }

        It "OpenAI Images Generations URI is valid" {
            $Script:OpenAIImagesGenerationsURI | Should -BeExactly 'https://api.openai.com/v1/images/generations'
        }

        It "OpenAI Edit URI is valid" {
            $Script:OpenAIEditsURI | Should -BeExactly 'https://api.openai.com/v1/edits'
        }
    }
}
