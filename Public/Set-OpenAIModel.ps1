function Set-OpenAIModel {
    <#
        .SYNOPSIS
        Set the OpenAI API model.

        .DESCRIPTION
        Sets the default OpenAI model using string parameter.

        .PARAMETER Model
        Specifies OpenAI API model name as string.

        .EXAMPLE
        Set-OpenAIModel -Model "text-ada-001"
        .EXAMPLE
        Set-OpenAIModel -Model (Get-OpenAIModel | Get-Random)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({if ($_ -in (Get-OpenAIModel)) {$true} else {throw 'Sepcified OpenAI Model is not on the available models list.'}})]
        [ValidateNotNullOrEmpty()]
        [string]
        $Model
    )

    $Script:OpenAIModel = $Model
    Write-Verbose "Using $Model model"
}
