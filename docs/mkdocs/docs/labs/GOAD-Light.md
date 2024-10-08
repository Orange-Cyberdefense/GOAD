# GOAD-Light

This is a light version of goad without the essos domain. This lab was build for computer with less performance (min ~20GB).

![GOAD Light overview](../img/GOAD-Light_schema.png)

Missing scenarios:

- cross forest exploitation (no more external forest)
- mssql trusted link
- some old computer vulnerabilities (zero logon, petitpotam unauthent,...)
- ESC4, ESC2/3

## Servers
This lab is actually composed of five virtual machines:

**domain : sevenkingdoms.local**

- **kingslanding** : DC01  running on Windows Server 2019 (with windefender enabled by default)

**domain : north.sevenkingdoms.local**

- **winterfell**   : DC02  running on Windows Server 2019 (with windefender enabled by default)
- **castelblack**  : SRV02 running on Windows Server 2019 (with windefender **disabled** by default)


## Users/Groups and associated vulnerabilites/scenarios

- You can find a lot of the available scenarios on [https://mayfly277.github.io/categories/ad/](https://mayfly277.github.io/categories/goad/)

**NORTH.SEVENKINGDOMS.LOCAL**

- STARKS:              RDP on WINTERFELL AND CASTELBLACK
    - arya.stark:        Execute as user on mssql
    - eddard.stark:      DOMAIN ADMIN NORTH/ (bot 5min) LLMRN request to do NTLM relay with responder
    - catelyn.stark:     
    - robb.stark:        bot (3min) RESPONDER LLMR
    - sansa.stark:       
    - brandon.stark:     ASREP_ROASTING
    - rickon.stark:      
    - theon.greyjoy:
    - jon.snow:          mssql admin / KERBEROASTING / group cross domain / mssql trusted link
    - hodor:             PASSWORD SPRAY (user=password)
- NIGHT WATCH:         RDP on CASTELBLACK
    - samwell.tarly:     Password in ldap description / mssql execute as login
                        GPO abuse (Edit Settings on "STARKWALLPAPER" GPO)
    - jon.snow:          (see starks)
    - jeor.mormont:      (see mormont)
- MORMONT:             RDP on CASTELBLACK
    - jeor.mormont:      ACL writedacl-writeowner on group Night Watch
- AcrossTheSea :       cross forest group

**SEVENKINGDOMS.LOCAL**

- LANISTERS
    - tywin.lannister:   ACL forcechangepassword on jaime.lanister
    - jaime.lannister:   ACL genericwrite-on-user joffrey.baratheon
    - tyron.lannister:   ACL self-self-membership-on-group Small Council
    - cersei.lannister:  DOMAIN ADMIN SEVENKINGDOMS
- BARATHEON:           RDP on KINGSLANDING
    - robert.baratheon:  DOMAIN ADMIN SEVENKINGDOMS
    - joffrey.baratheon: ACL Write DACL on tyron.lannister
    - renly.baratheon:
    - stannis.baratheon: ACL genericall-on-computer kingslanding / ACL writeproperty-self-membership Domain Admins
- SMALL COUNCIL :      ACL add Member to group dragon stone / RDP on KINGSLANDING
    - petyer.baelish:    ACL writeproperty-on-group Domain Admins
    - lord.varys:        ACL genericall-on-group Domain Admins / Acrossthenarrossea
    - maester.pycelle:   ACL write owner on group Domain Admins
- DRAGONSTONE :        ACL Write Owner on KINGSGUARD
- KINGSGUARD :         ACL generic all on user stannis.baratheon
- AccorsTheNarrowSea:       cross forest group


## Computers Users and group permissions

- SEVENKINGDOMS
    - DC01 : kingslanding.sevenkingdoms.local (Windows Server 2019) (SEVENKINGDOMS DC)
        - Admins : robert.baratheon (U), cersei.lannister (U)
        - RDP: Small Council (G)

- NORTH
    - DC02 : winterfell.north.sevenkingdoms.local (Windows Server 2019) (NORTH DC)
        - Admins : eddard.stark (U), catelyn.stark (U), robb.stark (U)
        - RDP: Stark(G)

    - SRV02 : castelblack.essos.local (Windows Server 2019) (IIS, MSSQL, SMB share)
        - Admins: jeor.mormont (U)
        - RDP: Night Watch (G), Mormont (G), Stark (G)
        - IIS : allow asp upload, run as NT Authority/network
        - MSSQL:
            - admin : jon.snow
            - impersonate : 
                - execute as login : samwel.tarlly -> sa
                - execute as user : arya.stark -> dbo
