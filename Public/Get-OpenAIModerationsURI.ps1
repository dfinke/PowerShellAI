function Get-OpenAIModerationsURI {
    <#
        .Synopsis
        Base url for OpenAI Moderations API
        .DESCRIPTION
        Gets the base URI for the OpenAI moderations API.
        .EXAMPLE
        Get-OpenAIModelsURI
    #>
    
    (Get-OpenAIBaseRestURI) + '/moderations'
}