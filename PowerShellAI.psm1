Add-Type -Path "$PSScriptRoot\SharpToken.dll"

$Script:OpenAIKey = $null

foreach ($directory in @('Public', 'Private')) {
    Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1" | ForEach-Object { . $_.FullName }
}
