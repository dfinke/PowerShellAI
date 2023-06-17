function Get-OpenAIBaseRestURI {
    <#
        .Synopsis
        Base url for OpenAIBase API

        .Example
        Invoke-OpenAIAPI ((Get-GHBaseRestURI)+'/models')
    #>

    "${Script:OpenAIBaseUri}/v1"
}
