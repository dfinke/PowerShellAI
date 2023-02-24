Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe "OpenAIUri" -Tag 'OpenAIUri' {
    It "Should return the OpenAI URI" {
        $actual = Get-OpenAIBaseRestURI

        $actual | Should -Be 'https://api.openai.com/v1'
    }

    It "Should return the OpenAI Models URI" {
        $actual = Get-OpenAIModelsURI

        $actual | Should -Be 'https://api.openai.com/v1/models'
    }

    It "Should return the OpenAI Moderations URI" {
        $actual = Get-OpenAIModerationsURI

        $actual | Should -Be 'https://api.openai.com/v1/moderations'
    }

    It "Should return the OpenAI Completions URI" {
        $actual = Get-OpenAICompletionsURI

        $actual | Should -Be 'https://api.openai.com/v1/completions'
    }

    It "Should return the OpenAI Images Generations URI" {
        $actual = Get-OpenAIImagesGenerationsURI

        $actual | Should -Be 'https://api.openai.com/v1/images/generations'
    }

    It "Should return the OpenAI Edit URI" {
        $actual = Get-OpenAIEditsURI

        $actual | Should -Be 'https://api.openai.com/v1/edits'
    }
}
