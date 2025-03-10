# Code from LUDUS ESC13 role
# Licence GPL-3.0
# https://github.com/badsectorlabs/ludus_adcs/blob/main/files/esc13.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$esc13group,
    
    [Parameter(Mandatory=$true)]
    [string]$esc13templateName
)


# Import modules (just in case)
import-module ADCSTemplate
import-module ActiveDirectory

 # Function to generate a random hexadecimal string of a given length
 Function Get-RandomHex {
    param ([int]$Length)
    $Hex = '0123456789ABCDEF'
    $Return = ''
    1..$Length | ForEach-Object {
        $Return += $Hex.Substring((Get-Random -Minimum 0 -Maximum 16),1)
    }
    Return $Return
}

# Function to check if a given OID is unique
Function IsUniqueOID {
    param ($cn, $TemplateOID, $ConfigNC)
    $Search = Get-ADObject -Filter {cn -eq $cn -and msPKI-Cert-Template-OID -eq $TemplateOID} -SearchBase "CN=OID,CN=Public Key Services,CN=Services,$ConfigNC"
    If ($Search) {$False} Else {$True}
}

# Function to generate a new unique OID
Function New-TemplateOID {
    Param($ConfigNC)
    do {
        $OID_Part_1 = Get-Random -Minimum 10000000 -Maximum 99999999
        $OID_Part_2 = Get-Random -Minimum 10000000 -Maximum 99999999
        $OID_Part_3 = Get-RandomHex -Length 32
        $OID_Forest = Get-ADObject -Identity "CN=OID,CN=Public Key Services,CN=Services,$ConfigNC" -Properties msPKI-Cert-Template-OID |
            Select-Object -ExpandProperty msPKI-Cert-Template-OID
        $msPKICertTemplateOID = "$OID_Forest.$OID_Part_1.$OID_Part_2"
        $Name = "$OID_Part_2.$OID_Part_3"
    } until (IsUniqueOID -cn $Name -TemplateOID $msPKICertTemplateOID -ConfigNC $ConfigNC)
    Return @{
        TemplateOID  = $msPKICertTemplateOID
        TemplateName = $Name
    }
}

# Get the configuration naming context
$ADRootDSE = Get-ADRootDSE
$ConfigNC = $ADRootDSE.configurationNamingContext

# Define the display name and the template
$IssuanceName = "IssuancePolicyESC13"
$ESC13Template = "CN=$esc13templateName,CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigNC"

# Generate a new unique OID
$OID = New-TemplateOID -ConfigNC $ConfigNC

# Define the path to the OID
$TemplateOIDPath = "CN=OID,CN=Public Key Services,CN=Services,$ConfigNC"

# Create a new AD object with the generated OID
$oa = @{
    'DisplayName' = $IssuanceName
    'Name' = $IssuanceName
    'flags' = [System.Int32]'2'
    'msPKI-Cert-Template-OID' = $OID.TemplateOID
 }
$theresults = New-ADObject -Path $TemplateOIDPath -OtherAttributes $oa -Name $OID.TemplateName -Type 'msPKI-Enterprise-Oid'

# Get the new OID object
$OIDContainer = "CN=OID,CN=Public Key Services,CN=Services,"+$ConfigNC
$OIDs = Get-ADObject -Filter * -SearchBase $OIDContainer -Properties DisplayName,Name,msPKI-Cert-Template-OID,msDS-OIDToGroupLink
$newOIDObj = ($OIDS | where {$_.DisplayName -eq $IssuanceName })
$newOIDValue = $newOIDObj | select -ExpandProperty msPKI-Cert-Template-OID

# Get the ESC13 template object for updating
$adObject = Get-ADObject $ESC13Template -Properties msPKI-Certificate-Policy

# Get the current policies
$policies = $adObject.'msPKI-Certificate-Policy'

# Add new OID to the policies
$newPolicy = $newOIDValue # replace with your new OID
$policies = $newPolicy

# Convert policies to an array of strings
$policies = $policies | ForEach-Object { $_.ToString() }

# Update the ESC13 template AD object
Set-ADObject -Identity $adObject.DistinguishedName -Replace @{ 'msPKI-Certificate-Policy' = $policies } 

# Get DN of the ESC13 Group
$ludus_esc13_group_dn = (Get-ADGroup $esc13group).DistinguishedName
$ludus_esc13_group_dn  

# Get Distinguished Name of the ESC13 OID Issuance Policy we created
# Thanks to Jonas (https://twitter.com/Jonas_B_K) for helping with this!
$ADRootDSE = Get-ADRootDSE
$ConfigurationNC = $ADRootDSE.configurationNamingContext
$OIDContainer = "CN=OID,CN=Public Key Services,CN=Services,"+$ConfigurationNC
$OIDs = Get-ADObject -Filter * -SearchBase $OIDContainer -Properties DisplayName,Name,msPKI-Cert-Template-OID,msDS-OIDToGroupLink
$esc13OID_dn = ($OIDS | where {$_.DisplayName -eq $IssuanceName }).DistinguishedName[0]
$esc13OID_dn

# Create a DirectoryEntry object for the Issuance Policy OID
$object = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$esc13OID_dn")

# Set the msDS-OIDToGroupLink property to the DN of the ESC13 group
$Toset = $ludus_esc13_group_dn
$object.Properties["msDS-OIDToGroupLink"].Value = $Toset
$object.CommitChanges()
$object.RefreshCache()
$object | select msDS-OIDToGroupLink