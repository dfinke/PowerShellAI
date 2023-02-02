function Get-GPTModeration {
	<#
	.SYNOPSIS
	Checks if prompt contains wording that violates OpenAI moderation rules
	.DESCRIPTION
	Checks prompt text content against latest moderation rules to determine if
	any OpenAI moderation rules would be violated.
	.PARAMETER InputText
	Prompt text to evaluate
	.PARAMETER Endpoint
	URI for API moderations namespace. Exposed in case a different endpoint is needed later
	.EXAMPLE
	Get-GPTModeration -InputText "I want to kill them."
	.NOTES
	This function requires the 'OpenAIKey' environment variable to be defined before being invoked
	Reference: https://platform.openai.com/docs/guides/moderation/quickstart
	Reference: https://platform.openai.com/docs/api-reference/moderations/create
	#>
	[CmdletBinding()]
	param(
		[parameter()][string][ValidateNotNullOrEmpty()]$InputText,
		[parameter()][string]$Endpoint = "https://api.openai.com/v1/moderations"
	)
	try {
		if ([string]::IsNullOrWhiteSpace($env:OpenAIKey)) { throw "OpenAIKey environment variable is not defined" }
		if ([string]::IsNullOrWhiteSpace($Endpoint)) { throw "Endpoint was not provided" }
		$headers = @{
			"Authorization" = "Bearer $($env:OpenAIKey)"
			"Content-Type" = "application/json"
		}
		$response = Invoke-RestMethod -Method POST -Uri $Endpoint -Headers $headers -Body '{"input": "'+$InputText+'"}'
		if ($NamesOnly) {
			return ($response.Content | ConvertFrom-Json).data.id
		} else {
			return ($response.Content | ConvertFrom-Json).data
		}
	} catch {
		Write-Error $_.Exception.Message
	}
}