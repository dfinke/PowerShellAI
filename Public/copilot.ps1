function copilot {
    <#
        .SYNOPSIS
        Use GPT to help you remember PowerShell commands and other command line tools

        .DESCRIPTION
        Makes the request to GPT, parses the response and displays it in a box and then prompts the user to run the code or not

        .EXAMPLE
        # via https://twitter.com/ClemMesserli/status/1616312238209376260?s=20&t=KknO2iPk3yrQ7x42ZayS7g

        copilot "using PowerShell regex, just code. split user from domain of email address with match:  demo.user@google.com"

        .EXAMPLE
        copilot 'how to get ImportExcel'

        .EXAMPLE
        copilot 'processes running with more than 700 handles'

        .EXAMPLE
        copilot 'processes running with more than 700 handles select first 5, company and name, as json'

        .EXAMPLE
        copilot 'for each file in the current dir list the name and length'
        
        .EXAMPLE
        copilot 'Find all enabled users that have a samaccountname similar to Mazi; List SAMAccountName and DisplayName'
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
