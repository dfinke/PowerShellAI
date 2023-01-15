function CustomReadHost {
    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Yes, run the code'    
    $no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'No, do not run the code'

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $no)

    $message = 'Run the code?'
    $host.ui.PromptForChoice($null, $message, $options, 1)
}