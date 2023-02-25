function Get-OpenAIKey {
    <#
        .SYNOPSIS
        Gets the OpenAIKey module scope variable or environment variable.

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
