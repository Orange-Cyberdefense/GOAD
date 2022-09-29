#!powershell

# Copyright: (c) 2018, Jordan Borean
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module Ansible.ModuleUtils.SID

$ErrorActionPreference = "Stop"

$params = Parse-Args -arguments $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false

$path = Get-AnsibleParam -obj $params -name "path" -type "str" -failifempty $true
$aces = Get-AnsibleParam -obj $params -name "aces" -type "list" -failifempty $true
$state = Get-AnsibleParam -obj $params -name "state" -type "str" -default "present" -validateset "absent", "present"

$result = @{
    changed = $false
}

Import-Module -Name ActiveDirectory

$common_ad_parameters = @{}

Function ConvertTo-SchemaGuid {
    param(
        [Parameter(Mandatory=$true)]$Value,
        [Parameter(Mandatory=$true)][String]$Name,
        [Parameter(Mandatory=$true)][Int32]$Entry,
        [Hashtable]$CommonParameters
    )

    if ($null -eq $Value.$Name) {
        return [System.Guid]::Empty
    }
    $raw_value = $Value.$Name

    try {
        $guid = [System.Guid]::Parse($raw_value)
        return $guid
    } catch [System.FormatException] {}  # not a GUID, we try and convert by scanning AD

    $root_schema = (Get-ADRootDSE @CommonParameters).schemaNamingContext
    $id_object = Get-ADObject -Filter { Name -eq $raw_value } -SearchBase $root_schema -Property schemaIDGUID @CommonParameters
    if ($null -eq $id_object) {
        Fail-Json -obj $result -message "Failed to convert ace entry option $Entry $Name to object guid '$($raw_value)'"
    } else {
        $schema_guid = New-Object -TypeName System.Guid -ArgumentList @(,$id_object.schemaIDGUID)
        return $schema_guid
    }
}

# Convert the input ace entries to a format we can compare against the real ACEs
$valid_access_rights = [System.Enum]::GetNames([System.DirectoryServices.ActiveDirectoryRights])
$valid_inheritance_types = [System.Enum]::GetNames([System.DirectoryServices.ActiveDirectorySecurityInheritance])

$raw_aces = [System.Collections.ArrayList]@()
foreach ($ace in $aces) {
    $identity_sid_str = Convert-ToSID -account_name $ace.account

    if ($null -eq $ace.rights) {
        $msg = "Found undefined ace entry index $($raw_aces.Count) rights. Valid options $($valid_access_rights -join ", ")"
        Fail-Json -obj $result -message $msg
    }
    $ace_rights = $ace.rights
    if ($ace_rights -isnot [Array]) {
        $ace_rights = $ace_rights.ToString().Split(",").Trim()
    }

    foreach ($ace_right in $ace_rights) {
        if ($ace_right -notin $valid_access_rights) {
            $msg = "Invalid value for ace entry index $(raw_aces.Count) rights, '$ace_right'. Valid options $($valid_access_rights -join ", ")"
            Fail-Json -obj $result -message $msg
        }
    }
    $ace_rights = [System.Enum]::Parse([System.DirectoryServices.ActiveDirectoryRights], $ace_rights -join ", ", $true)

    $access = switch($ace.access) {
        "allow" { [System.Security.AccessControl.AccessControlType]::Allow }
        "deny" { [System.Security.AccessControl.AccessControlType]::Deny }
        default { Fail-Json -obj $result -message "Invalid value for ace entry index $($raw_aces.Count) access, '$access'. Valid options allow, deny" }
    }

    if ($ace.inheritance_type -notin $valid_inheritance_types) {
        $msg = "Invalid value for ace entry index $($raw_aces.Count) inheritance_type, '$($ace.inheritance_type)'. Valid options $($valid_inheritance_types -join ", ")"
        Fail-Json -obj $result -message $msg
    }
    $inheritance_type = [System.DirectoryServices.ActiveDirectorySecurityInheritance]$ace.inheritance_type

    $object_type = ConvertTo-SchemaGuid -Value $ace `
        -Name "object_type" -Entry $raw_aces.Length `
        -CommonParameters $common_ad_parameters

    $inherited_object_type = ConvertTo-SchemaGuid -Value $ace `
        -Name "inherited_object_type" -Entry $raw_aces.Count `
        -CommonParameters $common_ad_parameters

    $raw_ace = New-Object -TypeName System.DirectoryServices.ActiveDirectoryAccessRule -ArgumentList @(
        (New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList $identity_sid_str),
        $ace_rights,
        $access,
        $object_type,
        $inheritance_type
        $inherited_object_type
    )
    $raw_aces.Add($raw_ace) > $null
}

# Now get the actual DACL for the AD object specified
$ad_object = Get-ADObject -Identity $path -Properties nTSecurityDescriptor @common_ad_parameters

$actual_sd = $ad_object.nTSecurityDescriptor
$actual_dacl = $actual_sd.GetAccessRules($true, $false, [System.Security.Principal.SecurityIdentifier])
$comparison_props = @(
    "ActiveDirectoryRights",
    "InheritanceType",
    "ObjectType",
    "InheritedObjectType",
    "AccessControlType",
    "IdentityReference"
)

foreach ($raw_ace in $raw_aces) {
    $found_ace = $null

    foreach ($actual_ace in $actual_dacl) {
        $mismatched = $false
        foreach ($comparison_prop in $comparison_props) {
            if ($actual_ace.$comparison_prop -ne $raw_ace.$comparison_prop) {
                $mismatched = $true
                break
            }
        }
        if (-not $mismatched) {
            $found_ace = $actual_ace
            break
        }
    }

    if ($state -eq "absent" -and $null -ne $found_ace) {
        $ad_object.nTSecurityDescriptor.RemoveAccessRuleSpecific($found_ace)
        $result.changed = $true
    } elseif ($state -eq "present" -and $null -eq $found_ace) {
        $ad_object.nTSecurityDescriptor.AddAccessRule($raw_ace)
        $result.changed = $true
    }
}

if ($result.changed -eq $true) {
    $replacements = @{
        nTSecurityDescriptor = $ad_object.nTSecurityDescriptor
    }
    Set-ADObject -Identity $ad_object.ObjectGUID -Replace $replacements -WhatIf:$check_mode @common_ad_parameters
}

Exit-Json -obj $result