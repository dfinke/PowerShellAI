Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe 'Get-DalleImage' -Tag 'Get-DalleImage' {

    BeforeAll {
        # Assumes OpenAIKey is set in environment
        # Configure the OpenAI key if not already done
        $script:savedKey = $env:OpenAIKey
        $env:OpenAIKey = 'sk-1234567890' # Replace with your actual API key for testing
    }

    AfterAll {
        # Restore the OpenAI key
        $env:OpenAIKey = $savedKey
    }

    Mock Invoke-OpenAIAPI {
        return @{
            data = @{
                url = 'https://mocked.image.url/image.png'
            }
        }
    }

    It 'Should call the right OpenAI API endpoint with correct parameters' {
        $description = 'A futuristic cityscape'
        $imagePath = Get-DalleImage -Description $description -Size '1024x1024' -Quality 'hd' -Style 'natural' -ModelVersion '3' -Raw:$true

        # Assert the mocked Invoke-OpenAIAPI was called
        Assert-MockCalled -CommandName Invoke-OpenAIAPI -Times 1 -Exactly 

        # Assert the returned image path matches the mock
        $imagePath.url | Should -Be 'https://mocked.image.url/image.png'
    }

    It 'Should save the image to a temp file when not using the -Raw switch' {
        $description = 'A cartoon character'
        $imagePath = Get-DalleImage -Description $description

        # Assert the file exists
        Test-Path -Path $imagePath | Should -Be $true

        # Cleanup the temp file
        if (Test-Path -Path $imagePath) {
            Remove-Item -Path $imagePath -Force
        }
    }
}