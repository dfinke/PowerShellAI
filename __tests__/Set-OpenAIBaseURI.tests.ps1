Remove-Module 'PowerShellAI' -Force -ErrorAction Ignore
Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe 'Set-OpenAIBaseURI' -Tag 'Set-OpenAIBaseURI' {
    It 'Should throw when Uri parameter value is null' {
        { Set-OpenAIBaseURI -Uri $null } | Should -Throw
    }

    It 'Should throw when Uri parameter value is empty' {
        { Set-OpenAIBaseURI -Uri '' } | Should -Throw
    }

    It 'Should accept valid string as Uri parameter value' {
        { Set-OpenAIBaseURI -Uri 'https://api.openai.com' } | Should -Not -Throw
    }

    AfterAll {
        InModuleScope 'PowerShellAI' {
            #Reset module scope base OpeAI URI with fake OpenAI URI
            $Script:OpenAIBaseUri = $null
        }
    }
}
