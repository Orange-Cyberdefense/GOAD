#!powershell

#Requires -Module Ansible.ModuleUtils.Legacy

# https://learn.microsoft.com/en-us/powershell/module/configurationmanager/new-cmboundary
# sccm_boundary_group:
#   name: "boundary group name"
#   server: sccmserver.myad.lab
#   site_code: "code" (optional)
#   state: "present" (absent/present)

$ErrorActionPreference = "Stop"

$params = Parse-Args -arguments $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false

$name = Get-AnsibleParam -obj $params -name "name" -type "str" -failifempty $true
$server = Get-AnsibleParam -obj $params -name "server" -type "str" -failifempty $true
$siteCode = Get-AnsibleParam -obj $params -name "site_code" -type "str"
$state = Get-AnsibleParam -obj $params -name "state" -type "str" -default "present" -validateset "absent", "present"

$result = @{
    changed = $false
}

Import-Module $env:SMS_ADMIN_UI_PATH.Replace("\bin\i386","\bin\configurationmanager.psd1") -force

if ($null -eq $siteCode) {
    $sc = Get-PSDrive -PSProvider CMSITE
    $siteCode = $sc.name
}
Set-Location ($siteCode +":")

$boundaryGroup = Get-CMBoundaryGroup -Name $name -ErrorAction SilentlyContinue

if ($state -eq "absent" -and $null -ne $boundaryGroup) {
    $boundaryGroup | Remove-CMBoundaryGroup -WhatIf:$check_mode
    $result.changed = $true
} elseif ($state -eq "present") {
    if ($null -eq $boundaryGroup) {
        New-CMBoundaryGroup -Name $name -AddSiteSystemServerName $server -DefaultSiteCode $sitecode -WhatIf:$check_mode
        $result.changed = $true
    }
}


Exit-Json -obj $result