
$fullpath = $env:PSModulePath -split ":(?!\\)|;|," |
Where-Object { $_ -notlike ([System.Environment]::GetFolderPath("UserProfile") + "*") -and $_ -notlike "$pshome*" } |
Select-Object -First 1

$fullPath = Join-Path $fullPath -ChildPath "PowerShellAI"

Push-location $PSScriptRoot
Robocopy . $fullPath /mir /XD .vscode images .git .github .devcontainer /XF README.md .gitattributes .gitignore install.ps1 InstallModule.ps1 PublishToGallery.ps1
Pop-Location