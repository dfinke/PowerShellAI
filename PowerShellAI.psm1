# Set the OpenAI key to null
$Script:OpenAIKey = $null

# Set the OpenAI base URI to OpenAI
$Script:OpenAIBaseUri = 'https://api.openai.com'

# Set the chat API provider to OpenAI
$Script:ChatAPIProvider = 'OpenAI'

# Set the chat in progress flag to false
$Script:ChatInProgress = $false

# Create an array list to store chat messages
[System.Collections.ArrayList]$Script:ChatMessages = @()

# Enable chat persistence
$Script:ChatPersistence = $true

# Set the options for the chat session
$Script:ChatSessionOptions = @{
    'model'             = 'gpt-4'
    'temperature'       = 0.0
    'max_tokens'        = 256
    'top_p'             = 1.0
    'frequency_penalty' = 0
    'presence_penalty'  = 0
    'stop'              = $null
}

# Set the options for the Azure OpenAI API
$Script:AzureOpenAIOptions = @{
    Endpoint       = 'not set'
    DeploymentName = 'not set'
    ApiVersion     = 'not set'
}

# Load all PowerShell scripts in the Public and Private directories
foreach ($directory in @('Public', 'Private')) {
    Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1" | ForEach-Object { . $_.FullName }
}
