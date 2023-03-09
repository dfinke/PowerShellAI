function Get-OpenAIKey {
    <#
        .SYNOPSIS
        Gets the OpenAI key from module scope variable or environment variable.

        .DESCRIPTION
        The Get-OpenAIKey gets an OpenAI key from module scope variable or environment variable.
        The key set with Set-OpenAIKey has precedence over $env:OpenAIKey.

        Return value type is:
        [String]       - when running on PowerShell 5 and lower, or when using environment variable ($env:OpenAIKey) to store the OpenAI key
        [SecureString] - when running on PowerShell 6 and higher, and when OpenAI key was set with Set-OpenAIKey function

        .EXAMPLE
        Get-OpenAIKey
    #>
    if ($null -ne $Script:OpenAIKey) {
        if ($PSVersionTable.PSVersion.Major -gt 5) {
            #On PowerShell 6 and higher return secure string because Invoke-RestMethod supports Bearer authentication with secure Token
            $Script:OpenAIKey
        } else {
            #On PowerShell 5 and lower use .NET marshaling to convert the secure string to plain text
            [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Script:OpenAIKey)
            )
        }
    } else {
        $env:OpenAIKey
    }
}
