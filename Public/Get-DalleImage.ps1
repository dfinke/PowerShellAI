function Get-DalleImage {
    <#
        .SYNOPSIS
        Get a DALL-E image from the OpenAI API.

        .DESCRIPTION
        Given a description, the model will return an image.

        .PARAMETER Description
        The description to generate an image for.

        .PARAMETER Size
        The size of the image to generate. Defaults to 256.

        .PARAMETER Raw
        If set, the raw response will be returned. Otherwise, the image will be saved to a temporary file and the path to that file will be returned.

        .EXAMPLE
        Get-DalleImage -Description "A cat sitting on a table"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Description,
        [ValidateSet('256', '512', '1024')]
        $Size = 256,
        [Switch]$Raw
    )

    try {
        $targetSize = switch ($Size) {
            256 { '256x256' }
            512 { '512x512' }
            1024 { '1024x1024' }
        }

        $body = [ordered]@{
            prompt = $Description
            size   = $targetSize
        } | ConvertTo-Json -Compress


        $splatParams = @{
            Uri         = $Script:OpenAIImagesGenerationsURI
            Body        = $body
            Method      = 'Post'
            ErrorAction = 'Stop'
        }
        $result = Invoke-OpenAIAPI @splatParams

        if ($Raw) {
            return $result
        } else {
            $DestinationPath = [IO.Path]::GetTempFileName().Replace('.tmp', '.png')
            Invoke-RestMethod $result.data.url -OutFile $DestinationPath
            $DestinationPath
        }
    } catch {
        Write-Error -ErrorRecord $_ -ErrorAction $ErrorActionPreference
    }
}
