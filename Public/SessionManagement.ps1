$Script:timeStamp
$Script:chatSessionPath

function Get-ChatSessionTimeStamp {
    <#
        .SYNOPSIS
            Get chat session time stamp
        .DESCRIPTION
            Get chat session time stamp, if not set, set it to current time
        .EXAMPLE
            Get-ChatSessionTimeStamp
    #>
    [CmdletBinding()]
    param ()

    if ($null -eq $Script:timeStamp) {
        $Script:timeStamp = (Get-Date).ToString("yyyyMMddHHmmss")
    }

    $Script:timeStamp
}

function Reset-ChatSessionTimeStamp {
    <#
        .SYNOPSIS
            Reset chat session time stamp
        .DESCRIPTION
            Reset chat session time stamp to $null
        .EXAMPLE
            Reset-ChatSessionTimeStamp
    #>
    [CmdletBinding()]
    param ()

    $Script:timeStamp = $null
}

function Reset-ChatSessionPath {
    <#
        .SYNOPSIS
            Reset chat session path
        .DESCRIPTION
            Reset chat session path to default value
        .EXAMPLE
            Reset-ChatSessionPath
    #>
    [CmdletBinding()]
    param ()

    if ($PSVersionTable.PSVersion.Major -gt 5 -and ($IsLinux -or $IsMacOS)) {
        $Script:chatSessionPath = Join-Path $env:HOME '~/PowerShellAI/ChatGPT'
    }
    elseif ($env:APPDATA) {
        $Script:chatSessionPath = Join-Path $env:APPDATA 'PowerShellAI/ChatGPT'
    }

}

function Get-ChatSessionPath {
    <#
        .SYNOPSIS
            Get chat session path
        .DESCRIPTION
            Get chat session path, if not set, set it to default value
        .EXAMPLE
            Get-ChatSessionPath
    #>
    [CmdletBinding()]
    param ()

    if ($null -eq $Script:chatSessionPath) {
        Reset-ChatSessionPath
    }

    $Script:chatSessionPath
}

function Set-ChatSessionPath {
    <#
        .SYNOPSIS
            Set chat session path
        .PARAMETER Path
            Path of the chat session
        .EXAMPLE
            Set-ChatSessionPath -Path 'C:\Users\user\Documents\PowerShellAI\ChatGPT'
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Path
    )

    $Script:chatSessionPath = $Path
}

function Get-ChatSessionFile {
    <#
        .SYNOPSIS
            Get chat session file
        .DESCRIPTION
            Get chat session file from current time
        .PARAMETER timeStamp
            Time stamp of the chat session file
        .EXAMPLE
            Get-ChatSessionFile
    #>
    [CmdletBinding()]
    param (
        $timeStamp
    )

    if (-not $timeStamp) {
        $timeStamp = Get-ChatSessionTimeStamp
    }

    Join-Path (Get-ChatSessionPath) ("{0}-ChatGPTSession.xml" -f $timeStamp)
}

function Get-ChatSession {
    <#
        .SYNOPSIS
            Get chat session files
        .DESCRIPTION
            Get chat session files from all time
        .PARAMETER Name
            Name of the chat session file, can be a regular expression
        .EXAMPLE
            Get-ChatSession
        .EXAMPLE
            Get-ChatSession -Name '20200101120000-ChatGPTSession'
    #>
    [CmdletBinding()]
    param (
        $Name
    )

    $path = Get-ChatSessionPath

    if (Test-Path $path) {
        $results = Get-ChildItem -Path $path -Filter "*.xml" | Where-Object { $_.Name -match $Name }
        $results
    }
}

function Get-ChatSessionContent {
    <#
        .SYNOPSIS
            Get chat session content
        .DESCRIPTION
            Get chat session content from a chat session file
        .PARAMETER Path
            Path of the chat session file
        .EXAMPLE
            Get-ChatSessionContent -Path 'C:\Users\user\Documents\PowerShellAI\ChatGPT\20200101120000-ChatGPTSession.xml'
    #>
    [CmdletBinding()]
    param (
        [Alias('FullName')]
        [Parameter(ValueFromPipelineByPropertyName)]
        $Path
    )

    Process {
        if (Test-Path -Path $Path) {
            Import-Clixml -Path $Path
        }
    }
}

function Export-ChatSession {
    <#
        .SYNOPSIS
            Export chat session
        .DESCRIPTION
            Export chat session to a chat session file
        .EXAMPLE
            Export-ChatSession
    #>


    [CmdletBinding()]
    param ()

    $sessionPath = Get-ChatSessionPath
    if (-not (Test-Path $sessionPath)) {
        New-Item -ItemType Directory -Path $sessionPath -Force | Out-Null
    }

    Get-ChatMessages | Export-Clixml -Path (Get-ChatSessionFile) -Force
}