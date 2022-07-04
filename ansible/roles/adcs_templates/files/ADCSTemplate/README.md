Find all code and samples at this location: [https://github.com/GoateePFE/ADCSTemplate/]()

# ADCSTemplate
A PowerShell module for exporting, importing, removing, permissioning, publishing Active Directory Certificate Templates.
It also includes a DSC resource for creating AD CS templates using these functions.
This was built with the intent of using DSC for rapid lab builds, 
but it could also be used in production environments to move templates between AD CS environments.

# Problem
Aren't you tired of using the Active Directory Certificate Services graphical interface to create and publish new certificate templates? Me too! I can build a domain controller and certificate server with DSC, but then I get stuck with manually creating the custom certificate templates for my environment. A popular example is the Document Encryption certificate used for DSC credential encryption and the CMS encryption cmdlets. You probably have some custom certificate templates unique to your company as well. No more right click, duplicate, permission, publish!

# Solution
The ADCSTemplate module contains the following PowerShell functions:
* Export-ADCSTemplate
* Get-ADCSTemplate
* New-ADCSDrive
* New-ADCSTemplate
* Remove-ADCSTemplate
* Set-ADCSTemplateACL

And the following DSC resource:
* ADCSTemplate

# Overview
This is a simple outline of the procedure to export and import your templates.
Yes, you must create it manually at least once.
1. Create your desired template in the AD CS GUI.
2. `Install-Module ADCSTemplate`
3. `Export-ADCSTemplate -DisplayName foo > .\foo.json`
4. Copy the JSON file to your destination environment.
5. `Install-Module ADCSTemplate`
6. `New-ADCSTemplate -DisplayName foo2 -JSON (Get-Content .\foo.json -Raw) -Publish -Identity Contoso\MyGroup`
7. -OR- Use the `ADCSTemplate` DSC Resource with the JSON string data to define the template. This is most easily accomplished using a ConfigurationData block to pass the large string. See the sample provided.

If you want to duplicate an existing template on the same server try this:

```New-ADCSTemplate -DisplayName NewTemplateName -JSON (Export-ADCSTemplate -DisplayName OldTemplateName)```

If you want to export all templates try this:

``` (Get-ADCSTemplate).name | ForEach-Object {"Exporting $_"; Export-ADCSTemplate -DisplayName $_ | Out-File .\$_.json -Force}```

See the module function help texts for many clever use cases for this code, including a bonus function for creating a PSDrive to browse the objects in AD without using the GUI.

See the \Examples directory for
* `Demo.ps1` showing popular use cases of the functions together.
* `Build-ADCS.ps1` DSC example for a full Active Directory domain controller build with Certificate Services and two sample templates.
* `PowerShellCMS.json` a sample JSON output file you can use to create templates for PowerShell Cryptographic Message Syntax cmdlets and encryption credentials in DSC.

# Requirements
* PowerShell 5.x
* Tested on Windows Server 2012 R2
* Tested on Windows Server 2016 (issues with the xActiveDirectory module here, but the ADCSTemplate DSC works just fine)
* Enterprise Administrator rights

# Credits
Created by Ashley McGlone

2017-2018

[@GoateePFE](https://twitter.com/goateepfe)

[http://aka.ms/goateepfe]()


# Get-Help

## Export-ADCSTemplate

### Synopsis
Returns a JSON string with the properties of an Active Directory certificate template.

### Description
Returns a JSON string with the properties of an Active Directory certificate template.
By default returns only the PKI-related properties of the object. These properties are
sufficient for passing to the New-ADCSTemplate function.

### Parameters

-DisplayName <String>
    DisplayName for the certificate to export.
    
    Required?                    true
    Position?                    1
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

-Server <String>
    FQDN of Active Directory Domain Controller to target for the operation.
    When not specified it will search for the nearest Domain Controller.
    
    Required?                    false
    Position?                    2
    Default value                (Get-ADDomainController -Discover -ForceDiscover -Writable).HostName[0]
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

-Detailed [<SwitchParameter>]
    Includes all ADObject properties of the template. These are not required for 
    use with the New-ADCSTemplate function.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

### Notes
C.R.U.D. AD CS Template Operations in this module.
No longer have to use the cert GUI to clone a template and build a new one.
Create one manually the first time in the GUI, then export it to JSON.
Pass the JSON in your new environment (file, here string, DSC, etc.) to build from scratch.
Requires Enterprise Administrator permissions, since this touches the AD Configuration partition.

### Examples
-------------------------- EXAMPLE 1 --------------------------

```
PS C:\> Export-ADCSTemplate -DisplayName PowerShellCMS

```
-------------------------- EXAMPLE 2 --------------------------

```
PS C:\> Export-ADCSTemplate -DisplayName PowerShellCMS -Detailed

```
-------------------------- EXAMPLE 3 --------------------------

```
PS C:\> ### Backup all the templates to JSON
md C:\ADCSTemplates -ErrorAction SilentlyContinue
cd C:\ADCSTemplates
(Get-ADCSTemplate).name | ForEach-Object {"Exporting $_"; Export-ADCSTemplate -DisplayName $_ | Out-File .\$_.json -Force}
dir

```
-------------------------- EXAMPLE 4 --------------------------

```
PS C:\> New-ADCSTemplate -DisplayName PowerShellCMS-NEW -JSON (Export-ADCSTemplate -DisplayName PowerShellCMS-OLD)

```

## Get-ADCSTemplate

### Synopsis
Returns the properties of either a single or all Active Directory Certificate Template(s).

### Description
Returns the properties of either a single or list of Active Directory Certificate Template(s)
depending on whether a DisplayName parameter was passed.

### Parameters

-DisplayName <String>
    Name of an AD CS template to retrieve.
    
    Required?                    false
    Position?                    1
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

-Server <String>
    FQDN of Active Directory Domain Controller to target for the operation.
    When not specified it will search for the nearest Domain Controller.
    
    Required?                    false
    Position?                    named
    Default value                (Get-ADDomainController -Discover -ForceDiscover -Writable).HostName[0]
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

### Notes
Requires Enterprise Administrator permissions, since this touches the AD Configuration partition.

### Examples
-------------------------- EXAMPLE 1 --------------------------

```
PS C:\> Get-ADCSTemplate

```
-------------------------- EXAMPLE 2 --------------------------

```
PS C:\> Get-ADCSTemplate -DisplayName PowerShellCMS

```
-------------------------- EXAMPLE 3 --------------------------

```
PS C:\> Get-ADCSTemplate | Sort-Object Name | ft Name, Created, Modified

```
-------------------------- EXAMPLE 4 --------------------------

```
PS C:\> ###View template permissions
(Get-ADCSTemplate pscms).nTSecurityDescriptor
(Get-ADCSTemplate pscms).nTSecurityDescriptor.Sddl
(Get-ADCSTemplate pscms).nTSecurityDescriptor.Access
ConvertFrom-SddlString -Sddl (Get-ADCSTemplate pscms).nTSecurityDescriptor.sddl -Type ActiveDirectoryRights

```

## New-ADCSDrive

### Synopsis
Maps a PowerShell drive to the Active Directory Certificate Services location.

### Description
Maps a PowerShell drive to the Active Directory Certificate Services location 
of the Configuration partition under CN=Public Key Services,CN=Services,... .
The new drive is ADCS:. This is purely for convenience of checking the objects
updated by functions in the ADCSTemplate module.

### Parameters

-Server <String>
    FQDN of Active Directory Domain Controller to target for the operation.
    When not specified it will search for the nearest Domain Controller.
    
    Required?                    false
    Position?                    1
    Default value                (Get-ADDomainController -Discover -ForceDiscover -Writable).HostName[0]
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

### Notes
Requires Enterprise Administrator permissions, since this touches the AD Configuration partition.

### Examples
-------------------------- EXAMPLE 1 --------------------------

```
PS C:\> New-ADCSDrive
PS C:\> Set-Location ADCS:

```
-------------------------- EXAMPLE 2 --------------------------

```
PS C:\> ### Explore templates with drive
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

```

## New-ADCSTemplate

### Synopsis
Creates a new Active Directory Certificate Services template based on a JSON export.

### Description
Creates a new Active Directory Certificate Services template based on a JSON export.
Optionally can permission and publish the template (best practice).

### Parameters

-DisplayName <String>
    DisplayName for the certificate template to create. This does not have to match
    the original name of the exported template.
    
    Required?                    true
    Position?                    1
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

-JSON <String>
    JSON string output from Export-ADCSTemplate. Defines the template to create.
    Can be retrieved from file using Get-Content -Raw.
    
    Required?                    true
    Position?                    2
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

-Server <String>
    FQDN of Active Directory Domain Controller to target for the operation.
    When not specified it will search for the nearest Domain Controller.
    
    Required?                    false
    Position?                    3
    Default value                (Get-ADDomainController -Discover -ForceDiscover -Writable).HostName[0]
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

-Identity <String[]>
    String or string array of Active Directory identities (users or groups).
    This is optional for permissioning the template.
    
    Required?                    false
    Position?                    4
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

-AutoEnroll [<SwitchParameter>]
    Default permission is Read and Enroll. Use this switch to also grant AutoEnroll 
    to the identity. Only used when Identity parameter is used.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

-Publish [<SwitchParameter>]
    Publish the template to *ALL* Certificate Authority issuers. Use with caution
    in production environments. You may want to manually publish to only specific
    Certificate Authorities in production. In a lab this is ideal.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

### Notes
This function does not use the official (complicated) API for PKI management.
Instead it creates the exact same AD objects that are generated by the API,
including AD forest-specific OIDs.
Requires Enterprise Administrator permissions, since this touches the AD Configuration partition.

### Examples
-------------------------- EXAMPLE 1 --------------------------

```
PS C:\> New-ADCSTemplate -DisplayName PowerShellCMS -JSON (Get-Content .\pscms.json -Raw)

```
-------------------------- EXAMPLE 2 --------------------------

```
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

```
-------------------------- EXAMPLE 3 --------------------------

```
PS C:\> New-ADCSTemplate -DisplayName PowerShellCMS-NEW -JSON (Export-ADCSTemplate -DisplayName PowerShellCMS-OLD)

```

## Remove-ADCSTemplate

### Synopsis
Removes a certificate template from Active Directory.

### Description
Removes the template from any issuers where it is published.
Removes the template itself.
Removes the unique OID object of the template.

### Parameters

-DisplayName <String>
    DisplayName for the certificate template to delete.
    
    Required?                    true
    Position?                    1
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

-Server <String>
    FQDN of Active Directory Domain Controller to target for the operation.
    When not specified it will search for the nearest Domain Controller.
    
    Required?                    false
    Position?                    2
    Default value                (Get-ADDomainController -Discover -ForceDiscover -Writable).HostName[0]
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

-WhatIf [<SwitchParameter>]
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

-Confirm [<SwitchParameter>]
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

### Notes
Use with caution!
Requires Enterprise Administrator permissions, since this touches the AD Configuration partition.

### Examples
-------------------------- EXAMPLE 1 --------------------------

```
PS C:\> Remove-ADCSTemplate -DisplayName PowerShellCMS

```
-------------------------- EXAMPLE 2 --------------------------

```
PS C:\> (Get-ADCSTemplate).name | Where-Object {$_ -like "PowerShellCMS*"} | ForEach-Object {Remove-ADCSTemplate -DisplayName $_ -Verbose}

```

## Set-ADCSTemplateACL

### Synopsis
Adds an ACL to an Active Directory Certificate template.

### Description
Adds an ACL to an Active Directory Certificate template.
Default permission is read (without the Enroll or AutoEnroll switches).

### Parameters

-DisplayName <String>
    Name of an AD CS template to receive the ACL.
    
    Required?                    true
    Position?                    1
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

-Server <String>
    FQDN of Active Directory Domain Controller to target for the operation.
    When not specified it will search for the nearest Domain Controller.
    
    Required?                    false
    Position?                    2
    Default value                (Get-ADDomainController -Discover -ForceDiscover -Writable).HostName[0]
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

-Type <String>
    ACL type: Allow or Deny
    
    Required?                    false
    Position?                    3
    Default value                Allow
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

-Identity <String[]>
    String or string array of Active Directory identities (users or groups)
    
    Required?                    false
    Position?                    4
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

-Enroll [<SwitchParameter>]
    Set the Enroll permission
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

-AutoEnroll [<SwitchParameter>]
    Set the AutoEnroll permission
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
    

### Notes
Requires Enterprise Administrator permissions, since this touches the AD Configuration partition.

### Examples
-------------------------- EXAMPLE 1 --------------------------

```
PS C:\> Set-ADCSTemplateACL -DisplayName PowerShellCMS -Type Allow -Identity 'CONTOSO\Servers Group' -Enroll

```
-------------------------- EXAMPLE 2 --------------------------

```
PS C:\> Set-ADCSTemplateACL -DisplayName PowerShellCMS -Type Allow -Identity 'CONTOSO\Servers Group','CONTOSO\Workstations Group' -Enroll -AutoEnroll

```
-------------------------- EXAMPLE 3 --------------------------

```
PS C:\> Set-ADCSTemplateACL -DisplayName PowerShellCMS -Type Deny -Identity 'CONTOSO\Servers Group'

```
