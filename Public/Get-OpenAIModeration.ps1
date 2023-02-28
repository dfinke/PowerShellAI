function Get-OpenAIModeration {
    <#
    .SYNOPSIS
    Checks if prompt contains wording that violates OpenAI moderation rules
    
    .DESCRIPTION
    Checks prompt text content against latest moderation rules to determine if
    any OpenAI moderation rules would be violated.
    
    .PARAMETER InputText
    Prompt text to evaluate

    .PARAMETER Raw
    Returns the raw JSON response from the API
    
    .EXAMPLE
    Get-OpenAIModeration -InputText "I want to kill them."
    
    .NOTES
    This function requires the 'OpenAIKey' environment variable to be defined before being invoked
    Reference: https://platform.openai.com/docs/guides/moderation/quickstart
    Reference: https://platform.openai.com/docs/api-reference/moderations/create
	#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $InputText,
        [Switch]$Raw
    )

    $body = @{
        "input" = $InputText
    } | ConvertTo-Json

    $response = Invoke-OpenAIAPI -Uri (Get-OpenAIModerationsURI) -Body $body -Method POST

    if ($Raw) {
        $response
    }
    else {
        $response.results.categories
    }
}