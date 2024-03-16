#!powershell

#Requires -Module Ansible.ModuleUtils.Legacy

# https://learn.microsoft.com/en-us/powershell/module/configurationmanager/new-cmboundary
#  sccm_boundary_to_boundarygroup:
#   boundary_name: "boundary name"
#   boundary_group: "boundary group name"
#   site_code: "code" (optional)
#   state: "present" (absent/present)

$ErrorActionPreference = "Stop"

$params = Parse-Args -arguments $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false

$boundaryName = Get-AnsibleParam -obj $params -name "boundary_name" -type "str" -failifempty $true
$boundaryGroupName = Get-AnsibleParam -obj $params -name "boundary_group" -type "str" -failifempty $true
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

$boundary_group_list = Get-CMBoundary -BoundaryGroupName $boundaryGroupName -ErrorAction SilentlyContinue

$boundary = Get-CMBoundary -BoundaryName $boundaryName -ErrorAction SilentlyContinue
$boundaryGroup = Get-CMBoundaryGroup -Name $boundaryGroupName -ErrorAction SilentlyContinue

$present = $false
foreach  ($b in $boundary_group_list){
    if ($b.DisplayName -eq $boundary.DisplayName){
        $present = $true
        break
    }
}

if ($state -eq "absent" -and $present) {
    $boundaryGroup | Remove-CMBoundaryFromGroup -BoundaryName $boundaryName -WhatIf:$check_mode
    $result.changed = $true
} elseif ($state -eq "present") {
    if (-Not $present) {
        Add-CMBoundaryToGroup -BoundaryName $boundaryName -BoundaryGroupName $boundaryGroupName -WhatIf:$check_mode
        $result.changed = $true
    }
}


Exit-Json -obj $result