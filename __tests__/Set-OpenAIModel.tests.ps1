Remove-Module 'PowerShellAI' -Force -ErrorAction Ignore
Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe "Set-OpenAIModel" {
    BeforeEach {
        # Clear any previous state of the OpenAI model
        Remove-Variable -Name OpenAIModel -Scope Script -ErrorAction SilentlyContinue
    }

    Context "When a valid model is specified" {
        InModuleScope 'PowerShellAI' {
            It "Sets the specified model as the default" {
                $model = "text-ada-001"
                Set-OpenAIModel -Model $model

                $expectedModel = $model
                $actualModel = $Script:OpenAIModel

                $actualModel | Should -Be $expectedModel
            }
        }

        It "Writes verbose output indicating the model being used" {
            $model = "text-ada-001"
            Set-OpenAIModel -Model $model -Verbose 4>&1 | Should -Be "Using $model model"
        }
    }

    Context "When an invalid model is specified" {
        It "Throws an exception with an error message" {
            $model = "invalid-model"
            {Set-OpenAIModel -Model $model} | Should -Throw "Cannot validate argument on parameter 'Model'. Sepcified OpenAI Model is not on the available models list."
        }
    }
}
