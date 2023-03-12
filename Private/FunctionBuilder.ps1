$script:CorrectionPrompt = @"
Fix all of these PowerShell issues:
{0}
"@

$script:ValidationPrompt = @"
Can the PowerShell function below {0}?

Respond with either:
- YES without any reasoning or code
- NO followed by a reason and a corrected version of the function

{1}
"@

$script:FunctionTopLeft = $null
$script:ScriptAnalyzerAvailable = $null
$script:ScriptAnalyserIgnoredRules = @(
    "PSReviewUnusedParameter"
)


function Test-ScriptAnalyzerAvailable {
    <#
        .SYNOPSIS
        Checks if PSScriptAnalyzer is available on this system
    #>
    if($null -eq $script:ScriptAnalyzerAvailable) {
        if(Get-Module "PSScriptAnalyzer" -ListAvailable -Verbose:$false) {
            $script:ScriptAnalyzerAvailable = $true
        } else {
            Write-Warning "This module performs better if you have PSScriptAnalyzer installed"
            $script:ScriptAnalyzerAvailable = $false
        }
    }

    return $script:ScriptAnalyzerAvailable
}

function Get-FunctionBuilderAction {
    <#
        .SYNOPSIS
        A prompt for AIFunctionBuilder to allow the user to choose what to do with the final script
    #>

    $actions = @(
        New-Object System.Management.Automation.Host.ChoiceDescription '&Save', 'Save this function to your local filesystem'
        New-Object System.Management.Automation.Host.ChoiceDescription '&Run', 'Save this function to your local filesystem and load it into this PowerShell session'
        New-Object System.Management.Automation.Host.ChoiceDescription '&Quit', 'Exit AIFunctionBuilder'
    )

    $response = $Host.UI.PromptForChoice($null, "What do you want to do?", $actions, 2)

    return $actions[$response].Label -replace '&', ''
}

function Write-FunctionOutput {
    param (
        [int] $CursorPositionX,
        [int] $CursorPositionY,
        [string] $Stage,
        [string] $FunctionText,
        [switch] $SyntaxHighlight
    )
    [Console]::SetCursorPosition($CursorPositionX, $CursorPositionY)
    Write-Host -ForegroundColor Green "Iterations: " -NoNewline
    Write-Host "$Stage               `n"
    $OutputLines = @()
    $script:FunctionTopLeft = $Host.UI.RawUI.CursorPosition
    if($null -ne $FunctionText) {
        $OutputLines = $FunctionText.Split("`n")
        foreach($line in $OutputLines) {
            Write-Host -ForegroundColor DarkGray ("$([Char]27)[48;2;25;25;25m" + $line + (" " * ($Host.UI.RawUI.WindowSize.Width - $line.Length)))
            if(!$SyntaxHighlight) {
                Start-Sleep -Milliseconds 20
            }
        }
    } else {
        Write-Host -ForegroundColor DarkGray "$([Char]27)[48;2;25;25;25mNo function was provided`n"
    }

    Write-Host -NoNewline "$([Char]27)[0m"
    # Clear the rest of the window
    $endOfFunctionPosition = $Host.UI.RawUI.CursorPosition

    Write-Host (" " * $Host.UI.RawUI.WindowSize.Width)

    if($SyntaxHighlight) {
        $tokens = @()
        [System.Management.Automation.Language.Parser]::ParseInput($FunctionText, [ref]$tokens, [ref]$null) | Out-Null

        foreach($token in $tokens) {
            $TokenColor = switch -wildcard ($token.Kind) {
                "Function" { "DarkRed" }
                "Generic" { "Magenta" }
                "String*" { "Cyan" }
                "Variable" { "Cyan" }
                "Identifier" { "Yellow" }
                default { "White" }
            }
            if($token.TokenFlags -like "*operator*" -or $token.TokenFlags -like "*keyword*") {
                $TokenColor = "Red"
            }
            Write-Overlay -Line $token.Extent.StartLineNumber -Column $token.Extent.StartColumnNumber -Text $token.Text -ForegroundColor $TokenColor -TypingDelayMs 0
        }
    }

    [Console]::SetCursorPosition($endOfFunctionPosition.X, $endOfFunctionPosition.Y)
    5..($Host.UI.RawUI.WindowSize.Height - $script:FunctionTopLeft.Y - $OutputLines.Count) | Foreach-Object {
        Write-Host (" " * $Host.UI.RawUI.WindowSize.Width)
    }
    
    [Console]::SetCursorPosition($endOfFunctionPosition.X, $endOfFunctionPosition.Y + 1)
}

function Save-FunctionBuilderOutput {
    <#
        .SYNOPSIS
        Prompt the user for a destination to save their script output an save the output to disk
    #>
    param (
        [string] $FunctionText,
        [string] $FunctionName
    )

    $suggestedFilename = "$FunctionName.ps1"

    $defaultDirectory = Join-Path $env:HOMEDRIVE $env:HOMEPATH

    $powershellAiDirectory = Join-Path $defaultDirectory "PowerShellAI"

    $defaultFile = Join-Path $powershellAiDirectory $SuggestedFilename

    while($true) {
        $finalDestination = Read-Host -Prompt "Enter a location to save or press enter for the default ($defaultFile)"
        if([string]::IsNullOrEmpty($finalDestination)) {
            $finalDestination = $defaultFile
            if(!(Test-Path $powershellAiDirectory)) {
                New-Item -Path $powershellAiDirectory -ItemType Directory -Force | Out-Null
            }
        }

        if(Test-Path $finalDestination) {
            Write-Error "There is already a file at '$finalDestination'"
        } else {
            Set-Content -Path $finalDestination -Value $FunctionText
            Write-Output $finalDestination
            break
        }
    }
}

function Remove-Comments {
    <#
        .SYNOPSIS
        Strip all comments from a PowerShell code block
    #>
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string] $FunctionText
    )

    $tokens = @()

    [System.Management.Automation.Language.Parser]::ParseInput($FunctionText, [ref]$tokens, [ref]$null) | Out-Null

    $comments = $tokens | Where-Object { $_.Kind -eq "Comment" }

    # Strip comments from bottom to top to preserve extent offsets
    $comments | Sort-Object { $_.Extent.StartOffset } -Descending | ForEach-Object {
        $preComment = $FunctionText.Substring(0, $_.Extent.StartOffset)
        $postComment = $FunctionText.Substring($_.Extent.EndOffset, $FunctionText.Length - $_.Extent.EndOffset)
        $FunctionText = $preComment + $postComment
    }

    return $FunctionText
}

function Format-FunctionBuilder {
    <#
        .SYNOPSIS
        Strip all comments from a PowerShell code block and use PSScriptAnalyzer to format the script if it's available
    #>
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string] $FunctionText
    )

    Write-Verbose "FORMATTING - Input function input:`n--------`n$FunctionText`n--------"

    $FunctionText = $FunctionText | Remove-Comments

    if(!($FunctionText -match '(?s)function [a-z0-9\-]+ \{.*(\}|$)')) {
        Write-Verbose "There is no function in this PowerShell code block"
    }

    $FunctionText = $Matches[0]
    
    $FunctionText = ($FunctionText.Split("`n") | Where-Object { ![string]::IsNullOrWhiteSpace($_) }) -join "`n"
    
    if(Test-ScriptAnalyzerAvailable) {
        $FunctionText = $FunctionText | Invoke-Formatter -Verbose:$false
    }

    Write-Verbose "FORMATTING - Output function:`n--------`n$FunctionText`n--------"

    return $FunctionText
}

function Get-FunctionBuilderName {
    <#
        .SYNOPSIS
        Get the name of the function from the code block
    #>
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string] $FunctionText
    )

    if(!($FunctionText -match '(?s)function ([a-z0-9\-]+) \{')) {
        Write-Verbose "There is no function in this PowerShell code block"
    }

    return $Matches[1]
}

function Write-Overlay {
    # TODO Build a code renderer instead of hacking around write-host
    param (
        [int] $Line,
        [string] $Text,
        [string] $ForegroundColor,
        [string] $BackgroundColor = $null,
        [int] $Column = 1,
        [int] $TypingDelayMs = 20
    )
    try {
        [Console]::CursorVisible = $false
        $initialCursorPosition = $Host.UI.RawUI.CursorPosition
        $x = $script:FunctionTopLeft.X + $Column - 1
        $y = $script:FunctionTopLeft.Y + $Line - 1
        [Console]::SetCursorPosition($x, $y)
        foreach($letter in $Text.ToCharArray()) {
            if($BackgroundColor) {
                Write-Host -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor -NoNewline $letter
            } else {
                Write-Host -ForegroundColor $ForegroundColor -NoNewline ("$([Char]27)[48;2;25;25;25m" + $letter)
            }
            Write-Host -NoNewline "$([Char]27)[0m"
            Start-Sleep -Milliseconds $TypingDelayMs
        }
        [Console]::SetCursorPosition($initialCursorPosition.X, $initialCursorPosition.Y)
    } finally {
        [Console]::CursorVisible = $true
    }
}

function Test-FunctionBuilderParsing {
    <#
        .SYNOPSIS
        This function tests the quality of a PowerShell function using PSScriptAnalyzer module.

        .DESCRIPTION
        The Test-FunctionBuilderParsing function checks the quality of a PowerShell script by using the PSScriptAnalyzer module.
        If any errors or warnings are detected, the function outputs a list of lines containing errors and their corresponding error messages.
        If the module is not installed, the function silently bypasses script quality validation because it's not critical to the operation of the AI Script Builder.

        .PARAMETER FunctionText
        Specifies the text of the PowerShell script to be tested.

        .EXAMPLE
        Test-FunctionBuilderParsing -FunctionText "Get-ChildItem | Where-Object { $_.Length -gt 1GB }"
    #>
    [CmdletBinding()]
    param (
        [string] $FunctionText
    )

    $functionName = Get-FunctionBuilderName -FunctionText $FunctionText

    if(Test-ScriptAnalyzerAvailable) {
        Write-Verbose "Using PSScriptAnalyzer to validate script quality"
        $scriptAnalyzerOutput = Invoke-ScriptAnalyzer -ScriptDefinition $FunctionText `
            -Severity @("Warning", "Error", "ParseError") `
            -ExcludeRule $script:ScriptAnalyserIgnoredRules `
            -Verbose:$false

        if($null -ne $scriptAnalyzerOutput) {
            $brokenLines = $scriptAnalyzerOutput | Group-Object Line

            # This originally returned the whole list of errors but it was too much for the LLM to understand, just return the first and then fix
            # other errors on future iterations
            $firstBrokenLine = $brokenLines[0]
            $brokenLineErrors = $firstBrokenLine.Group.Message
            $ruleNames = $firstBrokenLine.Group.RuleName

            Write-Overlay -Line ($firstBrokenLine.Name) -Text $($FunctionText.Split("`n")[$firstBrokenLine.Name - 1]) -BackgroundColor "White" -ForegroundColor "Red"

            if($ruleNames | Where-Object { $_ -eq "PSAvoidOverwritingBuiltInCmdlets" }) {
                Write-Output " - The name of the function is reserved, rename the function to not collide with internal PowerShell commandlets."
            } elseif($ruleNames | Where-Object { $_ -eq "PSUseApprovedVerbs" }) {
                $verb = $functionName.Split("-")[0]
                Write-Output " - The function is using an unapproved verb ($verb)."
            } else {
                $brokenLineErrors | ForEach-Object {
                    Write-Output " - $_"
                }
            }
        }
    } else {
        Write-Verbose "PSScriptAnalyzer is not installed so falling back on parsing directly with PS internals"
        try {
            [scriptblock]::Create($FunctionText) | Out-Null
        } catch {
            $innerExceptionErrors = $_.Exception.InnerException.Errors
            if($innerExceptionErrors) {
                Write-Output " - The script is invalid because of a parsing issue:`n$(($innerExceptionErrors | ForEach-Object { '   ' + $_.Message }) -join "`n")"
            } else {
                Write-Output " - The script is invalid because of a $($_.FullyQualifiedErrorId)."
            }
        }
    }

    if(Get-Command $functionName -ErrorAction "SilentlyContinue") {
        Write-Overlay -Line 1 -Text ($FunctionText.Split("`n")[0]) -BackgroundColor "White" -ForegroundColor "Red"
        Write-Output " - The name of the function is reserved, rename the function to not collide with common function names."
    }
}

function Test-FunctionBuilderCommandletUsage {
    <#
        .SYNOPSIS
        This function tests the usage of commandlets in a PowerShell script.

        .DESCRIPTION
        The Test-FunctionBuilderCommandletUsage function checks the usage of commandlets in a PowerShell script by analyzing the Abstract Syntax Tree (AST) of the script.
        For each commandlet found in the script, the function checks whether the commandlet is valid and whether any of the commandlet parameters are invalid.

        .PARAMETER FunctionText
        Specifies the text content of the PowerShell script to be tested.

        .EXAMPLE
        $FunctionText = Get-Content -Path "C:\Scripts\MyScript.ps1" -Raw
        Test-FunctionBuilderCommandletUsage -ScriptAst $scriptAst

        This example tests the usage of commandlets in a PowerShell script.
    #>
    param (
        [string] $FunctionText
    )

    $scriptAst = [System.Management.Automation.Language.Parser]::ParseInput($FunctionText, [ref]$null, [ref]$null)

    $commandlets = $scriptAst.FindAll({$args[0].GetType().Name -eq "CommandAst"}, $true)

    $commandlets | ForEach-Object {
        $commandletName = $_.CommandElements[0].Value
        $commandletParameterNames = $_.CommandElements.ParameterName
        $commandletParameterElements = @()
        $hasPipelineInput = $_.Parent.GetType().Name -eq "PipelineAst"
        $extent = $_.Extent
        if($_.CommandElements.Count -gt 1) {
            $commandletParameterElements = $_.CommandElements[1..($_.CommandElements.Count - 1)]
        }
        $command = Get-Command $commandletName -ErrorAction "SilentlyContinue"

        # Check online if no local command is found
        if($null -eq $command) {
            $onlineModules = Find-Module -Command $commandletName -Verbose:$false
            if($onlineModules) {
                Write-Host "There are modules online that include the functions used by ChatGPT. To validate the usage of commandlets in the function the module needs to be installed locally.`n"
                Write-Host ($onlineModules | Select-Object Name, ProjectUri | Out-String).Trim()
                while(!$command) {
                    $onlineModuleToInstall = Read-Host "`nEnter the name of one of the modules to install or press enter to get ChatGPT to try use a different command"
                    if(![string]::IsNullOrEmpty($onlineModuleToInstall)) {
                        Install-Module -Name $onlineModuleToInstall.Trim() -Scope CurrentUser -Verbose:$false
                        Import-Module -Name $onlineModuleToInstall.Trim() -Verbose:$false
                        $command = Get-Command $commandletName
                        Write-Host ""
                    } else {
                        Write-Host "Asking ChatGPT to use another command instead of installing the module"
                        break
                    }
                }
            }
        }

        if($null -eq $command) {
            Write-Overlay -Line $extent.StartLineNumber -Column $extent.StartColumnNumber -Text $extent.Text -BackgroundColor "White" -ForegroundColor "Red"
            Write-Output " - The commandlet $commandletName cannot be found, use a different command or write your own implementation."
        } else {
            # Check for missing parameters
            foreach($param in $commandletParameterNames) {
                if(![string]::IsNullOrEmpty($param)) {
                    if(!$command.Parameters.ContainsKey($param)) {
                        Write-Overlay -Line $extent.StartLineNumber -Column $extent.StartColumnNumber -Text $extent.Text -BackgroundColor "White" -ForegroundColor "Red"
                        Write-Output " - The commandlet $commandletName does not take a parameter named $param."
                    }
                }
            }

            # Check for unnamed parameters, these are harder to validate and makes a generated script less obvious as to what it does
            $previousElementWasParameterName = $false
            $validateParameterSets = $true
            foreach($element in $commandletParameterElements) {
                if($element.GetType().Name -eq "CommandParameterAst") {
                    $previousElementWasParameterName = $true
                } else {
                    if(!$previousElementWasParameterName) {
                        Write-Overlay -Line $extent.StartLineNumber -Column $extent.StartColumnNumber -Text $extent.Text -BackgroundColor "White" -ForegroundColor "Red"
                        Write-Output " - Use a named parameter when passing $element to $commandletName."
                        $validateParameterSets = $false
                    }
                    $previousElementWasParameterName = $false
                }
            }

            # Check named parameters haven't been specified more than once
            $commandletParameterNames | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object {
                Write-Overlay -Line $extent.StartLineNumber -Column $extent.StartColumnNumber -Text $extent.Text -BackgroundColor "White" -ForegroundColor "Red"
                Write-Output " - The parameter $($_.Name) cannot be provided more than once to $commandletName."
            }
            
            # Check at least one parameter set is satisfied if all parameters to this commandlet have been specified by name
            if($validateParameterSets) {
                $parameterSetSatisfied = $false
                if($command.ParameterSets.Count -eq 0) {
                    $parameterSetSatisfied = $true
                } else {
                    foreach($parameterSet in $command.ParameterSets) {
                        $mandatoryParameters = $parameterSet.Parameters | Where-Object { $_.IsMandatory }
                        $mandatoryParametersUsed = $mandatoryParameters | Where-Object { $commandletParameterNames -contains $_.Name }
                        if($hasPipelineInput -and ($mandatoryParameters | Where-Object { $_.ValueFromPipeline })) {
                            $mandatoryParametersUsed += @{
                                Name = "Pipeline Input"
                            }
                        }
                        if($mandatoryParameters.Count -eq $mandatoryParametersUsed.Count) {
                            $parameterSetSatisfied = $true
                            break
                        }
                    }
                }
                if(!$parameterSetSatisfied) {
                    Write-Overlay -Line $extent.StartLineNumber -Column $extent.StartColumnNumber -Text $extent.Text -BackgroundColor "White" -ForegroundColor "Red"
                    Write-Output " - Parameter set cannot be resolved using the specified named parameters for $commandletName."
                }
            }
        }
    }
}

function Test-FunctionBuilderSyntax {
    <#
        .SYNOPSIS
        This function tests a PowerShell script for quality and commandlet usage issues.

        .DESCRIPTION
        The Test-FunctionBuilderSyntax function checks a PowerShell script for quality and commandlet usage issues by calling the
        validating the script parses correctly and all commandlets exist and have the correct parameters used.
        If any issues are found, the function returns a ChatGPT prompt that requests the LLM to perform corrections for the issues.

        .PARAMETER FunctionText
        Specifies the text of the PowerShell script to be tested.

        .PARAMETER OriginalPrompt
        Specifies the prompt to be used when prompting the user for corrections.

        .EXAMPLE
        $FunctionText = @"
        Get-Service | Where-Object {$_.Status -eq "Running"} | Sort-Object -Property Name
        "@
        $originalPrompt = "Some Prompt"
        Test-FunctionBuilderSyntax -FunctionText $FunctionText -OriginalPrompt $originalPrompt

        This example tests the specified PowerShell script for quality and commandlet usage issues. If any issues are found, the function returns a prompt for corrections.
    #>

    param (
        [string] $FunctionText
    )

    $issuesToCorrect = @()
    $issuesToCorrect += Test-FunctionBuilderParsing -FunctionText $FunctionText
    if(!$issuesToCorrect) {
        $issuesToCorrect += Test-FunctionBuilderCommandletUsage -FunctionText $FunctionText
    }

    $issuesToCorrect = $issuesToCorrect | Group-Object | Select-Object -ExpandProperty Name
    
    if($issuesToCorrect.Count -gt 0) {
        $currentCorrectionPrompt = ($script:CorrectionPrompt -f ($issuesToCorrect -join "`n"))
        Write-Host -ForegroundColor Red $currentCorrectionPrompt
        return $currentCorrectionPrompt
    } else {
        Write-Verbose "The script has no issues to correct"
    }
}

function Repair-FunctionBuilderSemantics {
    <#
        .SYNOPSIS
        This function tests a PowerShell script will achieve what is stated in the prompt and repairs it if it has gone astray.

        .DESCRIPTION
        The Repair-FunctionBuilderSemantics function checks a PowerShell script will achieve what it was intended to do.
        This script is either returned in its original form or updated to fit the prompt direction.

        .PARAMETER FunctionText
        Specifies the text of the PowerShell script to be tested.

        .PARAMETER Prompt
        Specifies the prompt to be used to check the semantics of the script.
    #>

    param (
        [string] $FunctionText,
        [string] $Prompt
    )

    $semanticsRequest = ($script:ValidationPrompt -f $Prompt, $FunctionText)

    Write-Verbose "Raw semantics GPT request:`n$semanticsRequest"

    $result = Get-GPT3Completion $semanticsRequest -Verbose:$false

    Write-Verbose "Raw semantics GPT response:`n$result"

    if($result.Trim() -match "(?i)^yes") {
        $result = $FunctionText
    } else {
        $reason = ($result -replace '(?s)Function\s+[A-Za-z\-0-9]+\s+{.+$', '').Trim() -replace '^NO\.?\s+', ''
        Write-Host -ForegroundColor Red $reason
        Start-Sleep -Seconds 3
    }

    return $result
}
