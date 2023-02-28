function copilot {
    <#
        .SYNOPSIS
        Use GPT to help you remember PowerShell commands and other command line tools.

        .DESCRIPTION
        Makes the request to GPT, parses the response and displays it in a box and then prompts the user to run the code or not.

        .PARAMETER Raw
        Returns the raw JSON response from the API and does not prompt for choice.

        .EXAMPLE
        # via https://twitter.com/ClemMesserli/status/1616312238209376260?s=20&t=KknO2iPk3yrQ7x42ZayS7g

        copilot "using PowerShell regex, just code. split user from domain of email address with match: demo.user@google.com"

        .EXAMPLE
        copilot 'how to get ImportExcel'

        .EXAMPLE
        copilot 'processes running with more than 700 handles'

        .EXAMPLE
        copilot 'processes running with more than 700 handles select first 5, company and name, as json'

        .EXAMPLE
        copilot 'for each file in the current dir list the name and length'

        .EXAMPLE
        copilot 'Find all enabled users that have a SamAccountName similar to Mazi; List SamAccountName and DisplayName'
    #>
    param(
        [Parameter(Mandatory)]
        $inputPrompt,
        [ValidateRange(0,2)]
        [decimal]$temperature = 0.0,
        # The maximum number of tokens to generate. default 256
        $max_tokens = 256,
        # Don't show prompt for choice
        [Switch]$Raw
    )

    try {
        $shell = 'powershell, just code:'

        $promptComments = ', include comments'
        if (-not $IncludeComments) {
            $promptComments = ''
        }

        $prompt = "using {0} {1}: {2}`n{3}" -f $shell, $promptComments, $inputPrompt, '```'

        $splatParams = @{
            prompt      = $prompt
            max_tokens  = $max_tokens
            temperature = $temperature
            stop        = '```'
            ErrorAction = 'Stop'
        }
        $completion = (Get-GPT3Completion @splatParams).Split("`n")

        if ($completion[0] -ceq 'powershell') {
            $completion = $completion[1..($completion.Count - 1)]
        }

        if ($Raw) {
            return $completion
        } else {
            ($result = @($inputPrompt) + $completion) | CreateBoxText
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

                Invoke-Expression -Command [string]::Join("`n", $runnable)
            }
            else {
                'Not running'
            }
        }
    } catch {
        Write-Error -ErrorRecord $_ -ErrorAction $ErrorActionPreference
    }
}
