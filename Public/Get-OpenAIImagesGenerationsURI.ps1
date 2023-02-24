
function Get-OpenAIImagesGenerationsURI {
    <#
        .Synopsis
        Base url for OpenAI Images Generations API
    #>

    (Get-OpenAIBaseRestURI) + '/images/generations'
}
