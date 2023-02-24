function Get-OpenAIModerationsURI {
    <#
        .Synopsis
        Base url for OpenAI Moderations API
    #>

    (Get-OpenAIBaseRestURI) + '/moderations'
}
