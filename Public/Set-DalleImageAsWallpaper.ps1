function Set-DalleImageAsWallpaper {
    <#
        .SYNOPSIS
            Sets a DALL-E image as the desktop background
        .DESCRIPTION
            Sets a DALL-E image as the Windows desktop background
        .EXAMPLE
        Set-DalleImageAsBackground "A picture of a cat"

        .EXAMPLE
        Set-DalleImageAsBackground "A picture of a cat" -Size 512

    #>
    param(
        [Parameter(Mandatory)]
        $Description,
        [ValidateSet('256', '512', '1024')]
        $Size = 256
    )

    if ($IsMacOS -or $IsLinux) {
        Write-Error "Can only change the wallpaper on Windows"
        return
    }

    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
    
public class Params
{
    [DllImport("User32.dll",CharSet=CharSet.Unicode)]
    public static extern int SystemParametersInfo (Int32 uAction,
                                                    Int32 uParam,
                                                    String lpvParam,
                                                    Int32 fuWinIni);
}
"@    
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
      
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent

    $Image = Get-DalleImage $Description -Size $Size
    
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name wallpaperstyle -Value 0 # centered
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name tilewallpaper -Value 0 # centered

    $null = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}