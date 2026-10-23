param ([String] $ip_range)


try{
	Remove-VMSwitch -Name GOAD_INTERNAL_$($ip_range) -ErrorAction Stop -Force -Confirm:$false
	Get-NetNat GOAD_NAT_$($ip_range) -ErrorAction SilentlyContinue | Remove-NetNat -ErrorAction SilentlyContinue -Confirm:$false
}
catch {
	Write-Host "Virtual Switch is still in use or already removed."
}
