#Requires -Modules PowerShellAI

# This script uses the Get-DalleImage function from the PowerShellAI module
# to generate an image based on a text description using the DALL-E model.
# The image will be saved to a specified path on the local machine.

# Define a description for the image you want to generate
$description = 'A scenic view of the mountains at sunset with a river in the foreground'

# Define parameters for the DALL-E API request
$params = @{
    Description  = $description
    Size         = '1024x1024'  # Image dimensions
    Quality      = 'hd'      # Image quality
    Style        = 'natural'   # Image style
    ModelVersion = '3'  # DALL-E model version
}

# Call the Get-DalleImage function and store the path of the saved image
$imagePath = Get-DalleImage @params

# Output the path to the generated image
Write-Host "Image generated at: $imagePath"