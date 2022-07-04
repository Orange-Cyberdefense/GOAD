#requires -Version 5.0 -Modules ActiveDirectory

Function Get-RandomHex {
param ([int]$Length)
    $Hex = '0123456789ABCDEF'
    [string]$Return = $null
    For ($i=1;$i -le $length;$i++) {
        $Return += $Hex.Substring((Get-Random -Minimum 0 -Maximum 16),1)
    }
    Return $Return
}

Function IsUniqueOID {
param ($cn,$TemplateOID,$Server,$ConfigNC)
    $Search = Get-ADObject -Server $Server `
        -SearchBase "CN=OID,CN=Public Key Services,CN=Services,$ConfigNC" `
        -Filter {cn -eq $cn -and msPKI-Cert-Template-OID -eq $TemplateOID}
    If ($Search) {$False} Else {$True}
}

Function New-TemplateOID {
Param($Server,$ConfigNC)
    <#
    OID CN/Name                                                         [10000000-99999999].[32 hex characters (MD5hash)]
    OID msPKI-Cert-Template-OID    [Forest base OID].[1000000-99999999].[10000000-99999999]  <--- second number same as first number in OID name
    #>
    do {
        $OID_Part_1 = Get-Random -Minimum 10000000 -Maximum 99999999
        $OID_Part_2 = Get-Random -Minimum 10000000 -Maximum 99999999
        $OID_Part_3 = Get-RandomHex -Length 32
        $OID_Forest = Get-ADObject -Server $Server `
            -Identity "CN=OID,CN=Public Key Services,CN=Services,$ConfigNC" `
            -Properties msPKI-Cert-Template-OID |
            Select-Object -ExpandProperty msPKI-Cert-Template-OID
        $msPKICertTemplateOID = "$OID_Forest.$OID_Part_1.$OID_Part_2"
        $Name = "$OID_Part_2.$OID_Part_3"
    } until (IsUniqueOID -cn $Name -TemplateOID $msPKICertTemplateOID -Server $Server -ConfigNC $ConfigNC)
    Return @{
        TemplateOID  = $msPKICertTemplateOID
        TemplateName = $Name
    }
}


<#
.SYNOPSIS
Returns the properties of either a single or all Active Directory Certificate Template(s).
.DESCRIPTION
Returns the properties of either a single or list of Active Directory Certificate Template(s)
depending on whether a DisplayName parameter was passed.
.PARAMETER DisplayName
Name of an AD CS template to retrieve.
.PARAMETER Server
FQDN of Active Directory Domain Controller to target for the operation.
When not specified it will search for the nearest Domain Controller.
.EXAMPLE
PS C:\> Get-ADCSTemplate
.EXAMPLE
PS C:\> Get-ADCSTemplate -DisplayName PowerShellCMS
.EXAMPLE
PS C:\> Get-ADCSTemplate | Sort-Object Name | ft Name, Created, Modified
.EXAMPLE
PS C:\> ###View template permissions
(Get-ADCSTemplate pscms).nTSecurityDescriptor
(Get-ADCSTemplate pscms).nTSecurityDescriptor.Sddl
(Get-ADCSTemplate pscms).nTSecurityDescriptor.Access
ConvertFrom-SddlString -Sddl (Get-ADCSTemplate pscms).nTSecurityDescriptor.sddl -Type ActiveDirectoryRights
.NOTES
Requires Enterprise Administrator permissions, since this touches the AD Configuration partition.
#>
Function Get-ADCSTemplate {
param(
    [parameter(Position=0)]
    [string]
    $DisplayName,

    [string]
    $Server = (Get-ADDomainController -Discover -ForceDiscover -Writable).HostName[0]
)
    If ($PSBoundParameters.ContainsKey('DisplayName')) {
        $LDAPFilter = "(&(objectClass=pKICertificateTemplate)(displayName=$DisplayName))"
    } Else {
        $LDAPFilter = '(objectClass=pKICertificateTemplate)'
    }

    $ConfigNC     = $((Get-ADRootDSE -Server $Server).configurationNamingContext)
    $TemplatePath = "CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigNC"
    Get-ADObject -SearchScope Subtree -SearchBase $TemplatePath -LDAPFilter $LDAPFilter -Properties * -Server $Server
}


<#
.SYNOPSIS
Adds an ACL to an Active Directory Certificate template.
.DESCRIPTION
Adds an ACL to an Active Directory Certificate template.
Default permission is read (without the Enroll or AutoEnroll switches).
.PARAMETER DisplayName
Name of an AD CS template to receive the ACL.
.PARAMETER Server
FQDN of Active Directory Domain Controller to target for the operation.
When not specified it will search for the nearest Domain Controller.
.PARAMETER Type
ACL type: Allow or Deny
.PARAMETER Identity
String or string array of Active Directory identities (users or groups)
.PARAMETER Enroll
Set the Enroll permission
.PARAMETER AutoEnroll
Set the AutoEnroll permission
.EXAMPLE
PS C:\> Set-ADCSTemplateACL -DisplayName PowerShellCMS -Type Allow -Identity 'CONTOSO\Servers Group' -Enroll
.EXAMPLE
PS C:\> Set-ADCSTemplateACL -DisplayName PowerShellCMS -Type Allow -Identity 'CONTOSO\Servers Group','CONTOSO\Workstations Group' -Enroll -AutoEnroll
.EXAMPLE
PS C:\> Set-ADCSTemplateACL -DisplayName PowerShellCMS -Type Deny -Identity 'CONTOSO\Servers Group'
.NOTES
Requires Enterprise Administrator permissions, since this touches the AD Configuration partition.
#>
Function Set-ADCSTemplateACL {
param(
    [parameter(Mandatory)]
    [string]$DisplayName,
    [string]$Server = (Get-ADDomainController -Discover -ForceDiscover -Writable).HostName[0],
    [ValidateSet('Allow','Deny')]
    [string]$Type = 'Allow',
    [string[]]$Identity,
    [switch]$Enroll,
    [switch]$AutoEnroll
)
    ## Potential issue here that the AD: drive may not be targetting the selected DC in the -SERVER parameter
    $TemplatePath        = "AD:\" + (Get-ADCSTemplate -DisplayName $DisplayName -Server $Server).DistinguishedName
    $acl                 = Get-ACL $TemplatePath
    $InheritedObjectType = [GUID]'00000000-0000-0000-0000-000000000000'
    ForEach ($Group in $Identity) {
        $account = New-Object System.Security.Principal.NTAccount($Group)
        $sid     = $account.Translate([System.Security.Principal.SecurityIdentifier])

        If ($Type -ne 'Deny') {
            # Read, but only if Allow
            $ObjectType = [GUID]'00000000-0000-0000-0000-000000000000'
            $ace        = New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
                $sid, 'GenericRead', $Type, $ObjectType, 'None', $InheritedObjectType
            $acl.AddAccessRule($ace)
        }

        If ($Enroll) {
            $ObjectType = [GUID]'0e10c968-78fb-11d2-90d4-00c04f79dc55'
            $ace        = New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
                $sid, 'ExtendedRight', $Type, $ObjectType, 'None', $InheritedObjectType
            $acl.AddAccessRule($ace)
        }

        If ($AutoEnroll) {
            $ObjectType = [GUID]'a05b8cc2-17bc-4802-a710-e7c15ab866a2'
            $ace        = New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
                $sid, 'ExtendedRight', $Type, $ObjectType, 'None', $InheritedObjectType
            $acl.AddAccessRule($ace)
        }
    }
    Set-ACL $TemplatePath -AclObject $acl
}


<#
.SYNOPSIS
Returns a JSON string with the properties of an Active Directory certificate template.
.DESCRIPTION
Returns a JSON string with the properties of an Active Directory certificate template.
By default returns only the PKI-related properties of the object. These properties are
sufficient for passing to the New-ADCSTemplate function.
.PARAMETER DisplayName
DisplayName for the certificate to export.
.PARAMETER Server
FQDN of Active Directory Domain Controller to target for the operation.
When not specified it will search for the nearest Domain Controller.
.PARAMETER Detailed
Includes all ADObject properties of the template. These are not required for 
use with the New-ADCSTemplate function.
.NOTES
C.R.U.D. AD CS Template Operations in this module.
No longer have to use the cert GUI to clone a template and build a new one.
Create one manually the first time in the GUI, then export it to JSON.
Pass the JSON in your new environment (file, here string, DSC, etc.) to build from scratch.
Requires Enterprise Administrator permissions, since this touches the AD Configuration partition.
.EXAMPLE
PS C:\> Export-ADCSTemplate -DisplayName PowerShellCMS
.EXAMPLE
PS C:\> Export-ADCSTemplate -DisplayName PowerShellCMS -Detailed
.EXAMPLE
### Backup all the templates to JSON
md C:\ADCSTemplates -ErrorAction SilentlyContinue
cd C:\ADCSTemplates
(Get-ADCSTemplate).name | ForEach-Object {"Exporting $_"; Export-ADCSTemplate -DisplayName $_ | Out-File .\$_.json -Force}
dir
.EXAMPLE
PS C:\> New-ADCSTemplate -DisplayName PowerShellCMS-NEW -JSON (Export-ADCSTemplate -DisplayName PowerShellCMS-OLD)
#>
Function Export-ADCSTemplate {
param(
    [parameter(Mandatory)]
    [string]$DisplayName,
    [string]$Server = (Get-ADDomainController -Discover -ForceDiscover -Writable).HostName[0],
    [switch]$Detailed   # Detailed output is not required for export/import. Use for documentation/backup purposes.
)
    If ($Detailed) {
        Get-ADCSTemplate -DisplayName $DisplayName -Server $Server |
            ConvertTo-Json
    } Else {
        Get-ADCSTemplate -DisplayName $DisplayName -Server $Server |
            Select-Object -Property name, displayName, objectClass, flags, revision, *pki* |
            ConvertTo-Json
    }
}

<#
.SYNOPSIS
Creates a new Active Directory Certificate Services template based on a JSON export.
.DESCRIPTION
Creates a new Active Directory Certificate Services template based on a JSON export.
Optionally can permission and publish the template (best practice).
.PARAMETER DisplayName
DisplayName for the certificate template to create. This does not have to match
the original name of the exported template.
.PARAMETER JSON
JSON string output from Export-ADCSTemplate. Defines the template to create.
Can be retrieved from file using Get-Content -Raw.
.PARAMETER Server
FQDN of Active Directory Domain Controller to target for the operation.
When not specified it will search for the nearest Domain Controller.
.PARAMETER Identity
String or string array of Active Directory identities (users or groups).
This is optional for permissioning the template.
.PARAMETER AutoEnroll
Default permission is Read and Enroll. Use this switch to also grant AutoEnroll 
to the identity. Only used when Identity parameter is used.
.PARAMETER Publish
Publish the template to *ALL* Certificate Authority issuers. Use with caution
in production environments. You may want to manually publish to only specific
Certificate Authorities in production. In a lab this is ideal.
.NOTES
This function does not use the official (complicated) API for PKI management.
Instead it creates the exact same AD objects that are generated by the API,
including AD forest-specific OIDs.
Requires Enterprise Administrator permissions, since this touches the AD Configuration partition.
.EXAMPLE
PS C:\> New-ADCSTemplate -DisplayName PowerShellCMS -JSON (Get-Content .\pscms.json -Raw)
.EXAMPLE
PS C:\> New-ADCSTemplate -DisplayName PowerShellCMS -JSON (Get-Content .\pscms.json -Raw) -Server dc1.contoso.com -Identity G_DSCNodes -AutoEnroll -Publish

# From a client configured for AD CS autoenrollment:
$Req = @{
    Template          = 'PowerShellCMS'
    Url               = 'ldap:'
    CertStoreLocation = 'Cert:\LocalMachine\My'
}
Get-Certificate @Req
# Note: If you have the Carbon module installed, it conflicts with Get-Certificate native cmdlet.

$DocEncrCert = (dir Cert:\LocalMachine\My -DocumentEncryptionCert | Sort-Object NotBefore)[-1]
Protect-CmsMessage -To $DocEncrCert -Content "Encrypted with my new cert from the new template!"
.EXAMPLE
PS C:\> New-ADCSTemplate -DisplayName PowerShellCMS-NEW -JSON (Export-ADCSTemplate -DisplayName PowerShellCMS-OLD)
#>
Function New-ADCSTemplate {
param(
    [parameter(Mandatory)]
    [string]$DisplayName,   # name in JSON export is ignored
    [parameter(Mandatory)]
    [string]$JSON,
    [string]$Server = (Get-ADDomainController -Discover -ForceDiscover -Writable).HostName[0],
    [string[]]$Identity, # = "$((Get-ADDomain).NetBIOSName)\Domain Computers",
    [switch]$AutoEnroll,
    [switch]$Publish
)
    ### Put GroupName and AutoEnroll into a parameter set

    # Manually import AD module to get AD: drive used later for permissions
    Import-Module ActiveDirectory -Verbose:$false

    $ConfigNC = $((Get-ADRootDSE -Server $Server).configurationNamingContext)

    #region CREATE OID
    <#
    CN                              : 14891906.F2AC4390685318BD1D950A66EDB50FF4
    DisplayName                     : TemplateNameHere
    DistinguishedName               : CN=14891906.F2AC4390685318BD1D950A66EDB50FF4,CN=OID,CN=Public Key Services,CN=Services,CN=Configuration,DC=contoso,DC=com
    dSCorePropagationData           : {1/1/1601 12:00:00 AM}
    flags                           : 1
    instanceType                    : 4
    msPKI-Cert-Template-OID         : 1.3.6.1.4.1.311.21.8.11489019.14294623.5588661.594850.12204198.151.6616009.14891906
    Name                            : 14891906.F2AC4390685318BD1D950A66EDB50FF4
    ObjectCategory                  : CN=ms-PKI-Enterprise-Oid,CN=Schema,CN=Configuration,DC=contoso,DC=com
    ObjectClass                     : msPKI-Enterprise-Oid
    #>
    $OID = New-TemplateOID -Server $Server -ConfigNC $ConfigNC
    $TemplateOIDPath = "CN=OID,CN=Public Key Services,CN=Services,$ConfigNC"
    $oa = @{
	    'DisplayName' = $DisplayName
	    'flags' = [System.Int32]'1'
	    'msPKI-Cert-Template-OID' = $OID.TemplateOID
    }
    New-ADObject -Path $TemplateOIDPath -OtherAttributes $oa -Name $OID.TemplateName -Type 'msPKI-Enterprise-Oid' -Server $Server
    #endregion

    #region CREATE TEMPLATE
    # https://docs.microsoft.com/en-us/powershell/dsc/securemof#certificate-requirements
    # https://blogs.technet.microsoft.com/option_explicit/2012/04/09/pki-certificates-and-the-x-509-standard/
    # https://technet.microsoft.com/en-us/library/cc776447(v=ws.10).aspx
    $import = $JSON | ConvertFrom-Json
    $oa = @{ 'msPKI-Cert-Template-OID' = $OID.TemplateOID }
    ForEach ($prop in ($import | Get-Member -MemberType NoteProperty)) {
        Switch ($prop.Name) {
            { $_ -in 'flags',
                    'msPKI-Certificate-Name-Flag',
                    'msPKI-Enrollment-Flag',
                    'msPKI-Minimal-Key-Size',
                    'msPKI-Private-Key-Flag',
                    'msPKI-Template-Minor-Revision',
                    'msPKI-Template-Schema-Version',
                    'msPKI-RA-Signature',
                    'pKIMaxIssuingDepth',
                    'pKIDefaultKeySpec',
                    'revision'
            } { $oa.Add($_,[System.Int32]$import.$_); break }

            { $_ -in 'msPKI-Certificate-Application-Policy',
                    'pKICriticalExtensions',
                    'pKIDefaultCSPs',
                    'pKIExtendedKeyUsage',
                    'msPKI-RA-Application-Policies'
            } { $oa.Add($_,[Microsoft.ActiveDirectory.Management.ADPropertyValueCollection]$import.$_); break }

            { $_ -in 'pKIExpirationPeriod',
                    'pKIKeyUsage',
                    'pKIOverlapPeriod'
            } { $oa.Add($_,[System.Byte[]]$import.$_); break }

        }
    }
    $TemplatePath = "CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigNC"
    New-ADObject -Path $TemplatePath -OtherAttributes $oa -Name $DisplayName.Replace(' ','') `
        -DisplayName $DisplayName -Type pKICertificateTemplate -Server $Server
    #endregion

    #region PERMISSIONS
    ## Potential issue here that the AD: drive may not be targetting the selected DC in the -SERVER parameter
    If ($PSBoundParameters.ContainsKey('Identity')) {
        If ($AutoEnroll) {
            Set-ADCSTemplateACL -DisplayName $DisplayName -Server $Server -Type Allow -Identity $Identity -Enroll -AutoEnroll
        } Else {
            Set-ADCSTemplateACL -DisplayName $DisplayName -Server $Server -Type Allow -Identity $Identity -Enroll
        }
    }
    #endregion

    #region ISSUE
    If ($Publish) {
        ### WARNING: Issues on all available CAs. Test in your environment.
        $EnrollmentPath = "CN=Enrollment Services,CN=Public Key Services,CN=Services,$ConfigNC"
        $CAs = Get-ADObject -SearchBase $EnrollmentPath -SearchScope OneLevel -Filter * -Server $Server
        ForEach ($CA in $CAs) {
            Set-ADObject -Identity $CA.DistinguishedName -Add @{certificateTemplates=$DisplayName.Replace(' ','')} -Server $Server
        }
    }
    #endregion
}


<#
.SYNOPSIS
Removes a certificate template from Active Directory.
.DESCRIPTION
Removes the template from any issuers where it is published.
Removes the template itself.
Removes the unique OID object of the template.
.PARAMETER DisplayName
DisplayName for the certificate template to delete.
.PARAMETER Server
FQDN of Active Directory Domain Controller to target for the operation.
When not specified it will search for the nearest Domain Controller.
.EXAMPLE
PS C:\> Remove-ADCSTemplate -DisplayName PowerShellCMS
.EXAMPLE
PS C:\> (Get-ADCSTemplate).name | Where-Object {$_ -like "PowerShellCMS*"} | ForEach-Object {Remove-ADCSTemplate -DisplayName $_ -Verbose}
.NOTES
Use with caution!
Requires Enterprise Administrator permissions, since this touches the AD Configuration partition.
#>
Function Remove-ADCSTemplate {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
param(
    [parameter(Mandatory)]
    [string]$DisplayName,
    [string]$Server = (Get-ADDomainController -Discover -ForceDiscover -Writable).HostName[0]
)
    if ($pscmdlet.ShouldProcess($DisplayName, 'Remove certificate template')) {
        $ConfigNC = $((Get-ADRootDSE -Server $Server).configurationNamingContext)

        $Template = Get-ADCSTemplate -DisplayName $DisplayName -Server $Server

        #region REMOVE ISSUE IF IT EXISTS
        $EnrollmentPath = "CN=Enrollment Services,CN=Public Key Services,CN=Services,$ConfigNC"
        $CAs = Get-ADObject -SearchBase $EnrollmentPath -SearchScope OneLevel -Filter * -Server $Server
        ForEach ($CA in $CAs) {
            Set-ADObject -Identity $CA.DistinguishedName -Remove @{certificateTemplates=$Template.cn} -Server $Server -Confirm:$false
        }
        #endregion

        #region REMOVE TEMPLATE
        Remove-ADObject -Identity $Template.distinguishedName -Server $Server -Confirm:$false
        #endregion

        #region REMOVE OID
        $TemplateOIDPath = "CN=OID,CN=Public Key Services,CN=Services,$ConfigNC"
        Get-ADObject -SearchBase $TemplateOIDPath -LDAPFilter "(DisplayName=$DisplayName)" -Server $Server | Remove-ADObject -Confirm:$false
        #endregion
    }
}


<#
.SYNOPSIS
Maps a PowerShell drive to the Active Directory Certificate Services location.
.DESCRIPTION
Maps a PowerShell drive to the Active Directory Certificate Services location 
of the Configuration partition under CN=Public Key Services,CN=Services,... .
The new drive is ADCS:. This is purely for convenience of checking the objects
updated by functions in the ADCSTemplate module.
.PARAMETER Server
FQDN of Active Directory Domain Controller to target for the operation.
When not specified it will search for the nearest Domain Controller.
.EXAMPLE
PS C:\> New-ADCSDrive
PS C:\> Set-Location ADCS:
.EXAMPLE
### Explore templates with drive
New-ADCSDrive
Get-PSDrive
cd ADCS:
dir

# List templates
cd '.\CN=Certificate Templates'
dir
dir | fl *
dir *WebServer*

# list CAs
cd \
cd '.\CN=Enrollment Services'
dir
cd C:
.NOTES
Requires Enterprise Administrator permissions, since this touches the AD Configuration partition.
#>
Function New-ADCSDrive {
param(
    [string]$Server = (Get-ADDomainController -Discover -ForceDiscover -Writable).HostName[0]
)
    $ConfigNC     = $((Get-ADRootDSE -Server $Server).configurationNamingContext)
    New-PSDrive -Name ADCS -PSProvider ActiveDirectory -Root "CN=Public Key Services,CN=Services,$ConfigNC" -Server $Server -Scope Global
}


Export-ModuleMember -Function *-ADCS*
