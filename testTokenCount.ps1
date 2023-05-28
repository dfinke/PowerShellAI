param(
    $Filter = "*.ps1"
)

Import-Module D:\mygit\PowerShellAI\PowerShellAI.psd1 -Force

$targetFiles = Get-ChildItem . -r $Filter

$result = @()
$fileProgress = 0
$totalFiles = $targetFiles.Count

foreach ($file in $targetFiles) {
    $fileProgress++
    Write-Progress -Activity "Processing files" -Status $file.Name -PercentComplete (($fileProgress / $totalFiles) * 100)
    $content = Get-Content $file.FullName -Raw
    $result += [PSCustomObject]@{
        FileName       = $file.Name
        NumberOfTokens = Get-NumberOfTokens $content
    }
}

$result