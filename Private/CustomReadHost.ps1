function CustomReadHost {
    <#
        .SYNOPSIS
        Custom Read-Host function that allows for a default value and a prompt message.

        .EXAMPLE
        CustomReadHost 
    #>

    $Run = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Yes, run the code'    
    $Explain = New-Object System.Management.Automation.Host.ChoiceDescription '&Explain', 'Explain the code'
    $Copy = New-Object System.Management.Automation.Host.ChoiceDescription '&Copy', 'Copy to clipboard'    
    $Nothing = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'No, do not run the code'

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($Run, $Explain, $Copy, $Nothing)

    $message = 'Run the code? You can also choose additional actions'
    $host.ui.PromptForChoice($null, $message, $options, 3)
}