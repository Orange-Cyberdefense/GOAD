# GOAD

- LAB Content 

![GOAD overview](../../docs/img/GOAD_schema.png)

## Servers
This lab is actually composed of five virtual machines:
- **kingslanding** : DC01  running on Windows Server 2019 (with windefender enabled by default)
- **winterfell**   : DC02  running on Windows Server 2019 (with windefender enabled by default)
- **castelblack**  : SRV02 running on Windows Server 2019 (with windefender **disabled** by default)
- **meereen**      : DC03  running on Windows Server 2016 (with windefender enabled by default)
- **braavos**      : SRV03 running on Windows Server 2016 (with windefender enabled by default)

## domain : north.sevenkingdoms.local
- **winterfell**     : DC01
- **castelblack**    : SRV02 : MSSQL / IIS

## domain : sevenkingdoms.local
- **kingslanding**   : DC02
- **castelrock**     : SRV01 (disabled due to resources reasons)

## domain : essos.local
- **braavos**        : DC03
- **meeren**         : SRV03 : MSSQL / ADCS

The lab setup is automated using vagrant and ansible automation tools.
You can change the vm version in the Vagrantfile according to Stefan Scherer vagrant repository : https://app.vagrantup.com/StefanScherer


## Users/Groups and associated vulnerabilites/scenarios

- You can find a lot of the available scenarios on [https://mayfly277.github.io/categories/ad/](https://mayfly277.github.io/categories/ad/)

- Graph of some scenarios is available here :
![diagram-GOAD_compromission_Path_dark](./../../docs/img/diagram-GOAD_compromission_Path_dark.png)

NORTH.SEVENKINGDOMS.LOCAL
- STARKS:              RDP on WINTERFELL AND CASTELBLACK
  - arya.stark:        Execute as user on mssql, pass on all share
  - eddard.stark:      DOMAIN ADMIN NORTH/ (bot 5min) LLMRN request to do NTLM relay with responder
  - catelyn.stark:     
  - robb.stark:        bot (3min) RESPONDER LLMR / lsass present user
  - sansa.stark:       keywalking password / unconstrained delegation
  - brandon.stark:     ASREP_ROASTING
  - rickon.stark:      pass spray WinterYYYY
  - jon.snow:          mssql admin / KERBEROASTING / mssql trusted link
  - hodor:             PASSWORD SPRAY (user=password)
- NIGHT WATCH:         RDP on CASTELBLACK
  - samwell.tarly:     Password in ldap description / mssql execute as login
                       GPO abuse (Edit Settings on "STARKWALLPAPER" GPO)
  - jon.snow:          (see starks)
  - jeor.mormont:      (see mormont)
- MORMONT:             RDP on CASTELBLACK
  - jeor.mormont:      Admin castelblack, pass in sysvol script
- AcrossTheSea :       cross forest group

SEVENKINGDOMS.LOCAL
- LANISTERS
  - tywin.lannister:   ACE forcechangepassword on jaime.lanister, password on sysvol cyphered
  - jaime.lannister:   ACE genericwrite-on-user joffrey.baratheon
  - tyron.lannister:   ACE self membership on small council
  - cersei.lannister:  DOMAIN ADMIN SEVENKINGDOMS
- BARATHEON:           RDP on KINGSLANDING
  - robert.baratheon:  DOMAIN ADMIN SEVENKINGDOMS, protected user
  - joffrey.baratheon: ACE Write DACL on tyron.lannister
  - renly.baratheon:   WriteDACL on container, sensitive user
  - stannis.baratheon: ACE genericall-on-computer kingslanding 
- SMALL COUNCIL :      ACE add Member to group dragon stone / RDP on KINGSLANDING
  - petyer.baelish:    
  - lord.varys:        ACE genericall-on-group Domain Admins and sdholder
  - maester.pycelle:   
- DRAGONSTONE :        ACE Write Owner on group KINGSGUARD
- KINGSGUARD :         ACE generic all on user stannis.baratheon
- AccorsTheNarrowSea:       cross forest group

ESSOS.LOCAL
- TARGERYEN
  - missande :          ASREP roasting, generic all on khal
  - daenerys.targaryen: DOMAIN ADMIN ESSOS
  - viserys.targaryen:  ACE write property on jorah.mormont
  - jorah.mormont:      mssql execute as login / mssql trusted link / Read LAPS Password
- DOTHRAKI
  - khal.drogo:         mssql admin / GenericAll on viserys (shadow credentials) / GenericAll on ECS4
- DragonsFriends:       cross forest group
- Spys:                 cross forest group / Read LAPS password  / ACL generic all jorah.mormont

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
      - link :
        - to braavos : jon.snow -> sa

- ESSOS
  - DC03  : meereen.essos.local (Windows Server 2016) (ESSOS DC)
    - Admins: daenerys.targaryen (U)
    - RDP: Targaryen (G)

  - SRV03 : braavos.essos.local (Windows Server 2016) (MSSQL, SMB share)
    - Admins: khal.drogo (U)
    - RDP: Dothraki (G)
    - MSSQL :
      - admin : khal.drogo
      - impersonate :
        - execute as login : jorah.mormont -> sa
      - link:
        - to castelblack: jorah.mormont -> sa

## Blueteam / ELK

- **elk** a kibana is configured on http://192.168.56.50:5601 to follow the lab events
- infos : log encyclopedia : https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/
- the elk is not installed by default due to resources reasons. 
- to install and start the elk play the following commands :

  1. uncomment the elk vm in Vagrantfile (vmware or virtualbox only by now) and provision with `vagrant up elk` (do not forget to add a coma on the box before)
```
# { :name => "elk", :ip => "192.168.56.50", :box => "bento/ubuntu-18.04", :os => "linux",
#   :forwarded_port => [
#     {:guest => 22, :host => 2210, :id => "ssh"}
#   ]
# }
```

  2. uncomment the elk part in the inventory (ad/sevenkingdoms.local/inventory) file
```
[elk:vars]
ansible_connection=ssh
ansible_ssh_user=vagrant
ansible_ssh_private_key_file=./.vagrant/machines/elk/virtualbox/private_key
ansible_ssh_port=22
host_key_checking = false

[elk]
192.168.56.50
```

  3. install with docker
```bash
sudo docker run -ti --rm --network host -e ANSIBLE_CONFIG=/goad/ansible -h goadansible -v $(pwd):/goad -w /goad/ansible goadansible ansible-playbook -i ../ad/GOAD/data/inventory -i ../ad/GOAD/providers/virtualbox/inventory elk.yml
```

  3. or install by hand : 

- you need `sshpass` for the elk installation
```bash
sudo apt install sshpass
```
- Chocolatey is needed to use elk. To install it run:
```bash
ansible-galaxy collection install chocolatey.chocolatey 
```
- play the elk.yml playbook to install and run elk:
```bash
ansible-playbook elk.yml
```

### V2 breaking changes
- If you previously install the v1 do not try to update as a lot of things have changed. Just drop your old lab and build the new one (you will not regret it)
- Chocolatey is no more used and basic tools like git or notepad++ are no more installed by default (as chocolatey regularly crash the install due to hitting rate on multiples builds)
- ELK is no more installed by default to save resources but you still can install it separately (see the blueteam/elk part)
- Dragonstone vm as disappear and there is no more DC replication in the lab to save resources
- Wintefell is now a domain controller for the subdomain north of the sevenkingdoms.local domain

