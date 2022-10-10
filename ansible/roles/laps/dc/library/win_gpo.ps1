#!powershell

# Copyright: (c) 2018, Jordan Borean
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy

$ErrorActionPreference = "Stop"

$params = Parse-Args -arguments $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false

$description = Get-AnsibleParam -obj $params -name "description" -type "str"
$name = Get-AnsibleParam -obj $params -name "name" -type "str" -failifempty $true
$state = Get-AnsibleParam -obj $params -name "state" -type "str" -default "present" -validateset "absent", "present"

$result = @{
    changed = $false
}

$gpo = Get-GPO -Name $name -ErrorAction SilentlyContinue
if ($state -eq "absent" -and $null -ne $gpo) {
    $result.id = $gpo.Id
    $result.path = $gpo.Path
    $gpo | Remove-GPO -WhatIf:$check_mode
    $result.changed = $true
} elseif ($state -eq "present") {
    if ($null -eq $gpo) {
        $new_params = @{
            Name = $name
            WhatIf = $check_mode
        }
        if ($null -ne $description) {
            $new_params.Comment = $description
        }
        $gpo = New-GPO @new_params
        $result.changed = $true
    }

    # When creating a GPO in check mode these values won't be set
    if ($null -ne $gpo) {
        $result.id = $gpo.Id
        $result.path = $gpo.Path
    } else {
        $result.id = [System.Guid]::Empty.ToString()
        $result.path = "cn=$($result.id),cn=policies,cn=system,dc=check,dc=domain"
    }
}

Exit-Json -obj $result