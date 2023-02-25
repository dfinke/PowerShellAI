Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe "Set-OpenAIKey" -Tag 'SetOpenAIKey' {
    It "Should throw when Key parameter value is null" {
        {Set-OpenAIKey -Key $null} | Should -Throw
    }

    It "Should throw when Key parameter value is empty" {
        {Set-OpenAIKey -Key ([System.Security.SecureString]::new())} | Should -Throw
    }

    It "Should throw when Key parameter value is not of [SecureString] type" {
        {Set-OpenAIKey -Key 'NotSecureStringType'} | Should -Throw
    }

    It "Should accept valid secure string as Key parameter value" {
        {Set-OpenAIKey -Key (ConvertTo-SecureString -String 'FakeOpenAIKey' -AsPlainText -Force)} | Should -Not -Throw
    }
}
