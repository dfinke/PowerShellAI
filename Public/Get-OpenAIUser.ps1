function Get-OpenAIUser {
    <#
    .SYNOPSIS
    Get OpenAI User Information
    
    .DESCRIPTION
    Returns an overview of the user's OpenAI organization information

    .PARAMETER OrganizationId
    The Identifier for this organization sometimes used in API requests

    .EXAMPLE
    Get-OpenAIUser -OrganizationId 'org-IkLeiQaK1fZi6271T9u18jO5'
   
    .NOTES
    This function requires the 'OpenAIKey' environment variable to be defined before being invoked
    Reference: https://platform.openai.com/docs/models/overview
    Reference: https://platform.openai.com/docs/api-reference/models
	#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrganizationId
    ) 

    $url = '{0}/organizations/{1}/users' -f (Get-OpenAIBaseRestURI), $organizationId

    Invoke-OpenAIAPI $url
}