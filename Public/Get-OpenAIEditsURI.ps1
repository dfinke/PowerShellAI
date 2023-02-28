function Get-OpenAIEditsURI {
    <#
        .SYNOPSIS
        Base url for OpenAI Edits API.
    #>
    (Get-OpenAIBaseRestURI) + '/edits'
}
