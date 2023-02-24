function Get-OpenAIModelsURI {
    <#
        .Synopsis
        Base url for OpenAI Models API
    #>

    (Get-OpenAIBaseRestURI) + '/models'
}
