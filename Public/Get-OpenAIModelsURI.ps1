function Get-OpenAIModelsURI {
    <#
        .Synopsis
        Base url for OpenAI Models API
        .DESCRIPTION
        Gets the base URI for the OpenAI models API.
        .EXAMPLE
        Get-OpenAIModelsURI
        .LINK
        https://platform.openai.com/docs/models/overview
    #>
    
    (Get-OpenAIBaseRestURI) + '/models'
}