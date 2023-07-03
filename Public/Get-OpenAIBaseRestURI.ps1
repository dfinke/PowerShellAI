function Get-OpenAIBaseRestURI {
    <#
        .Synopsis
        Base url for OpenAIBase API

        .Example
        Invoke-OpenAIAPI ((Get-GHBaseRestURI)+'/models')
    #>

    "$(Get-OpenAIBaseURI)/v1"
}
