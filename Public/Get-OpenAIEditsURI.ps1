function Get-OpenAIEditsURI {
    <#
        .Synopsis
        Base url for OpenAI Edits API
        .DESCRIPTION
        Gets the base URI for the OpenAI Edits.
        .EXAMPLE
        Get-OpenAIEditsURI
        .LINK
        Get-OpenAIBaseRestURI
    #>
    (Get-OpenAIBaseRestURI) + '/edits'
}