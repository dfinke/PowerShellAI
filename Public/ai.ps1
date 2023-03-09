function ai {
    <#
        .SYNOPSIS
        This is **Experimental** AI function.

        .DESCRIPTION
        AI function that you can pipe all sorts of things into and get back a completion.

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
        [ValidateRange(0,2)]
        [decimal]$temperature = 0.0,
        $max_tokens = 256
    )

    Begin {
        [Collections.ArrayList]$lines = @()
    }

    Process {
        $lines += $pipelineInput
    }

    End {
        try {
            $fullPrompt = @"
$($inputPrompt):
$($lines | Out-String)
"@
            $splatParams = @{
                prompt      = $fullPrompt.Trim()
                max_tokens  = $max_tokens
                temperature = $temperature
                ErrorAction = 'Stop'
            }
            (Get-GPT3Completion @splatParams).Trim()
        } catch {
            Write-Error -ErrorRecord $_ -ErrorAction $ErrorActionPreference
        }
    }
}
