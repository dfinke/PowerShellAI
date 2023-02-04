function Get-GPT3Completion {
    [CmdletBinding()]
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
    [alias("gpt")]
    param(
        [Parameter(Mandatory)]
        $prompt,
        $model = 'text-davinci-003',
        [ValidateRange(0, 1)]
        [int]$temperature,
        [ValidateRange(1, 2048)]
        [int]$max_tokens = 256,
        [ValidateRange(0, 1)]
        [int]$top_p = 1,
        [ValidateRange(-2, 2)]
        [int]$frequency_penalty = 0,
        [ValidateRange(-2, 2)]
        [int]$presence_penalty = 0,
        $stop,
        [Switch]$Raw
    )

    if (!(Test-OpenAIKey)) {
        throw 'You must set the $env:OpenAIKey environment variable to your OpenAI API key. https://beta.openai.com/account/api-keys'
    }

    $body = [ordered]@{
        model             = $model
        prompt            = $prompt
        temperature       = $temperature
        max_tokens        = $max_tokens
        top_p             = $top_p
        frequency_penalty = $frequency_penalty
        presence_penalty  = $presence_penalty
        stop              = $stop
    }

    $body = $body | ConvertTo-Json -Depth 5
    $body = [System.Text.Encoding]::UTF8.GetBytes($body)
    $params = @{
        Uri         = "https://api.openai.com/v1/completions" 
        Method      = 'Post' 
        Headers     = @{Authorization = "Bearer $($env:OpenAIKey)" } 
        ContentType = 'application/json'
        #body        = $body | ConvertTo-Json -Depth 5
        body        = $body
    }    
    
    #$params["body"] = [System.Text.Encoding]::UTF8.GetBytes($json)
    
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
        if ($env:USERNAME -eq 'finke') { $exclude = 'Headers' }

        $params | 
        ConvertTo-Json -Depth 10 | 
        ConvertFrom-Json | 
        Select-Object * -ExcludeProperty $exclude |
        Format-List |
        Out-Host
    }

    # Write-Progress -Activity 'PowerShellAI' -Status 'Processing GPT repsonse. Please wait...'

    $result = Invoke-RestMethod @params

    if ($Raw) {
        $result
    } 
    elseif ($result.choices) {
        $result.choices[0].text
    }
}
