# DALL-E Image Generation Example

This example demonstrates how to use the `Get-DalleImage` function from the `PowerShellAI` module to generate images from text descriptions using the DALL-E model.

## Prerequisites

Ensure that you have the `PowerShellAI` module installed and have set your OpenAI API key in your environment or PowerShell session.

## GenerateImageFromDescription.ps1

The `GenerateImageFromDescription.ps1` script takes a text description and generates an image using the DALL-E model. By default, the script saves the generated image to a temporary file path and outputs this path.

Modify the `$description` variable in the script to change the description used to generate the image.

## Running the Script

Run the script in a PowerShell console:

```powershell
.\GenerateImageFromDescription.ps1
```

After execution, the script will provide the path to the generated image file, which you can then view or use as needed.
