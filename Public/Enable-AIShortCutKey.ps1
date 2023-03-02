function Enable-AIShortCutKey {
    <#
        .SYNOPSIS
            Enable a shortcut key for getting completions
        .DESCRIPTION
            Enables a shortcut key for getting completions.

            The -ShortcutKey can be customized.

            If not in Visual Studio Code, the ShortcutKey will default to 'CTRL+G'
            In Visual Studio Code, the ShortcutKey will default to 'ALT+G'
        .EXAMPLE
            # Enables the shortcut key.  Outside of VSCode, CTRL+G.  Inside of VSCode, ALT+G.
            Enable-AIShortCutKey
        .EXAMPLE
            Enable-AIShortCutKey -ShortcutKey "CTRL+ALT+P"
    #>
    param(
    [string]
    $ShortcutKey = $(
        # In Visual Studio Code, CTRL+G is "goto",
        if ((Get-Process -id $pid).Parent.ProcessName -eq 'code') {
            "ALT+G" # so we'll use ALT+G by default.
        } else {
            "CTRL+G" # If we're not running in code, use CTRL+G by default
        }
    )
    )

    Set-PSReadLineKeyHandler -Key $ShortcutKey `
        -BriefDescription OpenAICli `
        -LongDescription "Calls Open AI on the current buffer" `
        -ScriptBlock {
        param($key, $arg)

            try {
                $line = $null
                $cursor = $null

                [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

                $prompt = "Using PowerShell, just code: $line"

                $output = (Get-GPT3Completion -prompt $prompt -max_tokens 256 -ErrorAction Stop).Trim()

                # check if output is not null
                if ($null -ne $output) {
                    foreach ($str in $output) {
                        if ($null -ne $str -and $str -ne '') {
                            [Microsoft.PowerShell.PSConsoleReadLine]::AddLine()
                            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($str)
                        }
                    }
                }
            } catch {
                throw $_
            }
        }
    }
    Set-PSReadLineKeyHandler @splatParams
}
