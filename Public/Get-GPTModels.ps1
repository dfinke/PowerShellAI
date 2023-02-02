function Get-GPTModels {
	[CmdletBinding()]
	<#
	.SYNOPSIS
	Get a list of current OpenAI GPT-3 API models
	.DESCRIPTION
	Returns full model properties, or just the names (id values)
	.PARAMETER NamesOnly
	Optional. Returns only the [id] values for each model. Default is to return all properties
	.PARAMETER Endpoint
	URI for API models namespace. Exposed in case a different endpoint is needed later
	.EXAMPLE
	Get-GPTModels
	.EXAMPLE
	Get-GPTModels -NamesOnly
	.NOTES
	This function requires the 'OpenAIKey' environment variable to be defined before being invoked
	#>
	param(
		[parameter()][switch]$NamesOnly,
		[parameter()][string]$Endpoint = "https://api.openai.com/v1/models"
	)
	try {
		if ([string]::IsNullOrWhiteSpace($env:OpenAIKey)) { throw "OpenAIKey environment variable is not defined" }
		if ([string]::IsNullOrWhiteSpace($Endpoint)) { throw "Endpoint was not provided" }
		$response = Invoke-WebRequest -Uri $Endpoint -Headers @{Authorization="Bearer $($env:OpenAIKey)"}
		if ($NamesOnly) {
			return ($response.Content | ConvertFrom-Json).data.id
		} else {
			return ($response.Content | ConvertFrom-Json).data
		}
	} catch {
		Write-Error $_.Exception.Message
	}
}