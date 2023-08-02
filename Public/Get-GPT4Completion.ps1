function Get-AzureOpenAIOptions {
    [CmdletBinding()]
    param()

    $Script:AzureOpenAIOptions
}

function Set-AzureOpenAIOptions {
    [CmdletBinding()]
    param(
        $Endpoint,
        $DeploymentName,
        $ApiVersion
    )

    $options = @{} + $PSBoundParameters

    foreach ($key in $options.Keys) {
        $Script:AzureOpenAIOptions[$key] = $options[$key]
    }
}


function Reset-AzureOpenAIOptions {
    [CmdletBinding()]
    param()

    $Script:AzureOpenAIOptions = @{
        Endpoint       = 'not set'
        DeploymentName = 'not set'
        ApiVersion     = 'not set'
    }
}

function Get-ChatAzureOpenAIURI {
    <#
        .SYNOPSIS
            Get the URI for the Azure OpenAI API.
        .EXAMPLE
            Get-ChatAzureOpenAIURI
    #>
    [CmdletBinding()]
    param()

    $options = Get-AzureOpenAIOptions

    if ($options.Endpoint -eq 'not set') {
        throw 'Azure Open AI Endpoint not set'
    }
    elseif ($options.DeploymentName -eq 'not set') {
        throw 'Azure Open AI DeploymentName not set'
    }
    elseif ($options.ApiVersion -eq 'not set') {
        throw 'Azure Open AI ApiVersion not set'
    }

    $uri = "{0}openai/deployments/{1}/chat/completions?api-version={2}" -f $options.Endpoint, $options.DeploymentName, $options.ApiVersion

    $uri
}

function Get-ChatAPIProvider {
    <#
        .SYNOPSIS
            Get the current chat API provider.
        .EXAMPLE
            Get-ChatAPIProvider
    #>
    [CmdletBinding()]
    param()

    $Script:ChatAPIProvider
}

function Set-ChatAPIProvider {
    <#
        .SYNOPSIS
            Set the chat API provider.
        .PARAMETER Provider
            The chat API provider to use.
            Valid values are 'AzureOpenAI' and 'OpenAI'.
            Default value is 'OpenAI'.
        .EXAMPLE
            Set-ChatAPIProvider -Provider 'AzureOpenAI'
    #>
    [CmdletBinding()]
    param(
        [ValidateSet('AzureOpenAI', 'OpenAI')]
        $Provider = 'OpenAI'
    )

    $Script:ChatAPIProvider = $Provider
}

function Get-ChatSessionOptions {
    <#
        .SYNOPSIS
            Get the current chat session options.
        .EXAMPLE
            Get-ChatSessionOptions
    #>
    [CmdletBinding()]
    param()

    $Script:ChatSessionOptions
}

function Set-ChatSessionOption {
    <#
        .SYNOPSIS
            Set a chat session option.
                
        .PARAMETER model
            The model to use for the chat session.
            Valid values are 'gpt-4' and 'gpt-3.5-turbo'.
            Default value is 'gpt-4'.
        .PARAMETER max_tokens
            The maximum number of tokens to generate.
            Default value is 256.
        .PARAMETER temperature
            The temperature of the model.
            Default value is 0.
        .PARAMETER top_p
            The top_p of the model.
            Default value is 1. 
        .PARAMETER frequency_penalty
            The frequency penalty of the model.
            Default value is 0.
        .PARAMETER presence_penalty
            The presence penalty of the model.
            Default value is 0.
        .PARAMETER stop
            The stop sequence of the model.
            Default value is $null.
        .EXAMPLE
            Set-ChatSessionOption -model 'gpt-4'
        .EXAMPLE
            Set-ChatSessionOption -max_tokens 512

    #>
    [CmdletBinding()]
    param(
        [ValidateSet('gpt-4', 'gpt-4-0613', 'gpt-3.5-turbo', 'gpt-3.5-turbo-16k', 'gpt-3.5-turbo-0613')]
        $model,
        $max_tokens = 256,
        $temperature = 0,
        $top_p = 1,
        $frequency_penalty = 0,
        $presence_penalty = 0,
        $stop
    )

    $options = @{} + $PSBoundParameters
    
    foreach ($entry in $options.GetEnumerator()) {
        $Script:ChatSessionOptions["$($entry.Name)"] = $entry.Value
    }
}

function Reset-ChatSessionOptions {
    <#
        .SYNOPSIS
            Reset the chat session options to their default values.
        .EXAMPLE
            Reset-ChatSessionOptions
    #>
    [CmdletBinding()]
    param()

    $Script:ChatSessionOptions = @{
        'model'             = 'gpt-4'
        'temperature'       = 0.0
        'max_tokens'        = 256
        'top_p'             = 1.0
        'frequency_penalty' = 0
        'presence_penalty'  = 0
        'stop'              = $null
    }

    Enable-ChatPersistence
}

function Clear-ChatMessages {
    <#
        .SYNOPSIS
            Clear the chat messages in the current chat session.
        .EXAMPLE
            Clear-ChatMessages
    #>
    [CmdletBinding()]
    param()

    $Script:ChatMessages.Clear()
}

function Add-ChatMessage {
    <#
        .SYNOPSIS
            Add a chat message to the current chat session.
        .PARAMETER Message
            The chat message to add.
        .EXAMPLE
            Add-ChatMessage -Message <#PSCustomObject#>
    #>    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Message
    )

    $null = $Script:ChatMessages.Add($Message)
}

function New-ChatMessageTemplate {
    <#
        .SYNOPSIS
            Create a new chat message template.
        .PARAMETER Role
            The role of the chat message.
            Valid values are 'user', 'system', and 'assistant'.
        .PARAMETER Content
            The content of the chat message.
        .PARAMETER Name
            The name of the author of this message. name is required if role is function, and it should be the name of the function whose response is in the content
        .EXAMPLE
            New-ChatMessageTemplate -Role 'user' -Content <#string#>
    #>
    [CmdletBinding()]
    param( 
        [ValidateSet('user', 'system', 'assistant', 'function')]
        $Role,
        $Content,
        $Name
    )

    $returnObject = [ordered]@{
        role    = $Role
        content = $Content
    }

    if ($Role -eq 'function' -and $null -eq $Name) {
        throw 'Name is required if role is function'
    }
    
    if ($Name) {
        $returnObject.name = $Name
    }

    [PSCustomObject]$returnObject
}

function New-ChatMessage {
    <#
        .SYNOPSIS
            Create a new chat message.
        .DESCRIPTION
            Create a new chat message and add it to the current chat session.
        .PARAMETER Role
            The role of the chat message.
            Valid values are 'user', 'system', and 'assistant'.
        .PARAMETER Content
            The content of the chat message.
        .EXAMPLE
            New-ChatMessage -Role 'user' -Content <#string
    #>
    param(
        [Parameter(Mandatory)]
        [ValidateSet('user', 'system', 'assistant')]
        $Role,
        [Parameter(Mandatory)]
        $Content
    )

    $Script:ChatInProgress = $Script:true

    $message = New-ChatMessageTemplate -Role $Role -Content $Content

    Add-ChatMessage -Message $message

    #Export-ChatSession
}

function New-ChatSystemMessage {
    <#
        .SYNOPSIS
            Create a new chat system message.
        .DESCRIPTION
            Create a new chat system message and add it to the current chat session.
        .PARAMETER Content
            The content of the chat message.
        .EXAMPLE
            New-ChatSystemMessage -Content <#string#>        
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Content
    )

    New-ChatMessage -Role 'system' -Content $Content
}

function New-ChatUserMessage {
    <#
        .SYNOPSIS
            Create a new chat user message.
        .DESCRIPTION
            Create a new chat user message and add it to the current chat session.
        .PARAMETER Content
            The content of the chat message.
        .EXAMPLE
            New-ChatUserMessage -Content <#string#>
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Content
    )

    New-ChatMessage -Role 'user' -Content $Content
}

function New-ChatAssistantMessage {
    <#
        .SYNOPSIS
            Create a new chat assistant message.
        .DESCRIPTION
            Create a new chat assistant message and add it to the current chat session.
        .PARAMETER Content
            The content of the chat message.
        .EXAMPLE
            New-ChatAssistantMessage -Content <#string
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Content
    )

    New-ChatMessage -Role 'assistant' -Content $Content
}

function Get-ChatMessages {
    <#
        .SYNOPSIS
            Get the chat messages in the current chat session.
        .EXAMPLE
            Get-ChatMessages
    #>
    [CmdletBinding()]
    param()

    @($Script:ChatMessages)
}

function Get-ChatPayload {
    <#
        .SYNOPSIS
            Get the chat payload.
        .DESCRIPTION
            Get the chat payload as a PSCustomObject.
        .PARAMETER AsJson
            Return the chat payload as a JSON string.
        .EXAMPLE
            Get-ChatPayload
    #>
    [CmdletBinding()]
    param(
        [Switch]$AsJson
    )

    $payload = (Get-ChatSessionOptions).Clone()
    
    $payload.messages = @(Get-ChatMessages)

    if ($AsJson) {
        return $payload | ConvertTo-Json -Depth 10
    }
    else {
        return $payload
    }
    
}

function New-Chat {
    <#
        .SYNOPSIS
            Start a new chat session.
        .DESCRIPTION
            Start a new chat session and optionally send a message to the assistant.
        .PARAMETER Content
            The content of the chat message.
        .EXAMPLE
            New-Chat 
        .EXAMPLE
            New-Chat -Content <#string#>
    #>
    [CmdletBinding()]
    param(
        $Content
    )

    Stop-Chat
    $Script:ChatInProgress = $true

    if (![string]::IsNullOrEmpty($Content)) {
        New-ChatSystemMessage -Content $Content
        Get-GPT4Response
    }
    
}

function Test-ChatInProgress {
    <#
        .SYNOPSIS
            Test if a chat session is in progress.
        .EXAMPLE
            Test-ChatInProgress
    #>
    [CmdletBinding()]
    param()
    $Script:ChatInProgress
}

function Stop-Chat {
    <#
        .SYNOPSIS
            Stop the current chat session.
        .EXAMPLE
            Stop-Chat
    #>
    [CmdletBinding()]
    param()

    $Script:ChatInProgress = $false
    
    Clear-ChatMessages
    Reset-ChatSessionTimeStamp 
}

function Get-GPT4Completion {
    <#
        .SYNOPSIS
            Get a GPT-4 completion.
        .DESCRIPTION
            Get a GPT-4 completion from the OpenAI API.
        .EXAMPLE
            chat "use powershell: what is my IP address?"
        .EXAMPLE
            Get-GPT4Completion -Prompt <#string#>
    #>
    [CmdletBinding()]
    [alias("chat")]
    param(
        [Parameter(Mandatory)]
        $Content,
        [decimal]$temperature
    )

    New-ChatUserMessage -Content $Content

    Get-GPT4Response -Temperature $temperature
}

function Get-GPT4Response {
    [CmdletBinding()]
    param(
        [decimal]$Temperature
    )

    $payload = Get-ChatPayload -AsJson
    $body = [System.Text.Encoding]::UTF8.GetBytes($payload)

    if ((Get-ChatAPIProvider) -eq 'OpenAI') {
        $uri = Get-OpenAIChatCompletionUri
    }
    elseif ((Get-ChatAPIProvider) -eq 'AzureOpenAI') {
        $uri = Get-ChatAzureOpenAIURI
    }
    
    if ($Temperature) {
        (Get-ChatSessionOptions)['temperature'] = $Temperature
    }

    $result = Invoke-OpenAIAPI -Uri $uri -Method 'Post' -Body $body 

    if ($result.choices) {
        $response = $result.choices[0].message.content
        New-ChatAssistantMessage -Content $response
        
        Export-ChatSession
        return $response
    }
}