function Get-DalleImage {
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
            if (-not $PSBoundParameters.ContainsKey('Size')) {
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