

configuration CreateADDomainWithCS
{ 
   param 
   ( 
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$AdminCreds,

        [Int]$RetryCount = 60,
        [Int]$RetryIntervalSec = 5
    ) 
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xActiveDirectory -ModuleVersion 2.17.0.0
    Import-DscResource -ModuleName xAdcsDeployment -ModuleVersion 1.4.0.0
    Import-DscResource -ModuleName ADCSTemplate -ModuleVersion 1.0.1.0
    
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("$DomainName\$($AdminCreds.UserName)", $AdminCreds.Password)

    Node $AllNodes.NodeName
    {
        LocalConfigurationManager
        {
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
            AllowModuleOverWrite = $true
        }

        WindowsFeature ADDSInstall 
        { 
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
        }  

        WindowsFeature ADDSPowerShell
        { 
            Ensure = 'Present' 
            Name = 'RSAT-AD-PowerShell'
        }

        # Optional GUI tools
        WindowsFeature ADDSTools
        { 
            Ensure = 'Present' 
            Name = 'RSAT-ADDS'
        }

        xADDomain FirstDS 
        {
            DomainName = $DomainName
            DomainAdministratorCredential = $DomainCreds
            SafemodeAdministratorPassword = $DomainCreds
            DomainNetbiosName = ($DomainName -split '\.')[0]
            DependsOn = "[WindowsFeature]ADDSInstall"
        }
<#
        #This resource is broken as of 2.17.0.0.
        #See Script resource alternative below.
        #Revert to using this resource when it is fixed.

        xWaitForADDomain DscForestWait
        {
            DomainName = $DomainName
            DomainUserCredential = $DomainCreds
            RetryCount = $RetryCount
            RetryIntervalSec = $RetryIntervalSec
            DependsOn = "[xADDomain]FirstDS"
        } 
#>

        Script xWaitForADDomain_Alternative
        {
            GetScript = {
                Return @{
                    Result = [string]$(([ADSI]"LDAP://$Using:DomainName").distinguishedName)
                }
            }
            TestScript = {
                $DN = "DC=$($Using:DomainName -replace '\.',',DC=')"
                $FoundDomain = $false
                For ($i=1;$i -le $Using:RetryCount;$i++) {
                    If (([ADSI]"LDAP://$DN").distinguishedName -eq $DN) {
                        $FoundDomain = $true
                        Write-Verbose "Found domain $($Using:DomainName)."
                        break
                    } Else {
                        Write-Verbose "Could not find domain $($Using:DomainName). Attempt $i/$($Using:RetryCount). Sleeping $($Using:RetryIntervalSec) seconds..."
                        Start-Sleep -Seconds $Using:RetryIntervalSec
                    }
                }
                Return $FoundDomain
            }
            SetScript = {
                Write-Verbose 'Cannot continue. Domain not found.'
                Throw "Could not find domain $($Using:DomainName)."
            }
        }

        xADRecycleBin RecycleBin
        {
           EnterpriseAdministratorCredential = $DomainCreds
           ForestFQDN = $DomainName
           #DependsOn = '[xWaitForADDomain]DscForestWait'
           DependsOn = '[Script]xWaitForADDomain_Alternative'
        }


        ### OUs ###
        $DomainRoot = "DC=$($DomainName -replace '\.',',DC=')"
        $DependsOn_OU = @()

        ForEach ($RootOU in $ConfigurationData.NonNodeData.RootOUs) {

            xADOrganizationalUnit "OU_$RootOU"
            {
                Name = $RootOU
                Path = $DomainRoot
                ProtectedFromAccidentalDeletion = $true
                Description = "OU for $RootOU"
                Credential = $DomainCred
                Ensure = 'Present'
                DependsOn = '[xADRecycleBin]RecycleBin'
            }

            ForEach ($ChildOU in $ConfigurationData.NonNodeData.ChildOUs) {
                
                xADOrganizationalUnit "OU_$($RootOU)_$ChildOU"
                {
                    Name = $ChildOU
                    Path = "OU=$RootOU,$DomainRoot"
                    ProtectedFromAccidentalDeletion = $true
                    Credential = $DomainCred
                    Ensure = 'Present'
                    DependsOn = "[xADOrganizationalUnit]OU_$RootOU"
                }

                $DependsOn_OU += "[xADOrganizationalUnit]OU_$($RootOU)_$ChildOU"
            }

        }


        ### USERS ###
        # Use PasswordAuthentication = 'Negotiate' to avoid the password verification failure once ADCS is installed.
        # https://github.com/PowerShell/xActiveDirectory/issues/61
        $DependsOn_User = @()
        $Users = $ConfigurationData.NonNodeData.UserData | ConvertFrom-CSV
        ForEach ($User in $Users) {

            xADUser "NewADUser_$($User.UserName)"
            {
                DomainName = $DomainName
                Ensure = 'Present'
                UserName = $User.UserName
                Path = "OU=Users,OU=$($User.Dept),$DomainRoot"
                Enabled = $true
                PasswordAuthentication = 'Negotiate'
                Password = New-Object -TypeName PSCredential -ArgumentList 'JustPassword', (ConvertTo-SecureString -String $User.Password -AsPlainText -Force)
                DependsOn = $DependsOn_OU
            }
            $DependsOn_User += "[xADUser]NewADUser_$($User.UserName)"
        }

        ### GROUPS ###
        ForEach ($RootOU in $ConfigurationData.NonNodeData.RootOUs) {
            xADGroup "NewADGroup_$RootOU"
            {
                GroupName = "G_$RootOU"
                GroupScope = 'Global'
                Description = "Global group for $RootOU"
                Category = 'Security'
                Members = ($Users | Where-Object {$_.Dept -eq $RootOU}).UserName
                Path = "OU=Groups,OU=$RootOU,$DomainRoot"
                Ensure = 'Present'
                DependsOn = $DependsOn_User
            }
        }


        WindowsFeature ADCS-Cert-Authority
        {
            Ensure = 'Present'
            Name = 'ADCS-Cert-Authority'
            DependsOn = '[xADRecycleBin]RecycleBin'
        }

        WindowsFeature ADCS-Web-Enrollment
        {
            Ensure = 'Present'
            Name = 'ADCS-Web-Enrollment'
            DependsOn = '[xADRecycleBin]RecycleBin'
        }

        WindowsFeature RSAT-ADCS
        {
            Ensure = 'Present'
            Name = 'RSAT-ADCS'
            DependsOn = '[xADRecycleBin]RecycleBin'
        }

        xADCSCertificationAuthority ADCS
        {
            Ensure = 'Present'
            Credential = $DomainCreds
            CAType = 'EnterpriseRootCA'
            DependsOn = '[WindowsFeature]ADCS-Cert-Authority'              
        }

        xADCSWebEnrollment CertSrv
        {
            IsSingleInstance = 'Yes'
            Ensure = 'Present'
            Credential = $DomainCreds
            DependsOn = '[xADCSCertificationAuthority]ADCS'
        }

        ADCSTemplate PSDSCEncryptionTemplate
        {
            Ensure = 'Present'
            DisplayName = 'PSCMS'
            JSON = $ConfigurationData.NonNodeData.JSON_PSCMS
            Publish = $true
            Identity = "$DomainName\Domain Computers", "$DomainName\Domain Controllers"
            AutoEnroll = $true
            PsDscRunAsCredential = $DomainCreds
            DependsOn = '[xADCSWebEnrollment]CertSrv'
        }

        ADCSTemplate TaniumTemplate
        {
            Ensure = 'Present'
            DisplayName = 'Tanium'
            JSON = $ConfigurationData.NonNodeData.JSON_Tanium
            Publish = $true
            Identity = "$DomainName\Domain Computers"
            AutoEnroll = $false
            PsDscRunAsCredential = $DomainCreds
            DependsOn = '[xADCSWebEnrollment]CertSrv'
        }

    }
}


$configData = @{
    AllNodes = @(
        @{
            Nodename = "localhost"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
            Credential = $cred
        }
    )
    NonNodeData = @{
        
        UserData = @'
UserName,Password,Dept
TaniumAdmin,P@ssw0rd,Tanium
TaniumService,P@ssw0rd,Tanium
'@
        RootOUs = 'Tanium'
        ChildOUs = 'Users','Groups'

        JSON_PSCMS = @'
{
    "name":  "PowerShellCMS",
    "displayName":  "PowerShellCMS",
    "objectClass":  "pKICertificateTemplate",
    "flags":  131680,
    "revision":  100,
    "msPKI-Cert-Template-OID":  "1.3.6.1.4.1.311.21.8.14606814.4579994.15679635.15482926.4928991.141.63412935.14964662",
    "msPKI-Certificate-Application-Policy":  [
                                                 "1.3.6.1.4.1.311.80.1"
                                             ],
    "msPKI-Certificate-Name-Flag":  268435456,
    "msPKI-Enrollment-Flag":  32,
    "msPKI-Minimal-Key-Size":  2048,
    "msPKI-Private-Key-Flag":  16842752,
    "msPKI-RA-Signature":  0,
    "msPKI-Template-Minor-Revision":  1,
    "msPKI-Template-Schema-Version":  2,
    "pKICriticalExtensions":  [
                                  "2.5.29.15"
                              ],
    "pKIDefaultCSPs":  [
                           "1,Microsoft RSA SChannel Cryptographic Provider"
                       ],
    "pKIDefaultKeySpec":  1,
    "pKIExpirationPeriod":  [
                                0,
                                128,
                                114,
                                14,
                                93,
                                194,
                                253,
                                255
                            ],
    "pKIExtendedKeyUsage":  [
                                "1.3.6.1.4.1.311.80.1"
                            ],
    "pKIKeyUsage":  [
                        32
                    ],
    "pKIMaxIssuingDepth":  0,
    "pKIOverlapPeriod":  [
                             0,
                             128,
                             166,
                             10,
                             255,
                             222,
                             255,
                             255
                         ]
}
'@

        JSON_Tanium = @'
{
    "name":  "Tanium",
    "displayName":  "Tanium",
    "objectClass":  "pKICertificateTemplate",
    "flags":  131649,
    "revision":  100,
    "msPKI-Cert-Template-OID":  "1.3.6.1.4.1.311.21.8.14606814.4579994.15679635.15482926.4928991.141.13175610.2217120",
    "msPKI-Certificate-Application-Policy":  [
                                                 "1.3.6.1.5.5.7.3.1",
                                                 "1.3.6.1.5.5.7.3.2"
                                             ],
    "msPKI-Certificate-Name-Flag":  1,
    "msPKI-Enrollment-Flag":  0,
    "msPKI-Minimal-Key-Size":  2048,
    "msPKI-Private-Key-Flag":  16842768,
    "msPKI-RA-Signature":  0,
    "msPKI-Template-Minor-Revision":  2,
    "msPKI-Template-Schema-Version":  2,
    "pKICriticalExtensions":  [
                                  "2.5.29.7",
                                  "2.5.29.15"
                              ],
    "pKIDefaultKeySpec":  1,
    "pKIExpirationPeriod":  [
                                0,
                                128,
                                114,
                                14,
                                93,
                                194,
                                253,
                                255
                            ],
    "pKIExtendedKeyUsage":  [
                                "1.3.6.1.5.5.7.3.1",
                                "1.3.6.1.5.5.7.3.2"
                            ],
    "pKIKeyUsage":  [
                        160,
                        0
                    ],
    "pKIMaxIssuingDepth":  0,
    "pKIOverlapPeriod":  [
                             0,
                             128,
                             166,
                             10,
                             255,
                             222,
                             255,
                             255
                         ]
}
'@
    }
}



#Install-Module -Name xAdcsDeployment, xActiveDirectory -Force
#Get-DscResource | Sort-Object ModuleName, Version, Name

md C:\ADCS -ErrorAction SilentlyContinue
cd C:\ADCS

$cred = New-Object -TypeName PSCredential -ArgumentList 'Administrator', (ConvertTo-SecureString -String 'Passw0rd' -AsPlainText -Force)

CreateADDomainWithCS -ConfigurationData $configData -DomainName 'goatee.lab' -AdminCreds $cred

Set-DscLocalConfigurationManager -Path .\CreateADDomainWithCS -Verbose
Start-DscConfiguration -Path .\CreateADDomainWithCS -Force -Verbose -Wait


break


#region CERT REQUEST/INSTALL ##################################################

dir Cert:\LocalMachine\My
dir Cert:\LocalMachine\My | Select-Object Thumbprint,Subject,@{name='KeyUsage';expression={$_.Extensions.KeyUsages}} | fl *

certutil -pulse

$Req = @{
    Template          = 'PSCMS'
    Url               = 'ldap:'
    CertStoreLocation = 'Cert:\LocalMachine\My'
}
Get-Certificate @Req

dir Cert:\LocalMachine\My | Select-Object Thumbprint,Subject,@{name='KeyUsage';expression={$_.Extensions.KeyUsages}} | fl *

$DocEncrCert = (dir Cert:\LocalMachine\My -DocumentEncryptionCert)[-1]
Protect-CmsMessage -To $DocEncrCert -Content "Encrypted with my new cert from the new template!"

#endregion ####################################################################


