function Get-DalleImage {
    <#
    .SYNOPSIS
    Get a DALL-E image from the OpenAI API
    
    .DESCRIPTION
    Given a description, the model will return an image based on the DALL-E version specified.

    .PARAMETER Description
    The text description of the desired image.
    
    .PARAMETER Size
    For DALL-E 2, the Size parameter specifies the dimensions of the square image to generate. It must be one of '256', '512', or '1024', indicating the length of the sides of the square in pixels. Defaults to '1024'.

    For DALL-E 3, instead of this parameter, 'Orientation' is used to determine the aspect ratio and size of the image.

    .PARAMETER Orientation
    Used with DALL-E 3 to specify the orientation and aspect ratio of the generated image.
    - 'landscape' will produce an image of size '1792x1024'.
    - 'portrait' will produce an image of size '1024x1792'.
    - 'square' will produce an image of size '1024x1024'.
    The default is 'landscape'.

    .PARAMETER Quality
    Specific to DALL-E 3, determines the quality of the generated image. Can be 'standard' or 'hd', where 'hd' corresponds to higher detail. Defaults to 'hd'.

    .PARAMETER Style
    Specific to DALL-E 3, affects the style of the image. Can be 'vivid' for more dramatic and hyper-real images or 'natural' for more true-to-life images. Defaults to 'natural'.

    .PARAMETER Raw
    When specified, the command will return the raw API response. If omitted, the resulting image will be saved to a temporary file and its path returned.

    .PARAMETER NoProgress
    When specified, progress indicators are not displayed during the operation. Progress indicators can also be suppressed by setting $ProgressPreference to 'SilentlyContinue'.

    .EXAMPLE
    Get-DalleImage -Description "A cat sitting on a table"
    
    Generates an image for "A cat sitting on a table" using the default model version and settings, and returns the path to the saved image file.
#>
    
    [CmdletBinding(DefaultParameterSetName = 'Dalle3')]
    param(
        [Parameter(Mandatory)]
        [string]$Description,

        [ValidateSet('256', '512', '1024')]
        [string]$Size = '1024',

        [Parameter(ParameterSetName = 'Dalle3')]
        [ValidateSet('landscape', 'portrait', 'square')]
        [string]$Orientation = 'landscape',

        [Parameter(ParameterSetName = 'Dalle3')]
        [ValidateSet('hd', 'standard')]
        [string]$Quality = 'hd',

        [Parameter(ParameterSetName = 'Dalle3')]
        [ValidateSet('vivid', 'natural')]
        [string]$Style = 'natural',

        [Parameter()]
        [ValidateSet('2', '3')]
        [string]$ModelVersion = '3',

        [Switch]$Raw,
        [Switch]$NoProgress
    )

    begin {
        # Adjust parameter values and defaults for DALL-E 2
        if ($ModelVersion -eq '2') {
            # Set model-specific default parameters
            if (-not $PSBoundParameters.ContainsKey('Size')) {
                $Size = '1024'
            }
            # Remove DALL-E 3 specific parameters
            $PSBoundParameters.Remove('Quality')
            $PSBoundParameters.Remove('Style')
            $PSBoundParameters.Remove('Orientation')
            # Adjust size format for DALL-E 2
            $targetSize = "$Size`x$Size"
        }
        elseif ($ModelVersion -eq '3') {
            if (-not $PSBoundParameters.ContainsKey('Orientation')) {
                $Orientation = 'landscape'
            }
            # format size according to $Orientation
            $targetSize = switch ($Orientation) {
                'landscape' { '1792x1024' }
                'portrait' { '1024x1792' }
                'square' { '1024x1024' }
            }
        }

        # Prepare the request body
        $body = @{
            prompt = $Description
            size   = $targetSize
            model  = "dall-e-$ModelVersion"
        }

        # Add additional parameters for DALL-E 3
        if ($ModelVersion -eq '3') {
            $body['quality'] = $Quality
            $body['style'] = $Style
        }
    }

    process {
        $bodyJson = $body | ConvertTo-Json

        $result = Invoke-OpenAIAPI -Uri (Get-OpenAIImagesGenerationsURI) -Body $bodyJson -Method Post

        if ($Raw) {
            return $result
        }
        else {
            $destinationPath = [IO.Path]::GetTempFileName() -replace '\.tmp$', '.png'
            $params = @{
                Uri     = $result.data.url
                OutFile = $destinationPath
            }
            Invoke-RestMethodWithProgress -Params $params -NoProgress:$NoProgress
            return $destinationPath
        }
    }
}