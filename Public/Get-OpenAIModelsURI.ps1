function Get-OpenAIModerationsURI {
    <#
        .SYNOPSIS
        Base url for OpenAI Moderations API.
    #>

    (Get-OpenAIBaseRestURI) + '/moderations'
}
