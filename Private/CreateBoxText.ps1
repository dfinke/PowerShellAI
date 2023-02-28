Function CreateBoxText() {
    <#
        .SYNOPSIS
        Creates a box of text from a string array.

        .EXAMPLE
        $text = "This is a test`nof the emergency`nbroadcast system"
        $text | CreateBoxText
    #>
    Begin {
        $HorizontalBoxChar = [string][char]9552
        $VerticalBoxChar = [string][char]9553
        $TopLeftBoxChar = [string][char]9556
        $TopRightBoxChar = [string][char]9559
        $BottomLeftBoxChar = [string][char]9562
        $BottomRightBoxChar = [string][char]9565

        $lines = @()
        $lineCount = 0
        $maxLength = 0
    }

    Process {
        $item = $_.Trim()

        if (![string]::IsNullOrEmpty($item)) {
            if ($lineCount -eq 0) {
                $lines += 'Q: {0}' -f $item
            } else {
                $lines += '{0}: {1}' -f $lineCount, $item
            }

            $lineCount += 1

            if ($lines[-1].Length -gt $maxLength) {
                $maxLength = $lines[-1].Length
            }
        }
    }

    End {
        $horizontalBoxLine = $HorizontalBoxChar * ($maxLength + 2)
        '{0}{1}{2}' -f $TopLeftBoxChar, $horizontalBoxLine,  $TopRightBoxChar
        for ($i = 0; $i -lt $lineCount; $i += 1) {
            if ($i -eq 1) {
                '{0}{1}{2}' -f $VerticalBoxChar, $horizontalBoxLine, $VerticalBoxChar
            }
            '{0}{1}{2}{3}' -f $VerticalBoxChar, $lines[$i], (' ' * ($maxLength - $lines[$i].Length + 2)), $VerticalBoxChar
        }
        '{0}{1}{2}' -f $BottomLeftBoxChar, $horizontalBoxLine, $BottomRightBoxChar
    }
}
