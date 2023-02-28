Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe "OpenAIUri" -Tag 'OpenAIUri' {
    InModuleScope 'PowerShellAI' {
        It "Should return the OpenAI URI" {
            $actual = $Script:OpenAIBaseURI

            $actual | Should -Be 'https://api.openai.com/v1'
        }

        It "Should return the OpenAI Models URI" {
            $actual = $Script:OpenAIModelsURI

            $actual | Should -Be 'https://api.openai.com/v1/models'
        }

        It "Should return the OpenAI Moderations URI" {
            $actual = $Script:OpenAIModerationsURI

            $actual | Should -Be 'https://api.openai.com/v1/moderations'
        }

        It "Should return the OpenAI Completions URI" {
            $actual = $Script:OpenAICompletionsURI

            $actual | Should -Be 'https://api.openai.com/v1/completions'
        }

        It "Should return the OpenAI Images Generations URI" {
            $actual = $Script:OpenAIImagesGenerationsURI

            $actual | Should -Be 'https://api.openai.com/v1/images/generations'
        }

        It "Should return the OpenAI Edit URI" {
            $actual = $Script:OpenAIEditsURI

            $actual | Should -Be 'https://api.openai.com/v1/edits'
        }
    }
}
