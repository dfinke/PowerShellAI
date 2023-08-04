#Requires -Modules @{ ModuleName="PowerShellAI"; ModuleVersion="0.7.9" }, ImportExcel

function Invoke-ExcelTemplate {

    <#
    .SYNOPSIS
        Generates an Excel spreadsheet based on a given query.

    .DESCRIPTION
        The Invoke-ExcelTemplate function generates an Excel spreadsheet based on a given query. The function takes a single parameter, $q, which represents the query to be used for generating the spreadsheet.

    .PARAMETER q
        The query to be used for generating the spreadsheet.

    .EXAMPLE
        Invoke-ExcelTemplate -q 'Agenda for a one day sales kick off event with time, session descriptions, presenter, location, status.'

        This example generates an Excel spreadsheet with an agenda for a one day sales kick off event, including time, session descriptions, presenter, location, and status.

    .EXAMPLE
        Invoke-ExcelTemplate -q 'Agenda for a one day sales kick off event with session descriptions and status.'

        This example generates an Excel spreadsheet with an agenda for a one day sales kick off event, including session descriptions and status.
    #>

    param(
        [Parameter(Mandatory)]
        $q
    )

    $messages = @(
        New-ChatMessageTemplate system '
    You are an expert at creating Excel spreadsheets for everything.
    Output only in markdown tableformat.
    '
    )
 
    Set-ChatSessionOption -max_tokens 1024

    $messages += New-ChatMessageTemplate user $q

    (Get-CompletionFromMessages $messages).content | ConvertFrom-GPTMarkdownTable | Export-Excel
}