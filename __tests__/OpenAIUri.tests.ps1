Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe "OpenAIUri" -Tag 'OpenAIUri' {
    InModuleScope 'PowerShellAI' {
        It "Should return the OpenAI URI" {
            $Script:OpenAIBaseURI | Should -BeExactly 'https://api.openai.com/v1'
        }

        It "Should return the OpenAI Models URI" {
            $Script:OpenAIModelsURI | Should -BeExactly 'https://api.openai.com/v1/models'
        }

        It "Should return the OpenAI Moderations URI" {
            $Script:OpenAIModerationsURI | Should -BeExactly 'https://api.openai.com/v1/moderations'
        }

        It "Should return the OpenAI Completions URI" {
            $Script:OpenAICompletionsURI | Should -BeExactly 'https://api.openai.com/v1/completions'
        }

        It "Should return the OpenAI Images Generations URI" {
            $Script:OpenAIImagesGenerationsURI | Should -BeExactly 'https://api.openai.com/v1/images/generations'
        }

        It "Should return the OpenAI Edit URI" {
            $Script:OpenAIEditsURI | Should -BeExactly 'https://api.openai.com/v1/edits'
        }
    }
}
