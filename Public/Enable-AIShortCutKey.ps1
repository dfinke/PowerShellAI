function Enable-AIShortCutKey {
    <#
        .SYNOPSIS
        Enable the Ctrl+g shortcut key for getting completions
        .DESCRIPTION
        Running this command will make 'CTRL+G' convert a prompt suggestion into code you could run.
        .LINK
        Disable-AIShortcutKey
        .EXAMPLE
        Enable-AIShortCutKey
    #>
    Set-PSReadLineKeyHandler -Key Ctrl+g `
        -BriefDescription OpenAICli `
        -LongDescription "Calls Open AI on the current buffer" `
        -ScriptBlock {
        param($key, $arg)

        $line = $null
        $cursor = $null

        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

        $prompt = "Using PowerShell, just code: $($line)"

        $output = Get-GPT3Completion $prompt -max_tokens 256 
        $output = $output -replace "`r", ""

        # check if output is not null
        if ($null -ne $output) {        
            foreach ($str in $output) {
                if ($null -ne $str -and $str -ne "") {
                    [Microsoft.PowerShell.PSConsoleReadLine]::AddLine()
                    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($str)
                }
            }
        }
    }
}