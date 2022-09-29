#!powershell

# Copyright: (c) 2018, Jordan Borean
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy

$ErrorActionPreference = "Stop"

$params = Parse-Args -arguments $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false
$diff = Get-AnsibleParam -obj $params -name "_ansible_diff" -type "bool" -default $false

$gpo = Get-AnsibleParam -obj $params -name "gpo" -type "str" -failifempty $true
$name = Get-AnsibleParam -obj $params -name "name" -type "str" -failifempty $true
$path = Get-AnsibleParam -obj $params -name "path" -type "str" -failifempty $true
$state = Get-AnsibleParam -obj $params -name "state" -type "str" -default "present" -validateset "absent", "disabled", "present"
$type = Get-AnsibleParam -obj $params -name "type" -type "str" -default "string" -ValidateSet "string", "expandstring", "binary", "dword", "multistring", "qword"
$value = Get-AnsibleParam -obj $params -name "value"

$result = @{
    changed = $false
}
if ($diff) {
    $result.diff = @{
        before = ""
        after = ""
    }
}

if ($state -in @("absent", "disabled") -and $null -ne $value) {
    Fail-Json -obj $result -message "Cannot set a value with state=$state"
}

Function Convert-RegExportHexStringToByteArray {
    <#
    .SYNOPSIS
    Simplified version of Convert-HexStringToByteArray from
    https://cyber-defense.sans.org/blog/2010/02/11/powershell-byte-array-hex-convert
    Expects a hex in the format you get when you run reg.exe export and
    converts to a byte array so powershell can modify binary registry entries

    .PARAMETER String
    The string to convert in the format hex:be,ef,be,ef,be,ef,be,ef,be,ef
    #>#
    param(
        [Parameter(Mandatory=$true)][String]$String
    )
    # Remove 'hex:' from the front of the string if present
    $String = $String.ToLower() -replace '^hex\:',''

    # Remove whitespace and any other non-hex crud.
    $String = $String -replace '[^a-f0-9\\,x\-\:]',''

    # Turn commas into colons
    $String = $String -replace ',',':'

    # Maybe there's nothing left over to convert...
    if ($String.Length -eq 0) {
        return ,@()
    }

    # Split string with or without colon delimiters.
    if ($String.Length -eq 1) {
        return ,@([System.Convert]::ToByte($String,16))
    } elseif (($String.Length % 2 -eq 0) -and ($String.IndexOf(":") -eq -1)) {
        return ,@($String -split '([a-f0-9]{2})' | ForEach-Object { if ($_) {[System.Convert]::ToByte($_,16)}})
    } elseif ($String.IndexOf(":") -ne -1) {
        return ,@($String -split ':+' | ForEach-Object {[System.Convert]::ToByte($_,16)})
    } else {
        return ,@()
    }
}

Function Get-DiffValueString {
    <#
    .SYNOPSIS
    Converts an input value to a string for use in a diff comparison.

    .PARAMETER Type
    The registry value type that is used to display the appropriate string
    output.

    .PARAMETER Value
    The value to stringify.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("string", "expandstring", "binary", "dword", "multistring", "qword")]
        [String]$Type,
        [Parameter(Mandatory=$true)]$Value
    )
    if ($Type -eq "binary") {
        $hex_values = [System.Collections.ArrayList]@()
        foreach ($dec_value in $Value) {
            $hex_values.Add("0x$("{0:x2}" -f $dec_value)") > $null
        }
        $diff_value = "[$($hex_values -join ", ")]"
    } elseif ($Type -eq "dword") {
        $diff_value = "0x$("{0:x8}" -f $Value)"
    } elseif ($Type -eq "qword") {
        $diff_value = "0x$("{0:x16}" -f $Value)"
    } elseif ($Type -eq "multistring") {
        $diff_value = "[$($Value -join ", ")]"
    } else {
        if ($Value.EndsWith([char]0x0000)) {
            $Value = $Value.Substring(0, $Value.Length - 1)
        }

        $diff_value = $Value
    }

    return $diff_value
}

# Convert the input value to the type specified
if ($type -eq "binary") {
    if ($null -eq $value) {
        $value = ""
    }

    if ($value -is [String]) {
        $value = [byte[]](Convert-RegExportHexStringToByteArray -String $value)
    } elseif ($value -is [Int]) {
        if ($value -gt 255) {
            Fail-Json -obj $result -message "Cannot convert binary value '$value' to byte array, please specify this value as a yaml byte array or comma separated hex value string"
        }
        $value = [byte[]]@([byte]$value)
    } elseif ($value -is [Array]) {
        $value = [byte[]]$value
    }
} elseif ($type -in @("dword", "qword")) {
    # dword's and dword's don't allow null values, set to 0
    if ($null -eq $value) {
        $value = 0
    }

    if ($value -is [String]) {
        # If the value is a string we need to convert it to an unsigned int64
        # it needs to be unsigned as Ansible passes in an unsigned value while
        # powershell uses a signed value type. The value will then be converted
        # below
        $value = [UInt64]$value
    }

    if ($type -eq "dword") {
        if ($value -gt [UInt32]::MaxValue) {
            Fail-Json -obj $result -message "value cannot be larger than 0xffffffff when type is dword"
        } elseif ($value -gt [Int32]::MaxValue) {
            # When dealing with larger int32 (> 2147483647 or 0x7FFFFFFF) PowerShell
            # automatically converts it to a signed int64. We need to convert this to
            # signed int32 by parsing the hex string value.
            $value = "0x$("{0:x}" -f $value)"
        }
        $value = [Int32]$value
    } else {
        if ($value -gt [UInt64]::MaxValue) {
            Fail-Json -obj $result -message "value cannot be larger than 0xffffffffffffffff when type is qword"
        } elseif ($value -gt [Int64]::MaxValue) {
            $value = "0x$("{0:x}" -f $value)"
        }
        $value = [Int64]$value
    }
} elseif ($type -in @("string", "expandstring")) {
    # A null string or expandstring must be empty quotes
    if ($null -eq $value) {
        $value = ""
    }
} elseif ($type -eq "multistring") {
    # Convert the value for a multistring to a String[] array
    if ($null -eq $value) {
        $value = [String[]]@()
    } elseif ($value -isnot [Array]) {
        $new_value = New-Object -TypeName String[] -ArgumentList 1
        $new_value[0] = $value.ToString([CultureInfo]::InvariantCulture)
        $value = $new_value
    } else {
        $new_value = New-Object -TypeName String[] -ArgumentList $value.Count
        foreach ($entry in $value) {
            $new_value[$value.IndexOf($entry)] = $entry.ToString([CultureInfo]::InvariantCulture)
        }
        $value = $new_value
    }
}

$existing_value = Get-GPRegistryValue -Name $gpo -Key $path -ValueName $name -ErrorAction SilentlyContinue
if ($null -ne $existing_value -and $diff) {
    $result.diff.before = @{
        disabled = ($existing_value.PolicyState -eq "Delete")
        gpo = $gpo
        name = $existing_value.ValueName
        path = $existing_value.KeyPath
        type = $existing_value.Type.ToString()
        value = (Get-DiffValueString -Type $existing_value.Type.ToString() -Value $existing_value.Value)
    }
}

if ($state -eq "absent") {
    if ($null -ne $existing_value) {
        Remove-GPRegistryValue -Name $gpo -Key $path -ValueName $name -WhatIf:$check_mode > $null
        $result.changed = $true
    }
} else {
    $common_params = @{
        Name = $gpo
        Key = $path
        ValueName = $name
        WhatIf = $check_mode
    }

    if ($null -eq $existing_value) {
        if ($state -eq "disabled") {
            $common_params.Disable = $true
        } else {
            $common_params.Value = $value
            $common_params.Type = $type
        }

        Set-GPRegistryValue @common_params > $null
        $result.changed = $true
    } elseif ($state -eq "disabled") {
        if ($existing_value.PolicyState -ne "Delete") {
            Set-GPRegistryValue -Disable @common_params > $null
            $result.changed = $true
        }
    } elseif ($existing_value.PolicyState -eq "Delete") {
        # If the previous state was disabled then we need to remove that value
        # before we set the new one as it will cause double ups on the key
        Remove-GPRegistryValue @common_params > $null
        Set-GPRegistryValue -Value $value -Type $type @common_params > $null
        $result.changed = $true
    } else {
        $before_type = $existing_value.Type.ToString()
        $before_value = Get-DiffValueString -Type $before_type -Value $existing_value.Value
        $new_value = Get-DiffValueString -Type $type -Value $value

        if (($before_value -ne $new_value) -or ($before_type -ne $type)) {
            Set-GPRegistryValue -Value $value -Type $type @common_params > $null
            $result.changed = $true
        }
    }

    if ($diff) {
        if ($check_mode) {
            # in check mode we won't have access to the new values so just used the inputs
            $result.diff.after = @{
                disabled = ($state -eq "disabled")
                gpo = $gpo
                name = $name
                path = $path
                type = $type
                value = (Get-DiffValueString -Type $type -Value $value)
            }
        } else {
            $new_value = Get-GPRegistryValue -Name $gpo -Key $path -ValueName $name
            $result.diff.after = @{
                disabled = ($new_value.PolicyState -eq "Delete")
                gpo = $gpo
                name = $new_value.ValueName
                path = $new_value.KeyPath
                type = $new_value.Type.ToString()
                value = (Get-DiffValueString -Type $new_value.Type.ToString() -Value $new_value.Value)
            }
        }
    }
}

Exit-Json -obj $result

