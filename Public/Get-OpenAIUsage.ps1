function Get-OpenAIUsage {
    <#
    .SYNOPSIS
    Get a summary of OpenAI API usage
    
    .DESCRIPTION
    Returns a summary of OpenAI API usage for your organization. All dates and times are UTC-based, and data may be delayed up to 5 minutes.

    .PARAMETER StartDate
    The Start Date of the usage period to return in YYYY-MM-DD format

    .PARAMETER EndDate
    The End Date of the usage period to return in YYYY-MM-DD format
    
    .EXAMPLE
    Get-OpenAIUsage -StartDate '2023-03-01' -EndDate '2023-03-31'
   
    .NOTES
    This function requires the 'OpenAIKey' environment variable to be defined before being invoked
    Reference: https://platform.openai.com/docs/models/overview
    Reference: https://platform.openai.com/docs/api-reference/models
	#>

    [CmdletBinding()]
    param(
        [datetime]$StartDate = (Get-Date).AddDays(-1),
        [datetime]$EndDate = (Get-Date),
        [Switch]$OnlyLineItems
    )
 
    $url = 'https://api.openai.com/dashboard/billing/usage?end_date={0}&start_date={1}' -f $($endDate.toString("yyyy-MM-dd")), $($startDate.ToString("yyyy-MM-dd"))

    $result = Invoke-OpenAIAPI $url | 
    Add-Member -PassThru -MemberType NoteProperty -Name StartDate -Value $StartDate.ToShortDateString() -Force |
    Add-Member -PassThru -MemberType NoteProperty -Name EndDate -Value $EndDate.ToShortDateString() -Force
    
    #(get-openaiusage 3/1).daily_costs.line_items | sort name
    if ($OnlyLineItems) {
        $result.daily_costs.line_items | Sort-Object name
    }
    else {
        $result
    }
}