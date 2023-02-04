function Test-OpenAIKey {
    <#
        .SYNOPSIS
        Tests if the OpenAIKey environment variable is set.

        .EXAMPLE
        Test-OpenAIKey        
    #>
    -not [string]::IsNullOrEmpty($env:OpenAIKey)
}