function Invoke-AIErrorHelper {
    <#
        .SYNOPSIS
            Inspect the last error record and offer some suggestions on how to resolve it          
        .DESCRIPTION
            Invoke-AIErrorHelper is a function that uses the OpenAI GPT-3 API to provide insights into errors that occur in a powershell script.
        .EXAMPLE
            Invoke-AIErrorHelper    
    #>
    [CmdletBinding()]
    [alias("ieh")]
    param()

    $lastError = $global:Error[0]

    if ($null -ne $lastError) {
        $message = $lastError.Exception.Message
        $errorType = $lastError.FullyQualifiedErrorId

        $promptPrefix = "Provide a detailed summary of the following powershell error and offer a potential powershell solution (using code if it's a confident solution):"

        $errorDetails = "${errorType}`n$message"
        
        $response = (Get-GPT3Completion -prompt "$promptPrefix`n`n$errorDetails" -max_tokens 2048).Trim()
        Write-Host -ForegroundColor Cyan "$errorDetails`n"
        Write-Host -ForegroundColor DarkGray $response
    }
    else {
        Write-Host "No error has occurred"
    }
}