# GOAD (Game Of Active Directory)

![goad.png](./docs/img/GOAD.png)

## Description
GOAD is a pentest active directory LAB project.
The purpose of this lab is to give pentesters a vulnerable Active directory environement ready to use to practice usual attack techniques.

## warning
This lab is extremly vulnerable, do not reuse receipe to build your environement and do not deploy this environment on internet.
This repository is for pentest practice only.

## licences
This lab use free windows VM only (180 days). After that delay enter a licence on each server or rebuild all the lab (may be it's time for an update ;))

## Installation
### Requirements
So far the lab has only been tested on a linux machine, but it should work as well on macOS. Ansible has some problems with Windows hosts so I don't know about that.

For the setup to work properly you need to install:
- **vagrant** from their official site [vagrant](https://www.vagrantup.com/downloads). The version you can install through your favourite package manager (apt, yum, ...) is probably not the latest one.
- Install vagrant plugin vbguest: `vagrant plugin install vagrant-vbguest`
- **ansible** following the extensive guide on their website [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
  - **Tested with ansible-core (2.11)**
  - `pip install ansible-core==2.11.1 --user`
- **virtualbox** actually the vms are provided to be run on virtualbox so you need a working virtualbox environement on your computer
- **pywinrm** be sure you got the pywinrm package installed `pip install pywinrm`
- **ansible windows** `ansible-galaxy collection install ansible.windows`
- **ansible community.windows** `ansible-galaxy collection install community.windows`
- **ansible chocolatey** `ansible-galaxy collection install chocolatey.chocolatey`
- **ansible community.general**  `ansible-galaxy collection install community.general`
- you also need `sshpass` for the elk installation

> Vagrant and virtualbox are used to provide the virtual machines and Ansible is use to automate the configuration and vulnerabilites setup.

### Space use
- the lab take environ 60Go (but you have to get the space for the vms vagrant images windows server 2016 (6.15Go) / windows server 2019 (6.52) / ubuntu 18.04 (502M))
- the total space needed for the lab is ~80-100 Go (and more if you take snapshots)

### Start / Setup
The default domain will be **sevenkingdoms.local**, on the subnet 192.168.56.1/24 and each machine has only been allocated with 1CPU and 1024MB of memory. If you want to change some of these performance settings you can modify the Vagrantfile.

To have the lab up and running this is the commands you should do:

```bash
git clone git@github.com:Orange-Cyberdefense/GOAD.git
cd GOAD
vagrant up # this will create the vms
cd ansible/
ansible-playbook main.yml # this will configure the vms in order to play ansible when the vms are ready
```

- when you finish playing you could do :
```
vagrant halt # will stop all the vm
```

- to just relaunch the lab (no need to replay ansible as you already do that in the first place)
```
vagrant up   # will start the lab
```

- if you got some errors see the troobleshooting section at the end of the document

### Limit to one host
- Limit to one host with --limit

```
ansible-playbook main.yml --limit=dc02
```

### Update
If you want to update and replay the vulnerabilities playbook to update the lab you should do :
```
git pull
cd ansible/
ansible-playbook vulns.yml
```

## LAB Content - sevenkingdoms.local

### Servers
This lab is actually composed of three virtual machines:
- **kingslanding** : DC01 running on Windows Server 2019 (2020.07.17 with windefender enabled by default)
- **dragonstone**  : DC02 running on Windows Server 2016 (2017.12.14 and windefender disabled by default)
- **winterfell**   : Simple Server running on Windows Server 2019 (2020.07.17 with windefender disabled by default)

The lab setup is automated using vagrant and ansible automation tools.
You can change the vm version in the Vagrantfile according to Stefan Scherer vagrant repository : https://app.vagrantup.com/StefanScherer

Blueteam :
- **elk** a kibana is configured on http://192.168.56.50:5601 to follow the lab events
- infos : log encyclopedia : https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/

### Users/Groups and associated vulnerabilites/scenarios
- STARKS
  - arya.stark:        start user: password Needle
  - eddard.stark:      DOMAIN ADMIN / NTLM relay with responder
  - catelyn.stark:     ACL forcechangepassword on eddard.stark
  - robb.stark:        RESPONDER LLMR
  - sansa.stark:       ACL writeproperty-self-membership Domain Admins
  - brandon.stark:     ASREP_ROASTING
  - rickon.stark:      GPO abuse (Edit Settings on "ChangeWallpaperInBlue" GPO)
  - theon.greyjoy:
  - jon.snow:          KERBEROASTING
  - hodor:             PASSWORD SPRAY (user=password)
- NIGHT WATCH
  - samwell.tarly:     Password in ldap description
  - jeor.mormont:      ACL writedacl-writeowner on group Night Watch
- LANISTERS
  - tywin.lannister:   ACL genericall-on-user cersei.lannister
  - jaime.lannister:   ACL genericwrite-on-user cersei.lannister
  - tyron.lannister:   ACL self-self-membership-on-group Domain Admins
  - cersei.lannister:  DOMAIN ADMIN
- BARATHEON
  - robert.baratheon:  DOMAIN ADMIN
  - joffrey.baratheon: 
  - renly.baratheon:
  - stannis.baratheon: ACL genericall-on-computer dragonstone
- SMALL COUNCIL
  - petyer.baelish:    ACL writeproperty-on-group Domain Admins
  - lord.varys:        ACL genericall-on-group Domain Admins
  - maester.pycelle:   ACL write owner on group Domain Admins

## ROAD MAP
- [X] smbshare anonymous
- [X] two DC
- [X] smb not signed
- [X] responder
- [X] zerologon
- [X] windows defender
- [X] ASREPRoast
- [X] kerberoasting
- [X] AD acl abuse 
- [X] Unconstraint delegation
- [X] Ntlm relay
- [ ] GPO abuse (in progress not tested)
- [ ] generate certificate and enable ldaps
- [ ] RBCD
- [ ] mitm6
- [ ] printerbug / drop the mic
- [ ] smbshare null session
- [ ] exchange sur kingslanding ou une autre machine ?
- [ ] ms17.010 (windows 7)
- [ ] zone transfert
- [ ] tomcat + RMI
- [ ] LAPS
- [ ] sccm
- [ ] mssql trusted link ?
- [ ] add asp server
- [ ] exchange abuse

## MISC commands
### Force replication
- On dragonstone play as domain admin user :
```
repadmin /replicate kingslanding.sevenkingdoms.local dragonstone.sevenkingdoms.local dc=sevenkingdoms,dc=local /full
```

### vagrant usefull commands (vm management)
- start all lab vms :
```
vagrant up
```

- start only one vm :
```
vagrant up <vmname>
```

- stop all the lab vm :
```
vagrant halt
```

- drop all the lab vm (because you want to recreate all) (carrefull : this will erase all your lab instance)
```
vagrant destroy
```

### ansible commands (provisionning management)
#### Play only an ansible part
- only play shares of member_server.yml :
```
ansible-playbook -i hosts --user=vagrant member_server.yml --tags "shares"
```

#### Play only on some server
```
ansible-playbook -i hosts -l dc2 --user=vagrant domain_controller.yml
```

#### Add some vulns
```
ansible-playbook -i hosts --user=vagrant vulns.yml
```


## Troubleshooting

### Ansible-playbook

#### old Ansible version

```bash
ERROR! no action detected in task. This often indicates a misspelled module name, or incorrect module path.
 
The error appears to have been in '/home/hrrb0032/Documents/mission/GOAD/roles/domain_controller/tasks/main.yml': line 8, column 3, but maybe elsewhere in the file depending on the exact syntax problem.
 
The offending line appears to be:
 
- name: disable enhanced exit codes
^ here
```

solution : upgrade Ansible

### winrm

```bash
PLAY [DC01 - kingslanding] *******************************************************

 

TASK [Gathering Facts] ***********************************************************
fatal: [192.168.56.10]: FAILED! => {"msg": "winrm or requests is not installed: No module named winrm"}

 

PLAY RECAP ***********************************************************************
192.168.56.10              : ok=0    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
```

solution : pip install pywinrm



### winrm send input timeout

```bash
TASK [Gathering Facts] ****************************************************************************************************************************************************
[WARNING]: ERROR DURING WINRM SEND INPUT - attempting to recover: WinRMOperationTimeoutError
ok: [192.168.56.11]
```

solution : wait or if crashed then re-run Ansible script



### Domain controller : ensure Users are present 

```bash
TASK [domain_controller : Ensure that Users presents in ou=<kingdom>,dc=SEVENKINGDOMS,dc=local] ***************************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was:    at Microsoft.ActiveDirectory.Management.Commands.ADCmdletBase`1.ProcessRecord()
failed: [192.168.56.10] (item={u'key': u'lord.varys', u'value': {u'city': u"King's Landing", u'password': u'_W1sper_$', u'name': u'Lord Varys', u'groups': u'Small Council', u'path': u'OU=Users,OU=Crownlands,OU=kingdoms,DC=SEVENKINGDOMS,DC=local'}}) => {"ansible_loop_var": "item", "changed": false, "item": {"key": "lord.varys", "value": {"city": "King's Landing", "groups": "Small Council", "name": "Lord Varys", "password": "_W1sper_$", "path": "OU=Users,OU=Crownlands,OU=kingdoms,DC=SEVENKINGDOMS,DC=local"}}, "msg": "Unhandled exception while executing module: An unspecified error has occurred"}

```
 solution : re-run Ansible script

## Thanks to

This repo is based on the work of [jckhmr](https://github.com/jckhmr/adlab) and [kkolk](https://github.com/kkolk/mssql)
