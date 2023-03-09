function Set-OpenAIKey {
    <#
        .SYNOPSIS
        Set the OpenAI API key.

        .DESCRIPTION
        Sets the OpenAI API key using secure string.

        .PARAMETER Key
        Specifies OpenAI API key secure string.
        .EXAMPLE
        Set-OpenAIKey -Key (Get-Secret -Name MyOpenAIKey)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({if ($_.Length) {$true} else {throw 'OpenAIKey cannot be empty.'}})]
        [ValidateNotNullOrEmpty()]
        [Security.SecureString]
        $Key
    )

    $Script:OpenAIKey = $Key
}
