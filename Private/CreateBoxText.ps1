Function CreateBoxText() {
    <#
        .SYNOPSIS
        Creates a box of text from a string array

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
            If ($lineCount -eq 0) {
                $lines += "Q: " + $item
            }
            else {
                $lines += "{0}: {1}" -f $lineCount, $item
            }
            
            $lineCount += 1
            
            if ($lines[-1].Length -gt $maxLength) {
                $maxLength = $lines[-1].Length
            }
        }
    }

    End {
        $TopLeftBoxChar + ($HorizontalBoxChar * ($maxLength + 2)) + $TopRightBoxChar
        For ($i = 0; $i -lt $lineCount; $i += 1) {
            if ($i -eq 1) {
                $VerticalBoxChar + ($HorizontalBoxChar * ($maxLength + 2)) + $VerticalBoxChar
            }

            $VerticalBoxChar + $lines[$i] + (" " * ($maxLength - $lines[$i].Length + 2)) + $VerticalBoxChar
        }
        $BottomLeftBoxChar + ($HorizontalBoxChar * ($maxLength + 2)) + $BottomRightBoxChar
    }   
}