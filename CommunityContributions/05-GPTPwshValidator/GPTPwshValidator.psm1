#Requires -Modules PSScriptAnalyzer

function Test-GPT3Script {
    [CmdletBinding()]
    param (
        [string] $ScriptText,
        [string] $OriginalPrompt
    )

    $scriptAnalyzerOutput = Invoke-ScriptAnalyzer -ScriptDefinition $ScriptText -Severity @("Warning", "Error", "ParseError") -Verbose:$false

    $errorsToCorrect = @()
    if($null -ne $scriptAnalyzerOutput) {
        $brokenLines = $scriptAnalyzerOutput | Group-Object Line
        $brokenLines | ForEach-Object {
            $brokenLine = $_
            $brokenLineText = $ScriptText.Split("`n")[$brokenLine.Name - 1]
            $brokenLineErrors = $brokenLine.Group.Message
            $errorsToCorrect += " - Line $($brokenLine.Name - 1) ($($brokenLineText.Trim())) is not valid powershell because it has the errors: $brokenLineErrors"
        }
    }

    try {
        $commandlets = [scriptblock]::Create($ScriptText).Ast.FindAll({$args[0].GetType().Name -like "CommandAst"}, $true)

        $commandlets | ForEach-Object {
            $commandletName = $_.CommandElements[0].Value
            $commandletParams = $_.CommandElements.ParameterName
            $command = Get-Command $commandletName -ErrorAction "SilentlyContinue"
            if($null -eq $command) {
                $errorsToCorrect += " - The commandlet $commandletName cannot be found you may need to import a module or use a different command."
            } else {
                $commandletParams | Foreach-Object {
                    if(![string]::IsNullOrEmpty($_)) {
                        if(!$command.Parameters.ContainsKey($_)) {
                            $errorsToCorrect += " - The commandlet $commandletName does not take a parameter named $_."
                        }
                    }
                }
            }
        }
    } catch {
        $errorsToCorrect += " - The script cannot be validated because of a $($_.FullyQualifiedErrorId)"
    }

    if($errorsToCorrect.Count -lt 1) {
        return $false
    }

    Write-Verbose "The following errors need correcting:`n$($errorsToCorrect -join "`n")"

    $correctionPrompt = @"
Respond to the following request with powershell code only. Never say "corrected script" in your response.

Correct the script below that is supposed to meet the criteria: $OriginalPrompt

Provide a version of the script with the following errors corrected:

$($errorsToCorrect -join "`n")

The script is:
$ScriptText
"@

    return $correctionPrompt.Trim()
}