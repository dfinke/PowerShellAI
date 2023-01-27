function CustomRunCodeReadHost {
    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Yes, run the code'    
    $no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'No, do not run the code'

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $no)

    $message = 'Run the code?'
    $host.ui.PromptForChoice($null, $message, $options, 1)
}

function CustomContinueReadHost {
    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Yes, continue on with request'
    $no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'No, do not continue with request'

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $no)

    $message = 'Continue with request?'
    $host.ui.PromptForChoice($null, $message, $options, 1)
}