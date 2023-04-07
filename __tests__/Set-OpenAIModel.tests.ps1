Remove-Module 'PowerShellAI' -Force -ErrorAction Ignore
Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe "Set-OpenAIModel" {
    It "Should throw when Model parameter value is null" {
        {Set-OpenAIModel -Model $null} | Should -Throw
    }

    It "Should throw when Model parameter value is empty" {
        {Set-OpenAIModel -Model ""} | Should -Throw
    }
}
