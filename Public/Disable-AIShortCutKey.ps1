function Disable-AIShortCutKey {
    <#
        .SYNOPSIS
        Disable the Ctrl+g shortcut key for getting completions
        .DESCRIPTION
        Disables CTRL+G as the shortcut key for completing code.
        .LINK
        Enable-AIShortcutKey
        .EXAMPLE
        Disable-AIShortCutKey
    #>

    Remove-PSReadLineKeyHandler -Chord Ctrl+g 
}