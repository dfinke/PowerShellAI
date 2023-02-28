function Get-OpenAIModeration {
    <#
    .SYNOPSIS
    Checks if prompt contains wording that violates OpenAI moderation rules.

    .DESCRIPTION
    Checks prompt text content against latest moderation rules to determine if
    any OpenAI moderation rules would be violated.

    .PARAMETER InputText
    Prompt text to evaluate.

    .PARAMETER Raw
    Returns the raw JSON response from the API.

    .EXAMPLE
    Get-OpenAIModeration -InputText "I want to kill them."

    .NOTES
	Before calling this function the OpenAI key must be set with Set-OpenAIKey function or with the 'OpenAIKey' environment variable.
    Reference: https://platform.openai.com/docs/guides/moderation/quickstart
    Reference: https://platform.openai.com/docs/api-reference/moderations/create
	#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $InputText,
        [Switch]$Raw
    )

    try {
        $body = @{
            "input" = $InputText
        } | ConvertTo-Json -Compress

        $response = Invoke-OpenAIAPI -Uri (Get-OpenAIModerationsURI) -Body $body -Method Post -ErrorAction Stop

        if ($Raw) {
            $response
        } else {
            $response.results.categories
        }
    } catch {
        Write-Error -ErrorRecord $_ -ErrorAction $ErrorActionPreference
    }
}