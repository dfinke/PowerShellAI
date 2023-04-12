Set-AzureOpenAI `
    -Endpoint https://anEndpoint.openai.azure.com/ `
    -DeploymentName aName `
    -ApiVersion 2023-03-15-preview `
    -ApiKey aKey

chat 'what is 5+8?'
Stop-Chat