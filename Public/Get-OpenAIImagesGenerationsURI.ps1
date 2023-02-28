
function Get-OpenAIImagesGenerationsURI {
    <#
        .Synopsis
        Base url for OpenAI Images Generations API
        .DESCRIPTION
        Gets the base URI for the OpenAI image generations.
        .EXAMPLE
        Get-OpenAIImagesGenerationsURI
        .LINK
        Get-OpenAIBaseRestURI
    #>
    
    (Get-OpenAIBaseRestURI) + '/images/generations'
}