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
- [X] two DC !
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
- [ ] mssql trusted link ?
- [ ] add asp server
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