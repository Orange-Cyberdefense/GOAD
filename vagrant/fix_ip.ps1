# vmware bug to set the ip
# see : https://github.com/hashicorp/vagrant/issues/5000#issuecomment-258209286
# @Marshall-Hallenbeck: I changed this to use Get-NetAdapter physical devices since it seemed to work a bit better (doesn't return pseudo loopbacks)
# also, we cannot just hard-code the interface name because not all hosts will have that as the second interface (like mayfly/windows10)

param ([String] $ip)

$name = (Get-NetAdapter -Physical | Where-Object {$_.LinkLayerAddress -ne $null} | Select-Object -First 1).Name
if ($name) {
	Write-Host "Setting IP address of interface $name to $ip"
	& netsh.exe int ip set address $name static $ip 255.255.255.0
}
