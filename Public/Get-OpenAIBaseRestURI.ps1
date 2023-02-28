function Get-OpenAIBaseRestURI {
    <#
        .Synopsis
        Base url for OpenAIBase API
        .DESCRIPTION
        Gets the base URI used for all OpenAI API requests.        
        .Example
        Invoke-OpenAIAPI ((Get-OpenAIBaseRestURI)+'/models')
        .LINK
        Invoke-OpenAIAPI
    #>
    
    'https://api.openai.com/v1'
}