function Set-AzureOpenAI {
    <#
        .SYNOPSIS 
            Sets the Azure OpenAI API endpoint, deployment name, API version, and API key.
        .DESCRIPTION
            Sets up Azure OpenAI as the chat API provider. Use `Set-ChatAPIProvider -Provider OpenAI` to point to the public OpenAI
        .EXAMPLE
            Set-AzureOpenAI `
                -Endpoint https://anEndpoint.openai.azure.com/ `
                -DeploymentName aName `
                -ApiVersion 2023-03-15-preview `
                -ApiKey aKey
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Endpoint,
        [Parameter(Mandatory)]
        $DeploymentName,
        [Parameter(Mandatory)]
        $ApiVersion,
        [Parameter(Mandatory)]
        $ApiKey
    )

    $p = @{} + $PSBoundParameters    
    $p.Remove("ApiKey")    

    Set-AzureOpenAIOptions @p
    $env:AzureOpenAIKey = $ApiKey
    Set-ChatAPIProvider -Provider AzureOpenAI
}