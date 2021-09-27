Remove-GPLink -Name "StarkWallpaper" -Target "OU=North,OU=kingdoms,DC=sevenkingdoms,DC=local" -erroraction 'silentlycontinue'

#if (!(Get-ItemPropertyValue -Path "HKCU:\Control Panel\Desktop\" -Name "Wallpaper")) { Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value "c:\windows\web\wallpaper\windows\img0.jpg"  }
#

$gpo_exist=Get-GPO -Name "Remove-StarkWallpaper" -erroraction ignore
if ($gpo_exist) {
Remove-GPO -Name "Remove-StarkWallpaper"
}

New-GPO -Name "Remove-StarkWallpaper"-comment "Remove StarkWallpaper"
New-GPLink -Name "Remove-StarkWallpaper" -Target "OU=North,OU=kingdoms,DC=sevenkingdoms,DC=local"

Set-GPPrefRegistryValue -Name "Remove-StarkWallpaper" -Context User -Action Delete -Key "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System"

Set-GPPrefRegistryValue -Name "Remove-StarkWallpaper" -Context User -Action Delete -Key "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\CurrentVersion"

