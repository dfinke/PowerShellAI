function Get-LocalOpenAIKey {
    <#
        .SYNOPSIS
        Gets the OpenAIKey module scope variable or environment variable.

        .EXAMPLE
        Get-LocalOpenAIKey
    #>
    if ($null -ne $Script:OpenAIKey) {
        if ($PSVersionTable.PSVersion.Major -gt 5) {
            #On PowerShell 6 and higher return secure string because Invoke-RestMethod supports Bearer authentication with secure Token
            $Script:OpenAIKey
        } else {
            #On PowerShell 5 and lower use .NET marshalling to convert the secure string to plain text
            [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Script:OpenAIKey)
            )
        }
    } elseif (Test-Path Env:\OpenAIKey) {
        $env:OpenAIKey
    } else {
        # https://help.openai.com/en/articles/5112595-best-practices-for-api-key-safety
        $env:OPEN_AI_KEY
    }
}
