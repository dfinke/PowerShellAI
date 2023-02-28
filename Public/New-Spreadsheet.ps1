function New-SpreadSheet {
    <#
    .SYNOPSIS
    Creates a new spreadsheet from a prompt.

    .DESCRIPTION
    Creates a new spreadsheet from a prompt.

    .PARAMETER prompt
    The prompt to use.

    .PARAMETER Raw
    If set, returns the raw markdown table instead of converting it to an Excel spreadsheet.

    .EXAMPLE
    New-Spreadsheet "first 5 US presidents name, term, party".

    .EXAMPLE
    New-Spreadsheet "first 5 US presidents name, term, party" -Raw
    #>
    param(
        [Parameter(Mandatory)]
        $prompt,
        [Switch]$Raw
    )

    try {
        # Test if ImportExcel is installed
        if (!(Get-Module -Name ImportExcel -ListAvailable)) {
            throw "ImportExcel is not installed. Please install it with 'Install-Module ImportExcel'"
        }

        $result = ai "A spreadsheet of: $($prompt)" -ErrorAction Stop

        if ($Raw) {
            return $result
        } else {
            $result | ConvertFrom-GPTMarkdownTable | Export-Excel
        }
    } catch {
        Write-Error -ErrorRecord $_ -ErrorAction $ErrorActionPreference
    }
}
