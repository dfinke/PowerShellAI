
function Get-OpenAIImagesGenerationsURI {
    <#
        .SYNOPSIS
        Base url for OpenAI Images Generations API.
    #>

    (Get-OpenAIBaseRestURI) + '/images/generations'
}
