#!powershell

# Copyright: (c) 2018, Jordan Borean
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy

$ErrorActionPreference = "Stop"

$params = Parse-Args -arguments $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false

$attributes = Get-AnsibleParam -obj $params -name "attributes"
$context = Get-AnsibleParam -obj $params -name "context" -type "str" -default "default" -validateset "configuration", "default", "root_domain", "schema"
# $domain_server = Get-AnsibleParam -obj $params -name "domain_server" -type "str"
# $domain_username = Get-AnsibleParam -obj $params -name "domain_username" -type "str"
# $domain_password = Get-AnsibleParam -obj $params -name "domain_password" -type "str" -failifempty ($null -ne $domain_username)
$may_contain = Get-AnsibleParam -obj $params -name "may_contain" -type "list"
$name = Get-AnsibleParam -obj $params -name "name" -type "str" -failifempty $true
$type = Get-AnsibleParam -obj $params -name "type" -type "str" -default "attribute" -validateset "attribute", "class"
$update_schema = Get-AnsibleParam -obj $params -name "update_schema" -type "bool" -default $false

$result = @{
    changed = $false
}

Import-Module -Name ActiveDirectory

$common_params = @{}
# if ($null -ne $domain_server) {
#     $common_params.Server = $domain_server
# }
# if ($null -ne $domain_username) {
#     $sec_pass = ConvertTo-SecureString -String $domain_password -AsPlainText -Force
#     $common_params.Credential = (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $domain_username, $sec_pass)
# }

$root_dse = Get-ADRootDSE -Properties schemaNamingContext, rootDomainNamingContext @common_params
$context = switch($context) {
    "configuration" { $root_dse.configurationNamingContext }
    "default" { $root_dse.defaultNamingContext }
    "root_domain" { $root_dse.rootDomainNamingContext }
    "schema" { $root_dse.schemaNamingContext }
}

try {
    $search_filter = { DistinguishedName -eq $name -or ldapDisplayName -eq $name }
    $existing_obj = Get-ADObject -SearchBase $context -Filter $search_filter -Properties * @common_params
} catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    $existing_obj = $null
}

if ($null -eq $existing_obj) {
    $ldap_type = switch ($type) {
        "attribute" { "attributeSchema" }
        "class" { "classSchema" }
    }
    New-ADObject -Name $name -Path $context -OtherAttributes $attributes `
        -Type $ldap_type -WhatIf:$check_mode @common_params
    $result.changed = $true
} elseif ($null -ne $attributes) {
    # Compare the input attributes with the existing attributes and change if required
    $replacements = @{}
    $additions = @{}
    $clear = [System.Collections.Generic.List`1[String]]@()

    foreach ($attribute_entry in $attributes.GetEnumerator()) {
        $attribute_key = $attribute_entry.Key
        $attribute_value = $attribute_entry.Value

        $existing_value = $existing_obj.$attribute_key
        if ($null -eq $attribute_value -and $null -ne $existing_value) {
            $clear.Add($attribute_key) > $null
        } elseif ($null -ne $attribute_value -and $null -eq $existing_value) {
            $additions.$attribute_key = $attribute_value
        } elseif ($attribute_value -ne $existing_value) {
            $replacements.$attribute_key = $attribute_value
        }
    }

    if ($replacements.Count -gt 0 -or $additions.Count -gt 0 -or $clear.Count -gt 0) {
        $set_params = $common_params.Clone()
        if ($replacements.Count -gt 0) {
            $set_params.Replace = $replacements
        }
        if ($additions.Count -gt 0) {
            $set_params.Add = $additions
        }
        if ($clear.Count -gt 0) {
            $set_params.Clear = $clear.ToArray()
        }

        Set-ADObject -Identity $existing_obj.ObjectGuid @set_params
        $result.changed = $true
    }
}

# Now set the mayContain attributes, we do a last check on existing_obj in case we are in check mode
if ($null -ne $may_contain -and $null -ne $existing_obj) {
    foreach ($may_contain_entry in $may_contain) {
        if (-not $existing_obj.mayContain.Contains($may_contain_entry)) {
            Set-ADObject -Identity $existing_obj.ObjectGuid -Add @{ mayContain = $may_contain_entry } @common_params > $null
            $result.changed = $true
        }
    }
}

# Reload the schema cache if a change occurred
if ($result.changed -and $update_schema) {
    $ctor_args = [System.Collections.Generic.List`1[String]]@("LDAP://$($root_dse.dnsHostName)/RootDSE")
    if ($null -ne $domain_username) {
        $ctor_args.Add($domain_username) > $null
        $ctor_args.Add($domain_password) > $null
    }
    $dse = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $ctor_args.ToArray()
    try {
        $dse.Put("SchemaUpdateNow", 1)
        if (-not $check_mode) {
            $dse.SetInfo()
        }
    } finally {
        $dse.Dispose()
    }
}

Exit-Json -obj $result

