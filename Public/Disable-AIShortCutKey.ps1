function Disable-AIShortCutKey {
    <#
        .SYNOPSIS
        Disable the Ctrl+g shortcut key for getting completions.

        .EXAMPLE
        Disable-AIShortCutKey
    #>

    Remove-PSReadLineKeyHandler -Chord Ctrl+g
}
