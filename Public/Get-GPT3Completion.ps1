function Get-GPT3Completion {
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
    [alias("gpt")]
    param(
        [Parameter(Mandatory)]
        $prompt,
        $model = 'gpt-3.5-turbo',
        [ValidateRange(0, 2)]
        [decimal]$temperature = 0.0,
        [ValidateRange(1, 2048)]
        [int]$max_tokens = 256,
        [ValidateRange(0, 1)]
        [decimal]$top_p = 1.0,
        [ValidateRange(-2, 2)]
        [decimal]$frequency_penalty = 0,
        [ValidateRange(-2, 2)]
        [decimal]$presence_penalty = 0,
        $stop,
        [Switch]$Raw
    )

    # if (!(Test-OpenAIKey)) {
    #     throw 'You must set the $env:OpenAIKey environment variable to your OpenAI API key. https://beta.openai.com/account/api-keys'
    # }

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
    
    $result = Invoke-OpenAIAPI -Uri (Get-OpenAICompletionsURI) -Method 'Post' -Body $body

    if ($Raw) {
        $result
    } 
    elseif ($result.choices) {
        $result.choices[0].text
    }
}
