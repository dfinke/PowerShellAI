# Start with a guess at how long this API call will take
$script:DefaultResponseTimeSeconds = 10
$script:EndpointResponseTimeSeconds = @{}
$script:SupportedHosts = @("ConsoleHost")

function Reset-APIEstimatedResponseTimes {
    $script:DefaultResponseTimeSeconds = 10
    $script:EndpointResponseTimeSeconds = @{}    
}

function Get-APIEstimatedResponseTime {
    param (
        [string] $Method,
        [string] $Uri
    )

    $endpointResponseTimeKey = $Method + $Uri
    $estimatedResponseTime = $script:EndpointResponseTimeSeconds[$endpointResponseTimeKey]

    if($null -eq $estimatedResponseTime -or $estimatedResponseTime -lt $script:DefaultResponseTimeSeconds) {
        $estimatedResponseTime = $script:DefaultResponseTimeSeconds
    }

    return $estimatedResponseTime
}

function Set-APIResponseTime {
    param (
        [string] $Method,
        [string] $Uri,
        [int] $ResponseTimeSeconds
    )

    $endpointResponseTimeKey = $Method + $Uri
    $script:EndpointResponseTimeSeconds[$endpointResponseTimeKey] = $ResponseTimeSeconds
}

function Test-HostSupportsRestMethodWithProgress {
    # Check if the current host meets all the requirements to be able to send the restmethod to the background
    
    if($script:SupportedHosts -notcontains (Get-Host).Name) {
        return $false
    }

    $currentLocation = Get-Location
    if($currentLocation.Provider.Name -ne "FileSystem") {
        return $false
    }

    if($null -ne [System.Net.WebRequest]::DefaultWebProxy.Address -or $null -ne $env:HTTP_PROXY) {
        return $false
    }

    return $true
}

function Invoke-RestMethodWithProgress {
    param (
        [hashtable] $Params,
        $ProgressActivity = "Thinking..."
    )

    # Some hosts can't support background jobs. It's best to opt-in to this feature by using a list of supported hosts
    if(-not (Test-HostSupportsRestMethodWithProgress)) {
        return Invoke-RestMethod @Params
    }

    $estimatedResponseTime = Get-APIEstimatedResponseTime -Method $Params["Method"] -Uri $Params["Uri"]

    try {
        try { [Console]::CursorVisible = $false }
        catch [System.IO.IOException] { <# unit tests don't have a console #> }

        Push-Location -StackName "RestMethodWithProgress"
        $currentLocation = Get-Location
        if($currentLocation.Path -ne $currentLocation.ProviderPath) {
            Set-Location $currentLocation.ProviderPath
        }
        
        $job = Start-Job {
            $restParameters = $using:Params
            $response = Invoke-RestMethod @restParameters
            return @{
                Response = $response
            }
        }

        $start = Get-Date
        
        while($job.State -eq "Running") {
            $percent = ((Get-Date) - $start).TotalSeconds / $estimatedResponseTime * 100
            
            # Slow the progress towards the end of the progress bar because the api is a bit all over the show for response times, this makes sure the bar doesn't fill up linearly
            $logPercent = [int][math]::Min([math]::Max(1, $percent * [math]::Log(1.5)), 100)
            $status = "$logPercent% Completed"
            if($logPercent -eq 100) {
                $status = "API is taking longer than expected"
            }
            Write-Progress -Id 1 -Activity $ProgressActivity -Status $status -PercentComplete $logPercent
            Start-Sleep -Milliseconds 50
        }
        Write-Progress -Id 1 -Activity $ProgressActivity -Completed

        # If Invoke-RestMethod failed in the job rethrow this up to the caller so it's like a normal web error
        if($job.State -eq "Failed") {
            throw $job.ChildJobs[0].JobStateInfo.Reason
        }

        Set-APIResponseTime -Method $Params["Method"] -Uri $Params["Uri"] -ResponseTimeSeconds ((Get-Date) - $start).TotalSeconds

        return (Receive-Job $job).Response
    } catch {
        throw $_
    } finally {
        Pop-Location -StackName "RestMethodWithProgress" -ErrorAction "SilentlyContinue"
        if($null -ne $job) {
            Stop-Job $job -ErrorAction "SilentlyContinue"
            Remove-Job $job -Force -ErrorAction "SilentlyContinue"
        }
        try { [Console]::CursorVisible = $true }
        catch [System.IO.IOException] { <# unit tests don't have a console #> }
    }
}