[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification='$secureStringKey and $environmentVariableKey variables are used in tests')]
param()

Describe "Get-OpenAIKey" -Tag 'GetOpenAIKey' {
    BeforeEach {
        Remove-Module 'PowerShellAI' -Force
        Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force
    }

    AfterEach {
        $env:OpenAIKey = $null
    }

    InModuleScope 'PowerShellAI' {
        BeforeAll {
            $secureStringKey = 'OpenAIKeySecureString'
            $environmentVariableKey = 'OpenAIKeyEnvironmentVariable'
        }

        It 'Should return value of type [String] when $env:OpenAIKey is set' {
            $env:OpenAIKey = $environmentVariableKey
            Get-OpenAIKey | Should -BeOfType 'System.String'
        }

        It 'Should return the same value as set in $env:OpenAIKey' {
            $env:OpenAIKey = $environmentVariableKey
            Get-OpenAIKey | Should -BeExactly $env:OpenAIKey
        }

        if ($PSVersionTable.PSVersion.Major -lt 6) {
            It 'Should return value of type [String] set with Set-OpenAIKey on PowerShell 5 and lower' {
                Set-OpenAIKey -Key (ConvertTo-SecureString -String $secureStringKey -AsPlainText -Force)
                Get-OpenAIKey | Should -BeOfType 'System.String'
            }

            It 'Should return the same value as set with Set-OpenAIKey on PowerShell 5 and lower' {
                Set-OpenAIKey -Key (ConvertTo-SecureString -String $secureStringKey -AsPlainText -Force)
                Get-OpenAIKey | Should -BeExactly $secureStringKey
            }
        } else {
            It 'Should return value of type [SecureString] set with Set-OpenAIKey on PowerShell 6 and higher' {
                Set-OpenAIKey -Key (ConvertTo-SecureString -String $secureStringKey -AsPlainText -Force)
                Get-OpenAIKey | Should -BeOfType 'System.Security.SecureString'
            }

            It 'Should return the same value as set with Set-OpenAIKey on PowerShell 6 and higher' {
                Set-OpenAIKey -Key (ConvertTo-SecureString -String $secureStringKey -AsPlainText -Force)
                Get-OpenAIKey | ConvertFrom-SecureString -AsPlainText | Should -BeExactly $secureStringKey
            }
        }

        It 'OpenAI key set with Set-OpenAIKey has priority over $env:OpenAIKey' {
            $env:OpenAIKey = $environmentVariableKey
            Set-OpenAIKey -Key (ConvertTo-SecureString -String $secureStringKey -AsPlainText -Force)
            if ($PSVersionTable.PSVersion.Major -gt 5) {
                Get-OpenAIKey | ConvertFrom-SecureString -AsPlainText | Should -BeExactly $secureStringKey
            } else {
                Get-OpenAIKey | Should -BeExactly $secureStringKey
            }
        }
    }
}
