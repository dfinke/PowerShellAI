@{
    RootModule        = 'PowerShellAI.psm1'
    ModuleVersion     = '0.4.7'
    GUID              = '081ce7b4-6e63-41ca-92a7-2bf72dbad018'
    Author            = 'Douglas Finke'
    CompanyName       = 'Doug Finke'
    Copyright         = 'c 2023 All rights reserved.'

    Description       = @'
The PowerShell AI module integrates with the OpenAI API and let's you easily access the GPT models for text completion, image generation and more.
'@

    FunctionsToExport = @(
        'ai'
        'ConvertFrom-GPTMarkdownTable'
        'copilot'
        'Disable-AIShortCutKey'
        'Enable-AIShortCutKey'
        'Get-DalleImage'
        'Get-GPT3Completion'
        'Get-OpenAIModel'
        'Get-OpenAIModeration'
        'Invoke-OpenAIAPI'
        'Set-DalleImageAsWallpaper'
        'Set-OpenAIKey'
        'Get-OpenAIEdit'
        'New-SpreadSheet'
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
