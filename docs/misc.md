# install new domain

## set local administrator password :
$NewPwd = ConvertTo-SecureString "MyComplexPassword@123" -AsPlainText -Force
Set-LocalUser -Name Administrator -Password $NewPwd

# promote to dc
$password = ConvertTo-SecureString "Str0nGPassw0rd123_" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ("SEVENKINGDOMS\Administrator", $password)
Install-ADDSDomain -Credential $Cred -NewDomainName 'north' -NewDomainNetbiosName 'NORTH' -ParentDomainName 'sevenkingdoms.local' -InstallDNS -CreateDNSDelegation -DnsDelegationCredential $Cred -SafeModeAdministratorPassword $password -Force

ovh : ns server -> cloudflare

cloudflare : dns seulement

Après ajout sur cloudflare ajout de subdomaine
    resolution ip Cloudflare 
Cloudfront -> ---------------- -> aws ec2


PS C:\> 
$password = ConvertTo-SecureString "Str0nGPassw0rd123_" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ("SEVENKINGDOMS\Administrator", $password)
Install-ADDSDomain -Credential $Cred -NewDomainName child -ParentDomainName "sevenkingdoms.local" -InstallDNS -CreateDNSDelegation -ReplicationSourceDC "kingslanding.sevenkingdoms.local" -SiteName "North" -DatabasePath "C:\NTDS" -SYSVOLPath "C:\SYSVOL" -LogPath "C:\Logs" -SafeModeAdministratorPassword $password -Force


with domain administrator !!

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

$password = ConvertTo-SecureString "Str0nGPassw0rd123_" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ("SEVENKINGDOMS\Administrator", $password)
Install-ADDSDomain -NewDomainName north -ParentDomainName "sevenkingdoms.local" -InstallDNS -CreateDNSDelegation -ReplicationSourceDC "kingslanding.sevenkingdoms.local"-DatabasePath "C:\windows\NTDS" -SYSVOLPath "C:\windows\SYSVOL" -LogPath "C:\windows\NTDS" -SafeModeAdministratorPassword $password -Force


last test:
---------
$password = ConvertTo-SecureString "Str0nGPassw0rd123_" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ("SEVENKINGDOMS\Administrator", $password)
$safePassword = ConvertTo-SecureString "Str0nGPassw0rd456_" -AsPlainText -Force
Install-ADDSDomain -Credential $Cred -SkipPreChecks -NewDomainName north -ParentDomainName "sevenkingdoms.local" -ReplicationSourceDC "kingslanding.sevenkingdoms.local" -DatabasePath "C:\windows\NTDS" -SYSVOLPath "C:\windows\SYSVOL" -LogPath "C:\windows\NTDS" -SafeModeAdministratorPassword $safePassword -Force

=> désactiver l'autre interface réseau !!!!

-> next need to setup dns delegation on forward lookup of parent
and dns forwading on parent and child : https://rdr-it.com/en/active-directory-how-to-set-up-a-child-domain/4/

on child : 
Add-DnsServerConditionalForwarderZone -Name sevenkingdoms.local -MasterServers 192.168.56.10

on parent:
Add-DnsServerConditionalForwarderZone -Name north.sevenkingdoms.local -MasterServers 192.168.56.11


Install-ADDSDomain : The operation failed because:
Active Directory Domain Services could not enable the optional features that are enabled on the remote AD
DC.
"Access is denied."
At line:1 char:1
+ Install-ADDSDomain -Credential $Cred -NewDomainName child -ParentDoma ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Install-ADDSDomain], DCPromoExecutionException
    + FullyQualifiedErrorId : DCPromo.General.54,Microsoft.DirectoryServices.Deployment.PowerShell.Commands
   .InstallADDSDomainCommand

# fix domain trust issue “The trust relationship between this workstation and the primary domain failed”
Reset-ComputerMachinePassword -Server kingslanding.sevenkingdoms.local -Credential SEVENKINGDOMS\Administrator

# scénarios 
- North
   - ad attacks
     1) without account
       - anonymous smb user listing on winterfell
         - asreproasting
         - password spray
         - password in ldap
     2) with account
       - kerberoasting : get an administrator of castelblack
       - bloodhound
   - network attacks
        - responder : listen smb and capture hash => get account of night watch
        - relay LLMNR/NBTDNS: listen smb and relay from dc to castelblack to get a shell as admin with jeor.mormont
   - Castelblack
       - server : web asp upload -> shell on castelblack -> privesc
       - Mssql : exec
       - Constrained delegation server

    - Winterfell
    pth with essos server

- sevenkingdoms.local
  - kingslanding

- Essos : ADCS 1-8
    - Meereen
        - 
    - Braavos
        - ADCS
        - Mssql trusted link

- essos <-> sevenkingdoms
 - user with Foreign group member (essos (jorah.mormont) -> north (group : Mormont / rdp on castelblack))
 - group with Foreign group member ()

- kingslanding from north
   child->parent

- kingslanding from essos



# MISC, various informations in a disorganised way
# GAME OF THRONE - AD
- domain : westeros.local

- servers : 
 - king's landing (DC01)
 - dragonstone (DC02)
 - winterfell (tomcat)
 - casterly rock (mssql) : lanisters


 - the eyrie 
 - highgarden
 - riverun 
 - storm's end
 - sunspear
 - castel black 

- domain: essos.local
 - servers :
   - Meeren
   - Astapor
   - Volantis
   - Myr
   - Braavos


https://gameofthrones.fandom.com/wiki/Seven_Kingdoms
    Kingdom of the North, ruled by House Stark of Winterfell, the Kings in the North. Now independent and active again.
- winterfell

    Kingdom of the Mountain and the Vale, ruled by House Arryn of the Eyrie, the Kings of the Mountain and the Vale.
- the eyrie

    Kingdom of the Isles and Rivers, ruled by House Hoare of Harrenhal, the Kings of the Isles and the Rivers.
- harrenhal / riverun

    Kingdom of the Rock, ruled by House Lannister of Casterly Rock, the Kings of the Rock.
- casterly rock

    Kingdom of the Stormlands, ruled by House Durrandon of Storm's End, the Storm Kings.
 - storm's end

    Kingdom of the Reach, ruled by House Gardener of Highgarden, the Kings of the Reach.
 - highgarden

    Principality of Dorne, ruled by House Martell of Sunspear, the Princes of Dorne. Note that being referred to as a principality was purely stylistic; Dorne was an independent kingdom in all but name.
 - sunspear


## STARK -> RDP winterfell
Eddard Stark : admin winterfell / domain admin
Catelyn Stark : admin winterfell / generic all group STARK
Robb Stark : admin winterfell
Sansa Stark
Brandon Stark : Generic ALL hodor
Arya Stark
Rickon Stark
Jon Snow : 
hodor -> password : hodor

# TARGARYEN
Daenerys Targaryen : account disabled
Viserys Targaryen : account disabled

## NIGHT WATCH
samwell.tarly
jon.snow
jeor.mormont : generic ALL group NIGHTWATCH

# LANNISTER -> rdp caterly_rock
Tywin Lannister : admin casterly_rock / Generic Write cersei/Jaime / generic ALL group LANNISTER 
Jaime Lannister : admin casterly_rock
Cersei Lannister : admin casterly_rock / domain admin / group BARATHEON
Tyrion Lannister
sandor.clegane

# BARATHEON -> RDP 
Joffrey Baratheon : Generic ALL sandor.clegane
Myrcella Baratheon
Tommen baratheon
Robert Baratheon : domain admin / generic ALL group BARATHEON
Stannis Baratheon
Renly Baratheon

# COUNCIL : write property GPO / write DACL DOMAIN ADMIN  / rdp kings_landing
petyer.baelish : 
lord.varys : 
grand-maester.pycelle : 
barristan.selmy : 

# ARRYN
jon.arryn : accound disabled / domain admin / council group
lysa.arryn : generic write group ARRYN
robin.arryn


# GREYJOY
Theon Greyjoy
Asha (Yara) Greyjoy
Victarion Greyjoy

# TARTH
Brienne of Tarth

# Seaworth
Davos Seaworth

# TARLY
Samwell Tarly

# MARTELL
Arianne Martell

# BAELISH
Petyr Baelish (Littlefinger) 


## TODO list
- [ ] smbshare null session
- [X] smbshare anonymous
- [ ] ms17.010
- [ ] zone transfert
- [X] smb not signed
- [X] responder
- [ ] mitm6
- [X] zerologon
- [ ] printerbug / drop the mic
- [X] windows defender (everywhere)
- [ ] tomcat + RMI
- [X] ASREPRoast
- [X] kerberoasting
- [ ] LAPS
- [ ] sccm
- [X] mssql trusted link
- [X] add asp server
- [X] AD acl abuse 
- [ ] RBCD
- [X] Unconstraint delegation
- [ ] exchange abuse


# drop the mic 
find older windows vulnerable

# unconstrained delegation
Get-ADComputer -Identity Winterfell | Set-ADAccountControl ‑TrustedForDelegation $true

=> exploit https://medium.com/@riccardo.ancarani94/exploiting-unconstrained-delegation-a81eabbd6976

# constrained delegation
https://4sysops.com/archives/how-to-configure-computer-delegation-with-powershell/#unconstrained-delegation-to-any-service


$group_member = Get-ADObject -Filter "SamAccountName -eq 'jorah.mormont'" -Server essos.local
$ADGroup = Get-ADGroup -Identity "Mormont"



find mssql sysadmin: sqlcmd 
SELECT name,type_desc,is_disabled, create_date
FROM master.sys.server_principals
WHERE IS_SRVROLEMEMBER ('sysadmin',name) = 1
ORDER BY name

Trusted link : 
https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-addlinkedserver-transact-sql?view=sql-server-ver16


sp_addlinkedserver [ @server= ] 'server' [ , [ @srvproduct= ] 'product_name' ]   
     [ , [ @provider= ] 'provider_name' ]  
     [ , [ @datasrc= ] 'data_source' ]   
     [ , [ @location= ] 'location' ]   
     [ , [ @provstr= ] 'provider_string' ]   
     [ , [ @catalog= ] 'catalog' ]


USE [master]
GO
CREATE USER [NORTH\samwell.tarly] FOR LOGIN [NORTH\samwell.tarly]
GO
CREATE USER sa FOR LOGIN sa
GO
GRANT IMPERSONATE ON USER::[NORTH\samwell.tarly] TO sa;  
GO


create SPN : https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/register-a-service-principal-name-for-kerberos-connections?view=sql-server-ver16

setspn -A MSSQLSvc/catelblack.north.sevenkingdoms.local north\sql_svc
setspn -A MSSQLSvc/braavos.essos.local essos\sql_svc


set linked server:
USE [master]
GO
EXEC master.dbo.sp_addlinkedserver @server = N'BRAAVOS.ESSOS.LOCAL', @srvproduct=N'', @provider=N'SQLOLEDB'

GO
EXEC master.dbo.sp_serveroption @server=N'BRAAVOS.ESSOS.LOCAL', @optname=N'collation compatible', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'BRAAVOS.ESSOS.LOCAL', @optname=N'data access', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'BRAAVOS.ESSOS.LOCAL', @optname=N'dist', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'BRAAVOS.ESSOS.LOCAL', @optname=N'pub', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'BRAAVOS.ESSOS.LOCAL', @optname=N'rpc', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'BRAAVOS.ESSOS.LOCAL', @optname=N'rpc out', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'BRAAVOS.ESSOS.LOCAL', @optname=N'sub', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'BRAAVOS.ESSOS.LOCAL', @optname=N'connect timeout', @optvalue=N'0'
GO
EXEC master.dbo.sp_serveroption @server=N'BRAAVOS.ESSOS.LOCAL', @optname=N'collation name', @optvalue=null
GO
EXEC master.dbo.sp_serveroption @server=N'BRAAVOS.ESSOS.LOCAL', @optname=N'lazy schema validation', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'BRAAVOS.ESSOS.LOCAL', @optname=N'query timeout', @optvalue=N'0'
GO
EXEC master.dbo.sp_serveroption @server=N'BRAAVOS.ESSOS.LOCAL', @optname=N'use remote collation', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'BRAAVOS.ESSOS.LOCAL', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO
USE [master]
GO
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'BRAAVOS.ESSOS.LOCAL', @locallogin = N'NORTH\samwell.tarly', @useself = N'False', @rmtuser = N'sa', @rmtpassword = N'sa_P@ssw0rd!essos'
GO
USE [master]
GO
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'BRAAVOS.ESSOS.LOCAL', @locallogin = NULL , @useself = N'False'
GO
