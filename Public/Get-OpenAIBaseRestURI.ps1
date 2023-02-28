function Get-OpenAIBaseRestURI {
    <#
        .SYNOPSIS
        Base url for OpenAIBase API.

        .EXAMPLE
        Invoke-OpenAIAPI ((Get-GHBaseRestURI)+'/models')
    #>

    'https://api.openai.com/v1'
}
