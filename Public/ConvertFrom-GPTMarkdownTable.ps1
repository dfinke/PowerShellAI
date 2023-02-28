function ConvertFrom-GPTMarkdownTable {
    <#
    .SYNOPSIS
        Converts a markdown table to a PowerShell object.

    .PARAMETER Markdown
        The markdown table to convert.
    .EXAMPLE
        ConvertFrom-GPTMarkdownTable -Markdown @'
| Name | Value |
| ---- | ----- |
| foo  | bar   |
| baz  | qux   |
'@

    .EXAMPLE
        ai 'markdown table syntax' | ConvertFrom-GPTMarkdownTable
    #>
    param(
        [Parameter(ValueFromPipeline)]
        $Markdown
    )

    End {
        try {
            $lines = $Markdown.Trim().Split("`n")

            @(
                foreach ($line in $lines) {
                    if ($line -match '[A-Za-z0-9]') {
                        $line.Trim() -replace '^\|', ''
                    }
                }
            ) | ConvertFrom-Csv -Delimiter '|'
        } catch {
            Write-Error -ErrorRecord $_ -ErrorAction $ErrorActionPreference
        }
    }
}
