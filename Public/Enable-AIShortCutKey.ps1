function Enable-AIShortCutKey {
    <#
        .SYNOPSIS
        Enable the Ctrl+g shortcut key for getting completions.

        .EXAMPLE
        Enable-AIShortCutKey
    #>
    $splatParams = @{
        Key                 = 'Ctrl+g'
        BriefDescription    = 'OpenAICli'
        LongDescription     = 'Calls Open AI on the current buffer'
        ScriptBlock         = {
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
