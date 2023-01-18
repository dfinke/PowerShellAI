function ai {
    <#
        .SYNOPSIS
        Use GPT to help you remember PowerShell commands and other command line tools

        .DESCRIPTION
        Use GPT to help you remember PowerShell commands and other command line tools

        .EXAMPLE
        ai 'how to get ImportExcel'

        .EXAMPLE
        ai 'processes running with more thatn 700 handles'

        .EXAMPLE
        ai 'processes running with more thatn 700 handles select first 5, company and name, as json'

        .EXAMPLE
        ai 'for each file in the current dir list the name and length'
    #>
    param(
        [Parameter(Mandatory)]
        $inputPrompt,
        # The maximum number of tokens to generate. default 256
        $max_tokens = 256,
        # Don't show prompt for choice
        [Switch]$Raw
    )
    
    # $inputPrompt = $args -join ' '
    
    $shell = 'powershell, just code:'
    
    $promptComments = ', include comments'
    if (-not $IncludeComments) {
        $promptComments = ''
    }

    $prompt = "using {0} {1}: {2}`n" -f $shell, $promptComments, $inputPrompt
    $prompt += '```'

    $completion = Get-GPT3Completion -prompt $prompt -max_tokens $max_tokens -stop '```'
    $completion = $completion -split "`n"
    
    if ($completion[0] -ceq 'powershell') {
        $completion = $completion[1..($completion.Count - 1)]
    }

    if ($Raw) {
        return $completion
    }
    else {
        $result = @($inputPrompt)
        $result += ''
        $result += $completion

        $result | CreateBoxText

        $userInput = CustomReadHost

        if ($userInput -eq 0) {
            $runnable = for ($idx = 1; $idx -lt $result.Count; $idx++) {
                $line = $result[$idx]
                if ([string]::IsNullOrEmpty($line)) {
                    continue
                }

                $line = $line.Trim()
                if ($line.StartsWith('#')) {
                    continue
                }

                $line
            }

        ($runnable -join "`n") | Invoke-Expression
        }
        else {
            "Not running"
        }
    }
}