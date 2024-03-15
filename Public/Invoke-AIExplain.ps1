function Invoke-AIExplain {
    <#
        .SYNOPSIS
            Explain the last command or a command by id
        .DESCRIPTION
            Invoke-AIExplain is a function that uses the OpenAI GPT-3 API to provide explain the last command or a command by id.
        .EXAMPLE
            explain
        .EXAMPLE
            explain 10 # where 10 is the id of the command in the history
        .EXAMPLE
            explain 10 13 # the start and end id of the commands in the history
        .EXAMPLE
            explain -Value "Get-Process"
    #>
    [CmdletBinding()]
    [alias("explain")]
    param(
        $Id,
        $IdEnd,
        $Value,
        $max_tokens = 300
    )
 
    if ($Id -and $IdEnd) {
        foreach ($targetId in ($Id..$IdEnd)) {
            $cli += (Get-History -Id $targetId).CommandLine + "`r`n"
        }
    }
    elseif ($Value) {
        $cli = $Value
    }
    elseif ($Id) {
        $cli = (Get-History -Id $Id).CommandLine
    }
    else {
        $cli = (Get-History | Select-Object -last 1).CommandLine 
    }
        
    write-host $cli 
    $prompt = 'You are running powershell on ' + $PSVersionTable.Platform
    $prompt += " Please explain the following: "
    
    # Dynamically determine which OpenAI service is being used
    $provider = $null    
    $provider = Get-ChatAPIProvider
    switch ($provider.tolower()) {
        openai { $result = $cli | ai $prompt -max_tokens $max_tokens }
        azureopenai {
            $prompt += $cli 
            $result = Get-GPT4Completion -Content $prompt -max_tokens $max_tokens 
        }
        Default { $result = $cli | ai $prompt -max_tokens $max_tokens }
    }
    
    Write-Codeblock -Text $cli -SyntaxHighlight
    $result
}