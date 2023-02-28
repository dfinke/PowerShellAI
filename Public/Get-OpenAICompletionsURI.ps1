function Get-OpenAICompletionsURI {
    <#
        .SYNOPSIS
        Base url for OpenAI Completions API.
    #>

    (Get-OpenAIBaseRestURI) + '/completions'
}
