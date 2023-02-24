function Get-OpenAICompletionsURI {
    <#
        .Synopsis
        Base url for OpenAI Completions API
    #>

    (Get-OpenAIBaseRestURI) + '/completions'
}
