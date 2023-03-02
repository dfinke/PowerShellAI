# first pass
# for functions not directly tested for various reasons
# this is a simple test to ensure the function exists
# in cased they are deleted or renamed

Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe "FunctionExist" -Tag 'FunctionExist' {
    It "Should not be null the function exists" {
        $actual = Get-Command Invoke-AIErrorHelper -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }
}
