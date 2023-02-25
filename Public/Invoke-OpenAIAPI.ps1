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
        throw 'Please set your OpenAI API key using Set-OpenAIKey or by configuring the $env:OpenAIKey environment variable (https://beta.openai.com/account/api-keys)'
    }

    $params = @{
        Uri         = $Uri
        Method      = $Method
        ContentType = 'application/json'
        body        = $Body
    }

    if (($apiKey = Get-OpenAIKey) -is [SecureString]) {
        #On PowerShell 6 and higher use Invoke-RestMethod with Authentication parameter and secure Token
        $params['Authentication'] = 'Bearer'
        $params['Token'] = $apiKey
    } else {
        #On PowerShell 5 and lower, or when using the $env:OpenAIKey environment variable, use Invoke-RestMethod with plain text header
        $params['Headers'] = @{Authorization = "Bearer $apiKey"}
    }

    Invoke-RestMethod @params
}
