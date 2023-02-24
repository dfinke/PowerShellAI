function Invoke-OpenAIAPI {
    <#
    .SYNOPSIS
    Invoke the OpenAI API

    .DESCRIPTION
    Invoke the OpenAI API

    .PARAMETER Uri
    The URI to invoke

    .PARAMETER Method
    The HTTP method to use. Defaults to 'Get'

    .PARAMETER Body
    The body to send with the request

    .EXAMPLE
    Invoke-OpenAIAPI -Uri "https://api.openai.com/v1/images/generations" -Method Post -Body $body
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Uri,
        [ValidateSet('Default', 'Delete', 'Get', 'Head', 'Merge', 'Options', 'Patch', 'Post', 'Put', 'Trace')]
        $Method = 'Get',
        $Body
    )

    if (!(Test-OpenAIKey)) {
        throw 'Please set your OpenAI API key using Set-OpenAIKey or by configuring the $env:OpenAIKey environment variable. https://beta.openai.com/account/api-keys'
    }

    $params = @{
        Uri         = $Uri
        Method      = $Method
        Headers     = @{Authorization = 'Bearer {0}' -f (Get-OpenAIKey)}
        ContentType = 'application/json'
        body        = $Body
    }

    Invoke-RestMethod @params
}
