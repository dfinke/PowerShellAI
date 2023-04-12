Set-AzureOpenAI `
    -Endpoint https://anEndpoint.openai.azure.com/ `
    -DeploymentName aName `
    -ApiVersion 2023-03-15-preview `
    -ApiKey aKey

chat 'I have 3 apples, gave one to the teacher, and gave one to my friend. How many apples do I have left?'
Stop-Chat