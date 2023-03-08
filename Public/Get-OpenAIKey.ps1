function Get-OpenAIKey {
    <#
    .SYNOPSIS
    Get a list of OpenAI Keys
    
    .DESCRIPTION
    Returns a list of OpenAI Keys
    
    .EXAMPLE
    Get-OpenAIKey    
   
    .NOTES
    This function requires the 'OpenAIKey' environment variable to be defined before being invoked
    Reference: https://platform.openai.com/docs/models/overview
    Reference: https://platform.openai.com/docs/api-reference/models
	#>
    
    $uri = 'https://api.openai.com/dashboard/user/api_keys'

    Invoke-OpenAIAPI -Uri $uri
}