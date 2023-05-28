function Get-NumberOfTokens {
    <#
    .SYNOPSIS
        Gets the number of tokens in a message using OpenAI's GPT models.
    .DESCRIPTION
        This function encodes a message using the specified OpenAI GPT model and returns the number of tokens in the encoded message.
    .PARAMETER Message
        The message to encode and count the number of tokens for.
    .PARAMETER InputText
        Additional text to append to the message before encoding.
    .PARAMETER Model
        The OpenAI GPT model to use for encoding. Default is 'gpt-4'.
    .PARAMETER Truncate
        The maximum number of tokens to return. If specified, the function will return a truncated version of the encoded message.
    .PARAMETER Tokens
        If specified, the function will return the encoded message as an array of tokens instead of the count of tokens.
    .EXAMPLE
        Get-NumberOfTokens -Message "Hello, world!" -Model "davinci"
        Returns the number of tokens in the message "Hello, world!" encoded using the OpenAI GPT model 'davinci'.
    #>
    [CmdletBinding()]
    [Alias('pstok')]
    param(
        [Parameter(ValueFromPipeline)]
        $Message,
        $InputText,
        [ValidateSet('ada', 'babbage', 'code-cushman-001', 'code-cushman-002', 'code-davinci-001', 'code-davinci-002', 'code-davinci-edit-001', 'code-search-ada-code-001', 'code-search-babbage-code-001', 'curie', 'cushman-codex', 'davinci', 'davinci-codex', 'gpt-3.5-turbo', 'gpt-4', 'text-ada-001', 'text-babbage-001', 'text-curie-001', 'text-davinci-001', 'text-davinci-002', 'text-davinci-003', 'text-davinci-edit-001', 'text-embedding-ada-002', 'text-search-ada-doc-001', 'text-search-babbage-doc-001', 'text-search-curie-doc-001', 'text-search-davinci-doc-001', 'text-similarity-ada-001', 'text-similarity-babbage-001', 'text-similarity-curie-001', 'text-similarity-davinci-001')]
        $Model = 'gpt-4',
        [int]$Truncate,
        [Switch]$Tokens
    )
 
    End {
        $fullMessage = $Message 
        if ($InputText) {
            $fullMessage += ' ' + $InputText
        }
        
        $encoding = [SharpToken.GptEncoding]::GetEncodingForModel($Model)
        $result = $encoding.Encode($fullMessage)

        if ($truncate) {
            $result = $result[0..($truncate - 1)]
            return $encoding.Decode($result)
        }
    
        if ($Tokens) {
            $result -join ' '
        }
        else {
            $result.Count
        }
    }
}