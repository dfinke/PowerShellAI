function Disable-AIShortCutKey {
    <#
        .SYNOPSIS
            Disable the shortcut key for getting completions.
        .DESCRIPTION
            Disable the shortcut key for completing suggestions.
        .EXAMPLE
            Disable-AIShortCutKey
        .LINK
            Enable-AIShortCutKey
    #>

    $chordsToRemove = Get-PSReadLineKeyHandler |
        Where-Object Function -eq OpenAICli |
        Select-Object -ExpandProperty Key

    foreach ($chordToRemove in $chordsToRemove) {
        Remove-PSReadLineKeyHandler -Chord $chordToRemove
    }
}
