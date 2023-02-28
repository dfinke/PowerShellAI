function Get-OpenAICompletionsURI {
    <#
        .Synopsis
        Base url for OpenAI Completions API
        .Description
        Gets the base URI for the OpenAI Completions.
        .EXAMPLE
        Get-OpenAICompletionsURI
        .LINK
        Get-OpenAIBaseRestURI   
    #>
    
    (Get-OpenAIBaseRestURI) + '/completions'
}