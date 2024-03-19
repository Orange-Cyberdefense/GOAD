#!powershell

#Requires -Module Ansible.ModuleUtils.Legacy

# https://learn.microsoft.com/en-us/powershell/module/configurationmanager/new-cmboundary
# sccm_boundary:
#   name: "boundary name"
#   type: IPSubNet/ADSite/IPv6Prefix/IPRange/VPN
#   value: "value" (ex: "172.16.50.0/24" / "Default-First-Site-Name" / "10.255.255.0-10.255.255.255")
#   site_code: "code"
#   state: "present" (absent/present)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$params = Parse-Args -arguments $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false

$name = Get-AnsibleParam -obj $params -name "name" -type "str" -failifempty $true
$boundary_type = Get-AnsibleParam -obj $params -name "type" -type "str" -failifempty $true -validateset "IPSubNet","ADSite" ,"IPv6Prefix","IPRange","VPN"
$boundary_value = Get-AnsibleParam -obj $params -name "value" -type "str" -failifempty $true
$siteCode = Get-AnsibleParam -obj $params -name "site_code" -type "str" -failifempty $true
$state = Get-AnsibleParam -obj $params -name "state" -type "str" -default "present" -validateset "absent", "present"
$server = Get-AnsibleParam -obj $params -name "server" -type "str" -failifempty $true

$result = @{
    changed = $false
}

Import-Module $env:SMS_ADMIN_UI_PATH.Replace("\bin\i386","\bin\configurationmanager.psd1") -force
$sc = Get-PSDrive -PSProvider CMSITE
if ($null -eq $sc) {
    New-PSDrive -Name $siteCode -PSProvider "CMSite" -Root $server -Description "primary site"
}
Set-Location ($siteCode +":")

# search by name
($boundary = Get-CMBoundary -BoundaryName $name) | out-null

if ($state -eq "absent" -and $null -ne $boundary) {
    $boundary | Remove-CMBoundary -WhatIf:$check_mode | out-null
    $result.changed = $true
} elseif ($state -eq "present") {
    $update = $true
    if ($null -eq $boundary) {
        try {
            New-CMBoundary -DisplayName $name -BoundaryType $boundary_type -Value $boundary_value -WhatIf:$check_mode | out-null
        } catch {
            Set-CMBoundary -DisplayName $name -BoundaryType $boundary_type -Value $boundary_value -WhatIf:$check_mode | out-null
        }
        $result.changed = $true
    }
}

Exit-Json -obj $result