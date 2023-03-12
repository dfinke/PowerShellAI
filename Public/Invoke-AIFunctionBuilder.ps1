function Invoke-AIFunctionBuilder {
    <#
        .SYNOPSIS
            Create a PowerShell script with the help of ChatGPT
        .DESCRIPTION
            Invoke-AIFunctionBuilder is a function that uses ChatGPT to generate an initial PowerShell function to achieve the goal defined
            in the prompt by the user but goes a few steps beyond the typical interaction with an LLM by auto-validating the result
            of the AI generated script using parsing techniques that feed common issues back to the model until it resolves them.
        .EXAMPLE
            Invoke-AIFunctionBuilder
    #>
    [CmdletBinding()]
    [alias("ifb")]
    param(
        [string] $Prompt,
        [int] $MaximumReinforcementIterations = 10,
        [int] $MaxTokens = 2048
    )

    $ErrorActionPreference = "SilentlyContinue"

    if([string]::IsNullOrEmpty($Prompt)) {
        $prePrompt = "Write a PowerShell function that will"
        Write-Host -ForegroundColor Green -NoNewline "`n${prePrompt}: "
        $Prompt = Read-Host
    }
    $postPrompt = $prePrompt + " " + $Prompt

    $topLeftPosition = $Host.UI.RawUI.CursorPosition
    $topLeftPosition.Y++

    Write-Verbose "Sending initial prompt for completion: '$postPrompt'"
    $currentFunctionText = Get-GPT3Completion $postPrompt -Verbose:$false | Format-FunctionBuilder

    $iteration = 1
    while ($true) {

        if($iteration -gt $MaximumReinforcementIterations) {
            Write-Error "A valid function was not able to generated in $MaximumReinforcementIterations iterations, try again with a higher -MaximumReinforcementIterations value or rethink the initial prompt to be more explicit"
            return
        }
        
        Write-FunctionOutput -CursorPositionX $topLeftPosition.X -CursorPositionY $topLeftPosition.Y -Stage "$iteration (syntax validation)" -FunctionText $currentFunctionText
        $correctionPrompt = Test-FunctionBuilderSyntax -FunctionText $currentFunctionText
        
        if($correctionPrompt) {
            $currentFunctionText = (Get-OpenAIEdit -InputText $currentFunctionText -Instruction $correctionPrompt).text | Format-FunctionBuilder

            Write-FunctionOutput -CursorPositionX $topLeftPosition.X -CursorPositionY $topLeftPosition.Y -Stage "$iteration (semantic validation)" -FunctionText $currentFunctionText
            $currentFunctionText = Repair-FunctionBuilderSemantics -FunctionText $currentFunctionText -Prompt $Prompt | Format-FunctionBuilder
        } else {
            break
        }

        $iteration++
    }

    Write-FunctionOutput -CursorPositionX $topLeftPosition.X -CursorPositionY $topLeftPosition.Y -Stage "$iteration (passed all validation)" -FunctionText $currentFunctionText -SyntaxHighlight

    $action = Get-FunctionBuilderAction -Filename $suggestedFilename
    $functionName = Get-FunctionBuilderName -FunctionText $currentFunctionText

    switch($action) {
        "Run" {
            $scriptLocation = Save-FunctionBuilderOutput -FunctionText $currentFunctionText -FunctionName $functionName
            Write-Host "Running '. $scriptLocation'`n`nYou can now use this function"
            . $scriptLocation
        }
        "Save" {
            Save-FunctionBuilderOutput -FunctionText $currentFunctionText -FunctionName $functionName
        }
    }
}