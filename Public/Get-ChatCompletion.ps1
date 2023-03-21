<#

NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE

This script is a work in progress.

It is a ** Proof of Concept **

It has proven to be a very useful tool.

I am releasing it as a preview to get feedback.

Next steps are to refactor the code, add unit tests, add help, vidoes and add more features.

Easiest way to get started:

1. Install-Module PowerShellAI

```powershell
new-chat 'you are a powershell bot'

chat 'even numbers btwn 1 and 10'
chat 'odd numbers'
```

These functions enable having a chat session with a GPT model. It has "memory" and keeps track of the conversation.

More to come....
#>

$Script:messages
$Script:timeStamp = $null

$Script:chatSessionPath = if ($PSVersionTable.PSVersion.Major -lt 6 -or $IsWindows) {
    Join-Path $env:APPDATA 'PowerShellAI/ChatGPT'
}
else {
    Join-Path $env:HOME '~/PowerShellAI/ChatGPT'
}

$Script:chatInProgress = $false

function Test-ChatInProgress {
    $Script:chatInProgress
}

function Get-ChatTheme {
    if (Test-ChatInProgress) {
        $Script:messages[0].content
    }
    else {
        "No chat in progress. Use `Chat <content>` or `New-Chat <theme>` to start a new chat session."
    }
}

function Stop-Chat {
    $Script:chatInProgress = $false
    $Script:messages = @()
    $Script:timeStamp = $null
}

function Get-ChatHistory {
    if (Test-ChatInProgress) {
        if ($Script:messages.Count -gt 0) {
            foreach ($message in $Script:messages) {
                [PSCustomObject]$message
            }
        }
        else {
            "No chat history"
        }
    }
    else {
        "No chat in progress. Use `Chat <content>` or `New-Chat <theme>` to start a new chat session."
    }
}

function Get-ChatInProgress {
    if (Test-ChatInProgress) {
        Get-ChatHistory
    }
    else {
        "No chat in progress. Use `New-Chat` to start a new chat session."
    }
}

function Set-TimeStamp {
    param(
        $targetTimeStamp
    )

    if ($null -ne $targetTimeStamp) {
        $Script:timeStamp = $targetTimeStamp
    }
    else {
        $Script:timeStamp = Get-Date -Format 'yyyyMMddHHmmss'
    }
}

function New-Chat {
    param(
        $prompt
    )

    if ($null -ne $Script:timeStamp) {
        Export-ChatSession
    }

    $Script:chatInProgress = $true
    $Script:messages = @()

    Set-TimeStamp

    if ($null -ne $prompt) {
        New-ChatMessage -Role system -Content $prompt
    }
}

function Get-ChatSessionPath {
    $Script:chatSessionPath
}

function Export-ChatSession {
    $file = Join-Path $Script:chatSessionPath ("{0}-ChatGPTSession.xml" -f $Script:timeStamp)

    if (-not (Test-Path $Script:chatSessionPath)) {
        $null = New-Item -ItemType Directory -Path $Script:chatSessionPath
    }

    $Script:messages | Export-Clixml -Path $file -Force
}

function Import-ChatSession {
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        $Path
    )

    End {
        if ($null -eq $Path -or -not (Test-Path $Path) ) {
            throw "Chat session file not found or is empty: $Path"
        }

        $Script:messages = Import-Clixml -Path $Path
        Set-TimeStamp ((Split-Path -Leaf $Path) -split '-')[0]
        $Script:chatInProgress = $true
    }
}

function Get-ChatSession {
    param(
        $Name
    )

    if (Test-Path $Script:chatSessionPath) {
        Get-ChildItem -Path $Script:chatSessionPath *.xml | Where-Object { $_.Name -match $Name }
    }
}

function Get-ChatSessionContent {
    param(
        [Alias('FullName')]
        [Parameter(ValueFromPipelineByPropertyName)]
        $Path
    )

    Process {
        (Import-Clixml -Path $Path) | ForEach-Object {
            $SessionName = (Split-Path -Leaf $Path) -replace '-ChatGPTSession.xml', ''
            [PSCustomObject]$_ | Add-Member -PassThru -MemberType NoteProperty -Name SessionName -Value $SessionName

        } | Select-Object SessionName, Role, Content
    }
}

function Invoke-ChatCompletion {
    [CmdletBinding()]
    [alias("chat")]
    param(
        [Parameter(Mandatory)]
        $prompt,
        [switch]$FastDisplay
    )

    if (!(Test-ChatInProgress)) {
        New-Chat
    }

    Write-ChatResponse -Role user -Content $prompt
}

function Import-ChatMessages {
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        $Content,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('user', 'system', 'assistant')]
        $Role
    )

    Begin {
        if (!(Test-ChatInProgress)) {
            New-Chat
        }
    }

    Process {
        if ($Content -is [string]) {
            $targetContent = $Content
        }
        else {
            $targetContent = $Content.Content
        }

        #New-ChatMessage -Role $Role -Content $Content #.Content
        New-ChatMessage -Role $Role -Content $targetContent
    }

}

function Import-ChatAssistantMessages {
    param(
        [Parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)]
        $Content
    )

    Process {
        [PSCustomObject]@{
            role    = 'assistant'
            content = $Content
        }  | Import-ChatMessages
    }
}

function Import-ChatUserMessages {
    param(
        [Parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)]
        $Content
    )

    Process {
        [PSCustomObject]@{
            role    = 'user'
            content = $Content.Content
        }  | Import-ChatMessages
    }
}

function New-ChatMessage {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('user', 'system', 'assistant')]
        $Role,
        [Parameter(Mandatory)]
        $Content
    )

    $Script:messages += @(
        @{
            role    = $Role
            content = $Content
        }
    )

    Export-ChatSession
}

function Get-OpenAIChatPayload {
    param(
        $model = 'gpt-3.5-turbo',
        $temperature = 0.0,
        $max_tokens = 256,
        $top_p = 1.0,
        $frequency_penalty = 0,
        $presence_penalty = 0,
        $stop
    )

    $payLoad = [ordered]@{
        model             = $model
        messages          = $Script:messages
        temperature       = $temperature
        max_tokens        = $max_tokens
        top_p             = $top_p
        frequency_penalty = $frequency_penalty
        presence_penalty  = $presence_penalty
        stop              = $stop
    }

    $payLoad | ConvertTo-Json -Depth 5
}

function Write-ChatResponse {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('user', 'system')]
        $Role,
        [Parameter(Mandatory)]
        $Content
    )

    New-ChatMessage -Role $Role -Content $prompt

    $body = Get-OpenAIChatPayload
    $result = Invoke-OpenAIAPI -Uri (Get-OpenAIChatCompletionUri) -Method 'Post' -Body $body

    if (!$ExcludeResponseFromBeingSaved) {
        New-ChatMessage -Role assistant -Content $result.choices[0].message.content
    }

    if ($Raw) {
        $result
    }
    elseif ($result.choices) {
        $content = $result.choices[0].message.content

        if ($FastDisplay) {
            Write-Host $content
        }
        else {
            $content.ToCharArray() | ForEach-Object { Write-Host -NoNewline $_; Start-Sleep -Milliseconds 1 }
        }
    }
    ''
}

function Get-ChatCompletion {
    <#
        .SYNOPSIS
        Get a completion from the OpenAI GPT-3 API

        .DESCRIPTION
        Given a prompt, the model will return one or more predicted completions, and can also return the probabilities of alternative tokens at each position

        .PARAMETER prompt
        The prompt to generate completions for

        .PARAMETER model
        ID of the model to use. Defaults to 'text-davinci-003'

        .PARAMETER temperature
        The temperature used to control the model's likelihood to take risky actions. Higher values means the model will take more risks. Try 0.9 for more creative applications, and 0 (argmax sampling) for ones with a well-defined answer. Defaults to 0

        .PARAMETER max_tokens
        The maximum number of tokens to generate. By default, this will be 64 if the prompt is not provided, and 1 if a prompt is provided. The maximum is 2048

        .PARAMETER top_p
        An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered. Defaults to 1

        .PARAMETER frequency_penalty
        A value between 0 and 1 that penalizes new tokens based on whether they appear in the text so far. Defaults to 0

        .PARAMETER presence_penalty
        A value between 0 and 1 that penalizes new tokens based on whether they appear in the text so far. Defaults to 0

        .PARAMETER stop
        A list of tokens that will cause the API to stop generating further tokens. By default, the API will stop generating when it hits one of the following tokens: ., !, or ?.

        .EXAMPLE
        Get-GPT3Completion -prompt "What is 2%2? - please explain"
    #>
    [CmdletBinding()]
    [alias("chatgpt")]
    param(
        # [Parameter(Mandatory)]
        $prompt,
        $model = 'gpt-3.5-turbo',
        [ValidateRange(0, 2)]
        [decimal]$temperature = 0.0,
        [ValidateRange(1, 4096)]
        [int]$max_tokens = 256,
        [ValidateRange(0, 1)]
        [decimal]$top_p = 1.0,
        [ValidateRange(-2, 2)]
        [decimal]$frequency_penalty = 0,
        [ValidateRange(-2, 2)]
        [decimal]$presence_penalty = 0,
        $stop,
        [Switch]$Raw,
        [Switch]$FastDisplay,
        [Switch]$ExcludeResponseFromBeingSaved
    )

    New-Chat

    if ($prompt) {
        New-ChatMessage -Role 'system' -Content $prompt
    }

    function AnotherQuestion {
        $prompt = Read-Host -Prompt 'Please tell me what you would like to know'
        Write-ChatResponse -Role 'user' -Content $prompt
    }

    function NewChat {
        New-Chat
        $prompt = Read-Host -Prompt 'What is the theme of your chat'
        New-ChatMessage -Role 'system' -Content $prompt

        AnotherQuestion
    }

    function RunCode {
        Write-Host "Run: Not yet implemented`r`n" -ForegroundColor Red
    }

    function SaveCode {
        Write-Host "Save: Not yet implemented`r`n" -ForegroundColor Red
    }

    function StopChat {
        break
    }

    function ClearScreen {
        Clear-Host
    }

    [System.Collections.ArrayList]$map = @()
    function New-MenuOption {
        param(
            [System.Management.Automation.Host.ChoiceDescription]$ChoiceDescription,
            $Action
        )

        $null = $map.Add(@{
                ChoiceDescription = $ChoiceDescription
                Action            = $Action
            })
    }

    New-MenuOption (New-Object System.Management.Automation.Host.ChoiceDescription '&Another question', 'Do a follow up question') AnotherQuestion
    New-MenuOption (New-Object System.Management.Automation.Host.ChoiceDescription '&New Chat', 'Start a new chat') NewChat
    New-MenuOption (New-Object System.Management.Automation.Host.ChoiceDescription '&Run', 'Run the code') RunCode
    New-MenuOption (New-Object System.Management.Automation.Host.ChoiceDescription '&Save', 'Save the code') SaveCode
    New-MenuOption (New-Object System.Management.Automation.Host.ChoiceDescription '&Clear Screen', 'Clear the screen') ClearScreen
    New-MenuOption (New-Object System.Management.Automation.Host.ChoiceDescription '&Quit', 'Stop the chat') StopChat

    $descriptions = foreach ($item in $map) { $item.ChoiceDescription }
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($descriptions)

    AnotherQuestion

    while ($true) {
        $message = "`r`nWhat would you like to do next?"
        $response = $host.ui.PromptForChoice($null, $message, $options, 0)
        &$map[$response].Action
    }
}