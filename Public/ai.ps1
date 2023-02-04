function ai {
    <#
        .SYNOPSIS
        This is **Experimental** AI function
        .DESCRIPTION
        AI function that you can pipe all sorts of things into and get back a completion

        .EXAMPLE
        ai "list of planets only names as json" |
        .EXAMPLE
        ai "list of planets only names as json" | ai 'convert to  xml' 
        .EXAMPLE
        ai "list of planets only names as json" | ai 'convert to  xml' | ai 'convert to  powershell'
        .EXAMPLE
        git status | ai "create a detailed git message"
    #>
    param(
        $inputPrompt,
        [Parameter(ValueFromPipeline = $true)]
        $pipelineInput,
        $max_tokens = 256
    )

    Begin {
        [System.Collections.ArrayList]$lines = @()
    }

    Process {
        $lines += $pipelineInput
    }

    End {
        $fullPrompt = @"
$($inputPrompt)
$(($lines | Out-String).Trim())

"@
        
        Get-GPT3Completion -prompt $fullPrompt.Trim() -max_tokens $max_tokens
    }
}
