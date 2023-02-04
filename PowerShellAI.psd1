@{
    RootModule        = 'PowerShellAI.psm1'
    ModuleVersion     = '0.3.3'
    GUID              = '081ce7b4-6e63-41ca-92a7-2bf72dbad018'
    Author            = 'Douglas Finke'
    CompanyName       = 'Doug Finke'
    Copyright         = 'c 2023 All rights reserved.'

    Description       = @'
PowerShell GPT AI module allows to integrate with OpenAI API and access GPT-3 model and easily to use with other PowerShell scripts and tools.
'@

    FunctionsToExport = @(
        'ai'
        'ConvertFrom-GPTMarkdownTable'
        'copilot'
        'Disable-AIShortCutKey'
        'Enable-AIShortCutKey'
        'Get-DalleImage'
        'Get-GPT3Completion'
        'Set-DalleImageAsWallpaper'
    )

    AliasesToExport   = @(
        'gpt'
    )

    PrivateData       = @{
        PSData = @{
            Category   = "PowerShell GPT Module"
            Tags       = @("PowerShell", "GPT", "OpenAI")
            ProjectUri = "https://github.com/dfinke/PowerShellAI"
            LicenseUri = "https://github.com/dfinke/PowerShellAI/blob/master/LICENSE.txt"
        }
    }
}