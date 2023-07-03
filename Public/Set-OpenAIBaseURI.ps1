function Set-OpenAIBaseURI {
    <#
        .SYNOPSIS
        Set the OpenAI base URI.

        .DESCRIPTION
        Set the OpenAI base URI.

        .PARAMETER Uri
        Specifies OpenAI base URI.
        .EXAMPLE
        Set-OpenAIBaseURI -Uri 'https://api.openai.com'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ if ($_.Length) { $true } else { throw 'OpenAI base URI cannot be empty.' } })]
        [ValidateNotNullOrEmpty()]
        [string] $Uri
    )

    if ($Uri[-1] -eq '/') {
        $Uri = $uri.SubString(0, $Uri.Length - 1)
    }
    $Script:OpenAIBaseUri = $Uri
}
