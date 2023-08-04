function Get-Runnable {
    <#
        .SYNOPSIS
        Gets the runnable code from the result

        .DESCRIPTION
        Gets the runnable code from the result

        .EXAMPLE
        Get-Runnable -result $result
    #>
    [CmdletBinding()]
    param(
        $result
    )

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

    return ($runnable -join "`n")
}

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
    [CmdletBinding()]
    [alias("??")]
    param(
        [Parameter(Mandatory)]
        $inputPrompt,
        $SystemPrompt = 'using powershell, just code:',
        [ValidateRange(0, 2)]
        [decimal]$temperature = 0.0,
        # The maximum number of tokens to generate. default 256
        [ValidateRange(1, 4000)]
        $max_tokens = 256,
        # Don't show prompt for choice
        [Switch]$Raw
    )
    
    # $inputPrompt = $args -join ' '
    
    #$shell = 'powershell, just code:'
    
    $promptComments = ', include comments'
    if (-not $IncludeComments) {
        $promptComments = ''
    }

    $prompt = "{0} {1}: {2}`n" -f $SystemPrompt, $promptComments, $inputPrompt
    $prompt += '```'

    $completion = Get-GPT3Completion -prompt $prompt -max_tokens $max_tokens -temperature $temperature -stop '```'
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

        $runnable = Get-Runnable -result $result
        
        if (Test-AifbScriptAnalyzerAvailable) {
            $runnable = Invoke-Formatter -ScriptDefinition $runnable -Verbose:$false
        }

        Write-Codeblock -Text $runnable -ShowLineNumbers -SyntaxHighlight

        do {
            $userInput = CustomReadHost
        
            switch ($userInput) {
                0 {
                (Get-Runnable -result $result) | Invoke-Expression
                }
                1 {
                    explain -Value (Get-Runnable -result $result)
                    write-output "`n"
                }
                2 {
                    Get-Runnable -result $result | Set-Clipboard
                }
                3 {
                    if (Test-VSCodeInstalled) {
                    (Get-Runnable $result) | code -                
                    }
                    else {
                        "Not running"
                    }
                }
                default {
                    "Not running"
                }
            }
        } while ($userInput -eq 1)
    }
}


function git? {
    <#
    .SYNOPSIS
        A brief description of what the cmdlet does.

    .DESCRIPTION
        A detailed description of what the cmdlet does.

    .PARAMETER inputPrompt
        Prompt to be sent to GPT
    
    .PARAMETER temperature
        The sampling temperature to use when generating text. Default is 0.0.

    .PARAMETER max_tokens
        The maximum number of tokens to generate. Default is 256.

    .PARAMETER Raw
        Don't show prompt for choice. Default is false.        

    .EXAMPLE
        git? 'compare this branch to master, just the files'

    #>
    [CmdletBinding()]    
    param(
        $inputPrompt,
        [ValidateRange(0, 2)]
        [decimal]$temperature = 0.0,
        # The maximum number of tokens to generate. default 256
        $max_tokens = 256,
        # Don't show prompt for choice
        [Switch]$Raw
    )

    $params = @{
        inputPrompt  = $inputPrompt
        SystemPrompt = 'you are an expert at using git command line, just code: '
        temperature  = $temperature
        max_tokens   = $max_tokens
        Raw          = $Raw
    }
    
    copilot @params
}

function gh? {
    <#
    .SYNOPSIS
        A brief description of what the cmdlet does.

    .DESCRIPTION
        A detailed description of what the cmdlet does.

    .PARAMETER inputPrompt
        Prompt to be sent to GPT

    .PARAMETER temperature
        The sampling temperature to use when generating text. Default is 0.0.

    .PARAMETER max_tokens
        The maximum number of tokens to generate. Default is 256.

    .PARAMETER Raw
        Don't show prompt for choice. Default is false.

    .EXAMPLE
        gh? 'list all closed PRs opened by dfinke and find the word fix' 

    .EXAMPLE
        gh? 'list issues on dfinke/importexcel'
    #>
    [CmdletBinding()]
    param(
        $inputPrompt,
        [ValidateRange(0, 2)]
        [decimal]$temperature = 0.0,
        # The maximum number of tokens to generate. default 256
        $max_tokens = 256,
        # Don't show prompt for choice
        [Switch]$Raw
    )

    $params = @{
        inputPrompt  = $inputPrompt
        SystemPrompt = '
1. You are an expert at using GitHub gh cli.
2. You are working with GitHub Repositories.
3. If no owner/repo, default to current dir.
4. Handle owner/repo correctly with --repo.
5. Map the prompt to the correct syntax of the gh cli.
6. Some commands require a flag, like --state
7. Handle pluralization to singular correctly for the gh cli syntax.
8. Handle removing spaces in the command and map to the correct syntax of the gh cli.
9. Do not provide an explanation or usage example.
10. Do not tell me about the command to use.
11. Just output the command:
        '
        temperature  = $temperature
        max_tokens   = $max_tokens
        Raw          = $Raw
    }
    
    copilot @params
}