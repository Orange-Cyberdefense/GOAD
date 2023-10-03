Install-WindowsFeature -Name GPMC
$gpo_exist = Get-GPO -Name "StarkWallpaper" -erroraction ignore

if ($gpo_exist) {
    # Do nothing
    #Remove-GPO -Name "StarkWallpaper"
    #Remove the link of the GPO Remove-StarkWallpaper if it exists
    #Remove-GPLink -Name "StarkWallpaper" -Target "DC=north,DC=sevenkingdoms,DC=local" -erroraction 'silentlycontinue'
} else {
    New-GPO -Name "StarkWallpaper" -comment "Change Wallpaper"
    New-GPLink -Name "StarkWallpaper" -Target "DC=north,DC=sevenkingdoms,DC=local"

    #https://www.thewindowsclub.com/set-desktop-wallpaper-using-group-policy-and-registry-editor
    Set-GPRegistryValue -Name "StarkWallpaper" -key "HKEY_CURRENT_USER\Control Panel\Colors" -ValueName Background -Type String -Value "100 175 200"
    #Set-GPPrefRegistryValue -Name "StarkWallpaper" -Context User -Action Create -Key "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName Wallpaper -Type String -Value "C:\tmp\GOAD.png"

    Set-GPRegistryValue -Name "StarkWallpaper" -key "HKEY_CURRENT_USER\Control Panel\Desktop" -ValueName Wallpaper -Type String -Value ""
    #Set-GPPrefRegistryValue -Name "StarkWallpaper" -Context User -Action Create -Key "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName WallpaperStyle -Type String -Value "4"

    Set-GPRegistryValue -Name "StarkWallpaper" -Key "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\CurrentVersion\WinLogon" -ValueName SyncForegroundPolicy -Type DWORD -Value 1

    # Allow samwell.tarly to Edit Settings of the GPO
    # https://learn.microsoft.com/en-us/powershell/module/grouppolicy/set-gppermission?view=windowsserver2022-ps
    Set-GPPermissions -Name "StarkWallpaper" -PermissionLevel GpoEditDeleteModifySecurity -TargetName "samwell.tarly" -TargetType "User"
}