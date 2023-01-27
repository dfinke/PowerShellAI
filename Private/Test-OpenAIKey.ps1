

function Test-OpenAIKey {
    [CmdletBinding()]
    <#
        .SYNOPSIS
        Used to validate api key
        .DESCRIPTION
        Validates OpenAIKey
        .PARAMETER openAiKey
        Default is OpenAIKey stored as an environmental variable. Otherwise, Api token is a secure string.
        .PARAMETER model
        The OpenAI API model by which to validate token. Default is text-davinci-003.
    #>
    param (
        [securestring]$openAiToken = (ConvertTo-SecureString -String $($env:OpenAIKey) -AsPlainText), 
        [string]$model = 'text-davinci-003'
    )

    try {
            Write-Progress -Activity "OpenAI Key" -Status "Validating..."
            Invoke-RestMethod -Uri "https://api.openai.com/v1/models/$($model)" -Authentication Bearer -Token $openAiToken                
            Write-Progress -Activity "OpenAI Key" -Completed
            return $true
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Error $statusCode
        throw 'Failed to access OpenAI api [$statusCode]. Please check your OpenAI API key (https://beta.openai.com/account/api-keys) and Organization ID (https://beta.openai.com/account/org-settings). You may also need to set the $env:OpenAIKey environment variable to your OpenAI API key or pass in the key as a secure string.'
    }
}
