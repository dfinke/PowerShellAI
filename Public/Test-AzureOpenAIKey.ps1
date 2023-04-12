function Test-AzureOpenAIKey {
    <#
        .SYNOPSIS
        Tests if the OpenAIKey module scope variable or environment variable is set.

        .EXAMPLE
        Test-OpenAIKey
    #>
    -not [string]::IsNullOrEmpty($env:AzureOpenAIKey)
}
