function Get-OpenAIModel {
    <#
    .SYNOPSIS
    Get a list of current OpenAI GPT-3 API models.

    .DESCRIPTION
    Returns full model properties, or just the names (id values).

    .PARAMETER Name
    The name of the model to return - wildcards are supported.

    .PARAMETER Raw
    Returns the raw JSON response from the API.

    .EXAMPLE
    Get-OpenAIModel

    .EXAMPLE
    Get-OpenAIModel -Raw

    .NOTES
	Before calling this function the OpenAI key must be set with Set-OpenAIKey function or with the 'OpenAIKey' environment variable.
    Reference: https://platform.openai.com/docs/models/overview
    Reference: https://platform.openai.com/docs/api-reference/models
	#>
    [CmdletBinding()]
    param(
        $Name,
        [Switch]$Raw
    )

    try {
        $splatParams = @{
            Uri         = $Script:OpenAIModelsURI
            ErrorAction = 'Stop'
        }
        $response = Invoke-OpenAIAPI @splatParams

        if ($Raw) {
            $response
        } else {
            if (!$Name) { $Name = '*' }

            $response.data.id | Where-Object { $_ -like $Name }
        }
    } catch {
        Write-Error -ErrorRecord $_ -ErrorAction $ErrorActionPreference
    }
}
