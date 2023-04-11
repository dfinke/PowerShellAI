Class OpenAIModels : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        # $templates = foreach ($model in Get-OpenAIModel) {
        #     $template.BaseName
        # }
          
        return Get-OpenAIModel
    }
}

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
        [ValidateSet([OpenAIModels])]
        $Model
    )

    $Script:OpenAIModel = $Model
    Write-Verbose "Using $Model model"
}
