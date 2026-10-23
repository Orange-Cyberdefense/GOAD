param (
    [string]$box_name,
    [string]$name_private_vswitch
)


$adapter = Get-VMNetworkAdapter -VMName $box_name -Name "GOAD_INTERNAL" -ErrorAction SilentlyContinue
if ($null -eq $adapter) {
    Add-VMNetworkAdapter -VMName $box_name -Name "GOAD_INTERNAL" -SwitchName $name_private_vswitch
} else {
    Write-Host "[!] Netwerkadapter GOAD_INTERNAL already exists on VM '$box_name'." -ForegroundColor Cyan
    Connect-VMNetworkAdapter -VMName $box_name -Name "GOAD_INTERNAL" -SwitchName $name_private_vswitch
}
