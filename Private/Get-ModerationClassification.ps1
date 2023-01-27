
function Get-ModerationClassification {
    [CmdletBinding()]
    <#
        .SYNOPSIS
        Used to check whether content complies with OpenAI's content policy.
        
        .DESCRIPTION
        This function utilizes the moderation endpoint to check whether content complies with OpenAI's content policy. If content is identified that the OpenAI policy prohibits, action can be taken. For instance, the content can be filtered. For additional information about the moderation endpoint api, refer to https://beta.openai.com/docs/api-reference/moderations. For additional information about the content policy, refer to https://beta.openai.com/docs/usage-policies/content-policy
        
        .PARAMETER $line
        Default is OpenAIKey stored as an environmental variable. Otherwise, Api token is a secure string.

        .PARAMETER openAiToken
        OpenAI API Token as a secure string.  By default, $env:OpenAIKey will be utilized.
    #>
    param (
        [ValidateNotNullOrEmpty()]
        [string]$prompt,
        [securestring]$openAiToken = (ConvertTo-SecureString -String $($env:OpenAIKey) -AsPlainText)
    )

    if($null -eq $openAiToken){
        throw 'OpenAI API key not found. Please set $env:OpenAIKey to your OpenAI API key or pass in the key as a Secure String'
    }

    $body = @{input="$($prompt)"} | ConvertTo-Json -Compress

    Write-Progress -Activity "Codex Moderations" -Status "Getting moderation results..."
    try {
        $moderation = Invoke-RestMethod -Uri "https://api.openai.com/v1/moderations" -ContentType 'application/json' -Authentication Bearer -Token $openAiToken -Body $body -Method Post
    }
    catch {
        Write-Error $_
        Write-Verbose -Verbose $body
    }

    if($moderation){

        Write-Progress -Activity "Codex Moderation" -Status "Analyzing results from endpoint..."

        if($moderation.results.flagged -eq $true){
            $moderationModel = $moderation.model
            $categories = $moderation.results.categories | Get-Member -MemberType NoteProperty | Select-Object -Property Name
            $violatedCategories = $null
            $categories | ForEach-Object{
                $categoryName = $_.Name
                if($null -eq $violatedCategories -and $moderation.results.categories.$($categoryName) -eq $true){
                    $violatedCategories = $categoryName
                }elseif($moderation.results.categories.$($categoryName) -eq $true){
                    $violatedCategories = $violatedCategories + ", " + $categoryName
                }
            }

            Write-Progress -Activity "Codex Moderation" -Completed
            Write-Warning "The model, $($moderationModel), has classified the content as having violated OpenAI's content policy in the following categories: $($categories)"
            $userInput = CustomContinueReadHost 
            if($userInput -eq 1){
                throw "Process has stopped."
                Exit
            }
        }

        Write-Progress -Activity "Codex Moderation" -Completed

    }else {
        Write-Progress -Activity "Codex Moderation" -Completed
        Write-Warning "Content could not be validated."
    }
}