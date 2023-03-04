param (
    [string] $Prompt
)

# Write a powershell script that will restart all websites with a name like dev, then wait until the website is returning the text `"healthy`" on the url `"/healthcheck.html`" and output each site name with write-output when it's ready. Use comments to explain each section of the script

$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot/GPTPwshValidator.psm1" -Force

$scriptText = (Get-GPT3Completion $Prompt).Trim()

$attempt = 1
while ($attempt -le 5) {
    Write-Host "`nAttempt $attempt to validate script:"
    Write-Host -ForegroundColor DarkGray $scriptText
    $correctionPrompt = Test-GPT3Script -ScriptText $scriptText -OriginalPrompt $Prompt -Verbose
    if($correctionPrompt) {
        $scriptText = (Get-GPT3Completion $correctionPrompt -max_tokens 2048).Trim()
        # The prompt keeps returning this text and it messes itself up on subsequent queries
        $scriptText = ($scriptText.Split("`n") | Where-Object { $_ -notlike "*corrected script*" }) -join "`n"
        if([string]::IsNullOrWhiteSpace($scriptText)) {
            Write-Error "Failed: response: '$scriptText' for prompt: '$correctionPrompt'"
        }
        $attempt++
    } else {
        Write-Host -ForegroundColor Green "Final script:`n"
        break
    }
}

Write-Host $scriptText

Write-Host -NoNewline -ForegroundColor Green "`nDo you want to invoke the script content? " 
$answer = Read-Host "(y/N)"
if($answer -eq "y") {
    Write-Host ""
    Invoke-Expression $scriptText
}