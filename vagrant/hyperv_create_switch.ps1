param ([String] $ip_range)

# Check if virtual switch exists and create if needed
try {
    Write-Host -ForegroundColor Yellow  "[+] Does GOAD_INTERNAL_$($ip_range) switch exist?"
    Get-VMSwitch -Name GOAD_INTERNAL_$ip_range -ErrorAction Stop | select -exp Name
    Write-Host -ForegroundColor Green  "[+] Yes!"
}
catch [Microsoft.HyperV.PowerShell.VirtualizationException] {
    Write-Host -ForegroundColor Red  "[+] No, creating the switch"
    New-VMSwitch -Name GOAD_INTERNAL_$ip_range -SwitchType Internal
    Write-Host "[+] Waiting for virtual network adapter to appear..."
    $adapter = $null
    while (-not $adapter) {
	    Start-Sleep -Seconds 2
	    $adapter = Get-NetAdapter -Name "*GOAD_INTERNAL_$($ip_range)*" -ErrorAction SilentlyContinue
	}
}

# check the IP configuration of the virtual network adapter (host side)
Write-Host "[+] Checking IP configuration"
$Adapter = Get-NetAdapter -Name "*GOAD_INTERNAL_$($ip_range)*" | Select-Object -First 1
$IpAddress = (Get-NetIPAddress -InterfaceAlias $Adapter.InterfaceAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress 

if ($IpAddress -eq "$($ip_range).1") {
    Write-Host "[+] IP Address of virtual adapter is correct" -ForegroundColor Green
} else {
    Write-Host "[+] Setting IPAdress of virtual network adapter" -ForegroundColor Yellow
    Remove-NetIPAddress -InterfaceAlias $Adapter.InterfaceAlias -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
    New-NetIPAddress -InterfaceAlias $Adapter.InterfaceAlias -IPAddress "$($ip_range).1" -PrefixLength 24
}

# Recreate the NAT 
try{
    Write-Host "[+] Checking if GOAD_NAT_$($ip_range) Exists?"
    Get-NetNat GOAD_NAT_$($ip_range) -ErrorAction Stop
    Write-Host -ForegroundColor Green  "[+] Yes!"
}
catch {
    Write-Host -ForegroundColor Red  "[+] No, creating the NAT"
    New-NetNat -Name GOAD_NAT_$($ip_range) -InternalIPInterfaceAddressPrefix "$($ip_range).0/24"
}
