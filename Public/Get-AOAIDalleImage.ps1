function Get-AOAIDalleImage { 
    <#
        .SYNOPSIS
        Get a DALL-E image from the Azure OpenAI API
        
        .DESCRIPTION
        Given a description, the model will return an image

        .PARAMETER Description
        The description to generate an image for

        .PARAMETER Size
        The size of the image to generate. Defaults to 1024

        .PARAMETER Images
        The number of images to generate. Defaults to 1

        .PARAMETER ApiVersion
        API Version to use. Defaults to 2023-06-01-preview

        .PARAMETER Raw
        If set, the raw response will be returned. Otherwise, the image will be saved to a temporary file and the path to that file will be returned

        .EXAMPLE
        Get-AOAIDalleImage -Description "a painting of the Sydney Opera house in the style of Rembrant on a sunny day"
    #>
    [CmdletBinding()]
    param(        
        [Parameter(Mandatory)]
        [string]$Description,
        [ValidateSet('256', '512', '1024')]
        $Size = 1024,
        $Images = 1,
        [Switch]$Raw,
        [string]$apiVersion = "2023-06-01-preview"
    )

    $targetSize = switch ($Size) {
        256 { '256x256' }
        512 { '512x512' }
        1024 { '1024x1024' }     
    }

    $body = [ordered]@{
        prompt = $Description
        size   = $targetSize
        n      = $Images
    } | ConvertTo-Json

    # Header for authentication
    $headers = @{
        'api-key' = $env:AzureOpenAIKey
    }

    if ($null -ne (Get-AzureOpenAIOptions).Endpoint) {
        # Invoke-OpenAIAPI -Uri "$(Get-AzureOpenAIOptions).Endpoint)/openai/images/generations:submit?api-version=$($apiVersion)"
        $baseEndPoint = (Get-AzureOpenAIOptions).Endpoint
        $AOAIDalleURL = "$($baseEndPoint)/openai/images/generations:submit?api-version=$($apiVersion)"

        Invoke-RestMethod -Uri $AOAIDalleURL -Headers $headers -Body $body -Method Post -ContentType 'application/json' -ResponseHeadersVariable submissionHeaders
        $operation_location = $submissionHeaders['operation-location'][0]

        $status = ''
        while ($status -ne 'succeeded') {
            Start-Sleep -Seconds 1
            $response = Invoke-RestMethod -Uri $operation_location -Headers $headers
            if ($response.status -eq 'failed') {
                Write-Error "Image Generation Failed with: $($response.error.code) and message: $($response.error.message)"
                exit 
            }
            $status = $response.status
        }

        # Retrieve the generated image
        $generatedImages = @()

        # Set the directory for the stored image
        $image_dir = Join-Path -Path $pwd -ChildPath 'images'

        # If the directory doesn't exist, create it
        if (-not(Resolve-Path $image_dir -ErrorAction Ignore)) {
            New-Item -Path $image_dir -ItemType Directory
        }

        $i = 1
        foreach ($generatedImage in $response.result.data.url) {
            $image_url = $generatedImage
            # Initialize the image path (note the filetype should be png)
            $ts = (get-date -Uformat %T).ToString().Replace(":", "-")
            $image_path = Join-Path -Path $image_dir -ChildPath "$($ts)-$($i).png"
            
            if ($Raw) {
                return (Invoke-WebRequest -Uri $image_url).content 
            }
            else {
                Invoke-WebRequest -Uri $image_url -OutFile $image_path  # download the image
                $generatedImages += $image_path
                $i = $i + 1
            }
        }
        if (!$Raw) {
            return $generatedImages
        }
    }
    else {
        throw 'Please set your Azure OpenAI EndPoint by using the Set-AzureOpenAI cmdlet'
    }
}