function Get-OpenAIModel {
    <#
    .SYNOPSIS
    Get a list of current OpenAI GPT-3 API models

    .DESCRIPTION
    Returns full model properties, or just the names (id values)

    .PARAMETER Name
    The name of the model to return - wildcards are supported

    .PARAMETER Raw
    Returns the raw JSON response from the API

    .EXAMPLE
    Get-OpenAIModel

    .EXAMPLE
    Get-OpenAIModel -Raw

    .NOTES
    This function requires the 'OpenAIKey' environment variable to be defined before being invoked
    Reference: https://platform.openai.com/docs/models/overview
    Reference: https://platform.openai.com/docs/api-reference/models
	#>
    [CmdletBinding()]
    param(
        $Name,
        [Switch]$Raw
    )

    $response = Invoke-OpenAIAPI -Uri (Get-OpenAIModelsURI)

    if ($Raw) {
        $response
    }
    else {
        if (!$Name) { $Name = '*' }

        $response.data.id | Where-Object { $_ -like $Name }
    }
}
