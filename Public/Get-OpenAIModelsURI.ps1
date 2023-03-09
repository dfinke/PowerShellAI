function Get-OpenAIModelsURI {
    <#
        .SYNOPSIS
        Base url for OpenAI Models API.
    #>

    (Get-OpenAIBaseRestURI) + '/models'
}
