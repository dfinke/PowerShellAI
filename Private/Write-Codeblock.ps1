$script:Themes = @{
    Github = @{
        Function = @{ R = 255; G = 123; B = 114 }
        Generic = @{ R = 199; G = 159; B = 252 }
        String = @{ R = 143; G = 185; B = 221 }
        Variable = @{ R = 255; G = 255; B = 255 }
        Identifier = @{ R = 110; G = 174; B = 231 }
        Number = @{ R = 255; G = 255; B = 255 }
        Keyword = @{ R = 255; G = 123; B = 114 }
        Default = @{ R = 200; G = 200; B = 200 }
        ForegroundRgb = @{ R = 102; G = 102; B = 102 }
        BackgroundRgb = @{ R = 35; G = 35; B = 35 }
        HighlightRgb = @{ R = 231; G = 72; B = 86 }
    }
    Matrix = @{
        Function = @{ R = 255; G = 255; B = 255 }
        Generic = @{ R = 113; G = 255; B = 96 }
        String = @{ R = 202; G = 255; B = 194 }
        Variable = @{ R = 200; G = 255; B = 200 }
        Identifier = @{ R = 131; G = 193; B = 26 }
        Number = @{ R = 255; G = 255; B = 255 }
        Keyword = @{ R = 40; G = 220; B = 20 }
        Default = @{ R = 0; G = 120; B = 0 }
        ForegroundRgb = @{ R = 102; G = 190; B = 102 }
        BackgroundRgb = @{ R = 15; G = 45; B = 15 }
        HighlightRgb = @{ R = 255; G = 221; B = 0 }
    }
}

function Write-Codeblock {
    <#
        .SYNOPSIS
            Writes a code block to the host.
            Intended for internal use only when you want to show a code block with some nicer formatting.

        .DESCRIPTION
            The Write-Codeblock function outputs a code block to the host console with optional line numbers,
            syntax highlighting, and line or extent highlighting. The function also supports custom foreground
            and background colors.

        .NOTES
            Author: Shaun Lawrie
            This was originally going to be using a screenbuffer but I wanted to support really long functions that may scroll the
            terminal so this streams the lines out from top to bottom which isn't the fastest way to render but it was the most
            reliable way I found to avoid mangling the code as it was being written out.
    #>
    param (
        # The text containing the code to write to the host
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
        [string] $Text,
        # Show a gutter with line numbers
        [switch] $ShowLineNumbers,
        # Syntax highlight the code block
        [switch] $SyntaxHighlight,
        # Extents to highlight in the code block
        [array] $HighlightExtents,
        # Lines to highlight in the code block
        [array] $HighlightLines,
        # The theme to use to render the code
        [ValidateSet("Github", "Matrix")]
        [string] $Theme = "Github"
    )

    # Fallback if the console host doesn't expose window dimensions, these are required for token highlighting
    if(!$Host.UI.RawUI.WindowSize.Width) {
        Write-Verbose "Could not write codeblock with syntax highlighting because this console host is not exposing window dimentsions."
        Write-Host -ForegroundColor Gray $Text
        return
    }

    $ForegroundRgb = $script:Themes[$Theme].ForegroundRgb
    $BackgroundRgb = $script:Themes[$Theme].BackgroundRgb

    # Work out the width of the console minus the line-number gutter
    $gutterSize = 0
    if($ShowLineNumbers) {
        $gutterSize = $Text.Split("`n").Count.ToString().Length + 1
    }
    $codeWidth = $Host.UI.RawUI.WindowSize.Width - $gutterSize

    try {
        [Console]::CursorVisible = $false
        
        $functionLineNumber = 1
        $resetEscapeCode = "$([Char]27)[0m"
        $foregroundColorEscapeCode = "$([Char]27)[38;2;{0};{1};{2}m" -f $ForegroundRgb.R, $ForegroundRgb.G, $ForegroundRgb.B
        $backgroundColorEscapeCode = "$([Char]27)[48;2;{0};{1};{2}m" -f $BackgroundRgb.R, $BackgroundRgb.G, $BackgroundRgb.B

        # Get all code tokens
        $tokens = @()
        [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref]$tokens, [ref]$null) | Out-Null
        $lineTokens = Expand-Tokens -Tokens $tokens | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Text) } | Group-Object { $_.Extent.StartLineNumber }
        $lineExtents = $HighlightExtents | Group-Object { $_.StartLineNumber }

        $functionLinesToRender = $Text.Split("`n")
        foreach($line in $functionLinesToRender) {
            $gutterText = ""
            if($ShowLineNumbers) {
                $gutterText = $functionLineNumber.ToString().PadLeft($gutterSize - 1) + " "
            }

            # Disable syntax highlighting for specifically highlighted lines
            $lineSyntax = $SyntaxHighlight
            $lineHighlight = $false
            if($HighlightLines -contains $functionLineNumber) {
                $lineSyntax = $false
                $lineHighlight = $true
            }

            # Work out the lines that will be wrapped in the terminal because they're too long and draw the background
            $lineBackground = $foregroundColorEscapeCode + $gutterText + $backgroundColorEscapeCode + (" " * $codeWidth) + $resetEscapeCode
            if($line.Length -gt $codeWidth) {
                # How many times can this line be wrapped in the code editor width available
                $wrappedLineSegments = ($line | Select-String -Pattern ".{1,$codeWidth}" -AllMatches).Matches.Value
                # Render the background line plus additional background lines without the gutter line number for each wrapped line
                $wrappedLinesBackground = (" " * $gutterSize) + $backgroundColorEscapeCode + (" " * $codeWidth) + $resetEscapeCode
                [Console]::WriteLine($lineBackground + ($wrappedLinesBackground * ($wrappedLineSegments.Count - 1)))
                # Correct terminal line position if the window scrolled
                $terminalLine = $Host.UI.RawUI.CursorPosition.Y - $wrappedLineSegments.Count
            } else {
                # Render the background
                [Console]::WriteLine($lineBackground)
                $terminalLine = $Host.UI.RawUI.CursorPosition.Y - 1
            }

            # Render the tokens that are on this line
            ($lineTokens | Where-Object { $_.Name -eq $functionLineNumber }).Group | ForEach-Object {
                if($null -ne $_) {
                    Write-Token -Token $_ -TerminalLine $terminalLine -BackgroundRgb $BackgroundRgb -GutterSize $gutterSize -Highlight:$lineHighlight -Theme $Theme -SyntaxHighlight:$lineSyntax
                }
            }

            # Highlight all extents on this line that have been requested to be emphasized
            ($lineExtents | Where-Object { $_.Name -eq $functionLineNumber }).Group | Foreach-Object {
                if($null -ne $_) {
                    Write-Token -Extent $_ -TerminalLine $terminalLine -BackgroundRgb $BackgroundRgb -GutterSize $gutterSize -Highlight -Theme $Theme
                }
            }

            $functionLineNumber++
        }
    } catch {
        throw $_
    } finally {
        [Console]::CursorVisible = $true
    }
}

function Expand-Tokens {
    <#
        .SYNOPSIS
            Split multiline tokens into "single line tokens" represented as hashtables.
        .DESCRIPTION
            Tokens can be multiline which makes rendering especially difficult when line wrapping of long tokens gets involved, it's
            easier to pre-split these multiline tokens into single line tokens before rendering them.
    #>
    param (
        [array] $Tokens
    )
    $splitTokens = @()
    if($null -eq $Tokens -or $Tokens.Count -eq 0) {
        return $splitTokens
    }
    foreach($token in $Tokens) {
        $tokenLines = $token.Text.Split("`n")
        $lineOffset = 0
        foreach($tokenLine in $tokenLines) {
            # If it's the first line this tokens column is not set to 1 it has its own x position
            $startColumnNumber = 1
            if($lineOffset -eq 0) {
                $startColumnNumber = $token.Extent.StartColumnNumber
            }
            $splitTokens += @{
                Text = $tokenLine
                Extent = @{
                    Text = $tokenLine
                    StartColumnNumber = $startColumnNumber
                    StartLineNumber = $token.Extent.StartLineNumber + $lineOffset
                }
                Kind = $token.Kind
                TokenFlags = $token.TokenFlags
                NestedTokens = @()
            }
            $lineOffset++
        }
        # Append nested tokens so they're expanded later than the parent and drawn overtop e.g. interpolated string variables
        $splitTokens += Expand-Tokens -Tokens $token.NestedTokens
    }
    return $splitTokens
}

function Get-TokenColor {
    <#
        .SYNOPSIS
            Given a syntax token provide a color based on its type.
    #>
    param (
        # The kind of token identified by the PowerShell language parser
        [System.Management.Automation.Language.TokenKind] $Kind,
        # TokenFlags identified by the PowerShell language parser
        [System.Management.Automation.Language.TokenFlags] $TokenFlags,
        # The theme to use to choose token colors
        [string] $Theme
    )
    $ForegroundRgb = switch -wildcard ($Kind) {
        "Function" { $script:Themes[$Theme].Function }
        "Generic" { $script:Themes[$Theme].Generic }
        "*String*" { $script:Themes[$Theme].String }
        "Variable" { $script:Themes[$Theme].Variable }
        "Identifier" { $script:Themes[$Theme].Identifier }
        "Number" { $script:Themes[$Theme].Number }
        default { $script:Themes[$Theme].Default }
    }
    if($TokenFlags -like "*operator*" -or $TokenFlags -like "*keyword*") {
        $ForegroundRgb = $script:Themes[$Theme].Keyword
    }
    return $ForegroundRgb
}

function Write-Token {
    <#
        .SYNOPSIS
            Writes colored text to the console at a specific token location.
    #>
    param (
        # The token to write, this can be a hashtable/object representing a (System.Management.Automation.Language.Token) or a real one, I'm faking it to deal with multiline tokens
        [object] $Token,
        # The text to write from an extent (System.Management.Automation.Language.InternalScriptExtent)
        [object] $Extent,
        # The terminal line to start rendering from
        [int] $TerminalLine,
        # Render the token with syntax highlighting
        [switch] $SyntaxHighlight,
        # Highlight this token in a bright overlay color for emphasis
        [switch] $Highlight,
        # The width of the gutter for this codeblock
        [int] $GutterSize,
        # The color theme to use
        [string] $Theme
    )

    $ForegroundRgb = $script:Themes[$Theme].ForegroundRgb
    $BackgroundRgb = $script:Themes[$Theme].BackgroundRgb

    if($Highlight) {
        $ForegroundRgb = $script:Themes[$Theme].HighlightRgb
    }

    if(!$Extent) {
        $Extent = $Token.Extent
    }

    $text = $Extent.Text
    $column = $Extent.StartColumnNumber

    $colorEscapeCode = ""
    if($SyntaxHighlight -and $null -ne $Token) {
        $ForegroundRgb = Get-TokenColor -Kind $Token.Kind -TokenFlags $Token.TokenFlags -Theme $Theme
    }
    $colorEscapeCode += "$([Char]27)[38;2;{0};{1};{2}m" -f $ForegroundRgb.R, $ForegroundRgb.G, $ForegroundRgb.B
    if($BackgroundRgb) {
        $colorEscapeCode += "$([Char]27)[48;2;{0};{1};{2}m" -f $BackgroundRgb.R, $BackgroundRgb.G, $BackgroundRgb.B
    }

    $consoleWidth = $Host.UI.RawUI.WindowSize.Width - $GutterSize
    
    try {
        $initialCursorSetting = [Console]::CursorVisible
    } catch {
        $initialCursorSetting = $true
    }
    $initialCursorPosition = $Host.UI.RawUI.CursorPosition
    [Console]::CursorVisible = $false
    try {
        $textToRender = @()
        # Overruns are parts of this extent that extend beyond the width of the terminal and need their own line wrapping
        $overrunText = @()
        # This extent might be on a wrapped part of this line, make sure to find the correct start point
        $columnIndex = $Column - 1
        $wrappedLineIndex = [Math]::Floor($columnIndex / $consoleWidth)
        $x = ($columnIndex % $consoleWidth) + $GutterSize
        $y = $wrappedLineIndex
        # Handle extent running beyond the width of the terminal
        if(($x + $text.Length) -gt ($consoleWidth + $GutterSize)) {
            $fullExtentLine = $text
            $endOfTextOnCurrentLine = $consoleWidth - $x + $GutterSize
            $text = $text.Substring(0, $endOfTextOnCurrentLine)
            $remainingText = $fullExtentLine.Substring($endOfTextOnCurrentLine, $fullExtentLine.Length - $endOfTextOnCurrentLine)
            if($remainingText.Length -gt $consoleWidth) {
                $overrunText += ($remainingText | Select-String "(.{1,$consoleWidth})+").Matches.Groups[1].Captures.Value
            } else {
                $overrunText += $remainingText
            }
        }

        $textToRender += @{
            Text = $text
            X = $x
            Y = $y
        }

        # Prepare any parts of this line that extended beyond the width of the terminal
        $overruns = 0
        foreach($overrun in $overrunText) {
            $overruns++
            $textToRender += @{
                Text = $overrun
                X = $GutterSize
                Y = $y + $overruns
            }
        }

        $textToRender | Foreach-Object {
            [Console]::SetCursorPosition($_.X, $TerminalLine + $_.Y)
            [Console]::Write($colorEscapeCode + $_.Text + "$([Char]27)[0m")
        }
    } catch {
        throw $_
    } finally {
        [Console]::CursorVisible = $initialCursorSetting
        [Console]::SetCursorPosition($initialCursorPosition.X, $initialCursorPosition.Y)
    }
}