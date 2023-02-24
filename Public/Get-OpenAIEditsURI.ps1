function Get-OpenAIEditsURI {
    <#
        .Synopsis
        Base url for OpenAI Edits API
    #>
    (Get-OpenAIBaseRestURI) + '/edits'
}
