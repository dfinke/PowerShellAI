function CustomReadHost {
    <#
        .SYNOPSIS
        Custom Read-Host function that allows for a default value and a prompt message.

        .EXAMPLE
        CustomReadHost
    #>

    $yes = [Management.Automation.Host.ChoiceDescription]::new('&Yes', 'Yes, run the code')
    $no = [Management.Automation.Host.ChoiceDescription]::new('&No', 'No, do not run the code')

    $options = [Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    $message = 'Run the code?'
    $Host.UI.PromptForChoice($null, $message, $options, 1)
}
