$Script:OpenAIKey = $null

#OpenAI URI definitions (module scope):
$Script:OpenAIBaseURI               = 'https://api.openai.com/v1'
$Script:OpenAICompletionsURI        = '{0}/completions' -f $OpenAIBaseURI
$Script:OpenAIEditsURI              = '{0}/edits' -f $OpenAIBaseURI
$Script:OpenAIImagesGenerationsURI  = '{0}/images/generations' -f $OpenAIBaseURI
$Script:OpenAIModelsURI             = '{0}/models' -f $OpenAIBaseURI
$Script:OpenAIModerationsURI        = '{0}/moderations' -f $OpenAIBaseURI

foreach ($directory in @('Public', 'Private')) {
    Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1" | ForEach-Object { . $_.FullName }
}
