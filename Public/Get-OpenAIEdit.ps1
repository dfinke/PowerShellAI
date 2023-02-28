function Get-OpenAIEdit {
	<#
	.SYNOPSIS
	Given a prompt and an instruction, the model will return an edited version of the prompt.

	.DESCRIPTION
	Creates a new edit for the provided input, instruction, and parameters.

	.PARAMETER InputText
	Prompt text to evaluate.

	.PARAMETER Instruction
	The instruction that tells the model how to edit the prompt.

	.PARAMETER model
	ID of the model to use. You can use the text-davinci-edit-001 or code-davinci-edit-001 model with this endpoint. Default is code-davinci-edit-001 model.

	.PARAMETER edits
	How many edits to generate for the input and instruction.

    .PARAMETER Raw
    Returns the raw JSON response from the API.

	.EXAMPLE
	Get-OpenAIEdit -InputText "What day of the wek is it?" -Instruction "Fix the spelling mistakes".

	.NOTES
	Before calling this function the OpenAI key must be set with Set-OpenAIKey function or with the 'OpenAIKey' environment variable.
	Reference: https://platform.openai.com/docs/guides/edits/quickstart
	Reference: https://platform.openai.com/docs/api-reference/edits
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		$InputText,
		[Parameter(Mandatory = $true, Position = 1)]
		$Instruction,
		[Parameter()]
		[ValidateSet('text-davinci-edit-001', 'code-davinci-edit-001')]
		$model = 'code-davinci-edit-001',
		[Parameter()]
		$numberOfEdits = 1,
		[ValidateRange(0, 2)]
		[decimal]$temperature = 0.0,
		[ValidateRange(0, 1)]
		[decimal]$top_p = 1.0,
		[Switch]$Raw
	)

	begin {
		$pipelineInput = [Collections.Generic.List[Object]]::new()
	}

	process {
		$pipelineInput.Add($_)
	}

	end {
		try {
			if (-not $pipelineInput){
				$inputBody = $InputText
			} else {
				$inputBody = $pipelineInput | Out-String
			}

			$body = @{
				"model"       = $model
				"temperature" = $temperature
				"top_p"       = $top_p
				"input"       = $inputBody
				"instruction" = $Instruction
				"n"           = $numberOfEdits
			} | ConvertTo-Json -Compress

			$response = Invoke-OpenAIAPI -Uri (Get-OpenAIEditsURI) -Method Post -Body $body -ErrorAction Stop

			if ($Raw) {
				$response
			} else {
				$response.choices | Select-Object -Property text
			}
		} catch {
			Write-Error -ErrorRecord $_ -ErrorAction $ErrorActionPreference
		}
	}
}
