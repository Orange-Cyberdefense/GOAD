<div align="center">
  <h1><img alt="GOAD (Game Of Active Directory)" src="./docs/img/logo_GOAD.png"></h1>
  <br>
</div>

## Description
GOAD is a pentest active directory LAB project.
The purpose of this lab is to give pentesters a vulnerable Active directory environment ready to use to practice usual attack techniques.

> **Warning**
> This lab is extremely vulnerable, do not reuse recipe to build your environment and do not deploy this environment on internet without isolation (this is a recommendation, use it as your own risk).<br>
> This repository was build for pentest practice.

## Licenses
This lab use free windows VM only (180 days). After that delay enter a license on each server or rebuild all the lab (may be it's time for an update ;))

## Available labs

- [GOAD](./ad/GOAD/README.md) : 5 vms, 2 forests, 3 domains (full goad lab)
<div align="center">
<img alt="GOAD" width="800" src="./docs/img/GOAD_schema.png">
</div>

- [GOAD-Light](./ad/GOAD-Light/README.md) : 3 vms, 1 forest, 2 domains (smaller goad lab for those with a smaller pc)
<div align="center">
<img alt="GOAD Light" width="600" src="./docs/img/GOAD-Light_schema.png">
</div>

- [MINILAB](./ad/MINILAB/README.md): 2 vms, 1 forst, 1 domain (basic lab with one DC (windows server 2019) and one Workstation (windows 10))

- [SCCM](./ad/SCCM/README.md) : 4 vms, 1 forest, 1 domain, with microsoft configuration manager installed
<div align="center">
<img alt="SCCM" width="600" src="./docs/img/SCCMLAB_overview.png">
</div>

- [NHA](./ad/NHA/README.md) : A challenge with 5 vms and 2 domains. no schema provided, you will have to find out how break it.

## Requirements

- Used space
  - The lab takes about 77GB (but you have to get the space for the vms vagrant images windows server 2016 (22GB) / windows server 2019 (14GB) / ubuntu 18.04 (502M))
  - The total space needed for the lab is ~115 GB (and more if you take snapshots)

- Linux operating system
  - The lab intend to be installed from a **Linux host** and was tested only on this.
  - Some people have successfully installed the lab from a windows OS, to do that they create the VMs with vagrant and have done the ansible provisioning part from a linux machine.
  - In this case the linux machine used to do the provisioning must be setup with one adapter on NAT and one adapter on the same virtual private network as the lab.


### tldr; quick install

- You are on linux, you already got virtualbox, vagrant and docker installed on your host and you know what you are doing, just run :
```bash
./goad.sh -t check -l GOAD -p virtualbox -m docker
./goad.sh -t install -l GOAD -p virtualbox  -m docker
```
- Now you can grab a coffee :coffee: it will take time :)

## Installation

- Installation depend of the provider you use, please follow the appropriate guide :
  - [Install with Virtualbox](./docs/install_with_virtualbox.md)
  - [Install with VmWare](./docs/install_with_vmware.md)
  - [Install with Proxmox](./docs/install_with_proxmox.md)
  - [Install with Azure](./docs/install_with_azure.md)

- Installation is in three parts :
  1. Templating : this will create the template to use (needed only for proxmox) 
  2. Providing : this will instantiate the virtual machines depending on your provider
  3. Provisioning : it is always made with ansible, it will install all the stuff to create the lab

### Check before install

- For linux users check dependencies installation before install :

```
./goad -t check -l <LAB> -p <PROVIDER> -m <ANSIBLE_RUN_METHOD>
```

- LAB: lab must be one of the following (folder in ad/)
   - GOAD
   - GOAD-Light

- PROVIDER : provider must be one of the following:
   - virtualbox
   - vmware
   - azure
   - proxmox

- ANSIBLE_RUN_METHOD : ansible method to use :
   - local : to use local ansible install
   - docker : to use docker ansible install

- **Please install all the needed tools before run the install process**
- There is no automatic installer for the dependencies tools (virtualbox, vagrant, python, ansible,... ) you will have to install them by yourself depending on your package manager an linux system.

### Install

- Launch all the install (vagrant or terraform) vms creation followed by ansible provisioning :

```
./goad -t install -l <LAB> -p <PROVIDER> -m <ANSIBLE_RUN_METHOD>
```

- The goad install will run all the ansible playbook one by one with a failover to restart the ansible playbook if something goes wrong (sometimes vms or playbook hit timeout so this will restart the playbook automatically)

### goad.sh options

- `-a` : ansible only is played during install task (no vagrant or terraform). This is useful if you install and run vagrant on windows and then launch the provisioning from a different computer (example : a kali linux connected to goad network)
- `-r <ansible_file.yml>` : run only one ansible task (useful to run elk.yml or run only one playbook)
- `-e` : enable elk in vagrant (example to install elk and play the elk playbook once you finish goad install run : `./goad.sh -t install -l GOAD -p virtualbox -m local -e elk -r elk.yml`)

## Provisioning

- The provisioning is always done with ansible, more detail on the ansible provisioning here : [Ansible provisioning](./docs/provisioning.md)

## WriteUp

- All the writeups of the Game Of Active Directory lab are available on this blog : [mayfly blog](https://mayfly277.github.io/categories/ad/)

## Troubleshoot

- see [troubleshoot](./docs/troubleshoot.md)

## Road Map
- [X] Password reuse between computer (PTH)
- [X] Spray User = Password
- [X] Password in description
- [X] SMB share anonymous
- [X] SMB not signed
- [X] Responder
- [X] Zerologon
- [X] Windows defender
- [X] ASREPRoast
- [X] Kerberoasting
- [X] AD Acl abuse 
- [X] Unconstraint delegation
- [X] Ntlm relay
- [X] Constrained delegation
- [X] Install MSSQL
- [X] MSSQL trusted link
- [X] MSSQL impersonate
- [X] Install IIS
- [X] Upload asp app
- [X] Multiples forest
- [X] Anonymous RPC user listing
- [X] Child parent domain
- [X] Generate certificate and enable ldaps
- [X] ADCS - ESC 1/2/3/4/6/8
- [X] Certifry
- [X] Samaccountname/nopac
- [X] Petitpotam unauthent
- [X] Printerbug
- [X] Drop the mic
- [X] Shadow credentials
- [X] Mitm6
- [X] Add LAPS
- [X] GPO abuse
- [X] Add Webdav
- [X] Add RDP bot
- [X] Add full proxmox integration
- [X] Add Gmsa (receipe created)
- [X] Add azure support
- [X] Refactoring lab and providers
- [X] Protected Users
- [X] Account is sensitive
- [X] Add PPL
- [X] Add Gmsa
- [X] Groups inside groups
- [X] Shares with secrets (all, sysvol)
- [ ] ADCS add vulns
- [ ] Add Applocker
- [ ] Add optional EDR install on goad
- [ ] Add attackbox + guacamole and openvpn creation

## Road Map for other labs (because these are too heavy for being embedded in goad)
- [X] Wsus (see SCCM lab)
- [X] Sccm (see SCCM lab)
- [ ] Exchange

## Lab organization

- The lab configuration is located on the ad/ folder
- Each Ad folder correspond to a lab and contains the following files :

```
ad/
  labname/            # The lab name must be the same as the variable : domain_name from the data/inventory
    data/
      config.json     # The json file containing all the variables and configuration of the lab
      inventory       # The global lab inventory (provider independent) (this should no contains variables)
    files/            # This folder contains files you want to copy on your vms
    scripts/          # This folder contains ps1 scripts you want to play on your vm (Must be added in the "scripts" entries of your vms)
    providers/        # Your lab available provider
      vmware/
        inventory     # specific vmware inventory
        Vagrantfile   # specific vmware vagrantfile
      virtualbox/
        inventory     # specific virtualbox inventory
        Vagrantfile   # specific virtualbox vagrantfile
      proxmox/
        terraform/    # specific proxmox terraform recipe
        inventory     # specific proxmox inventory
      azure/
        terraform/    # specific azure terraform recipe
        inventory     # specific azure inventory
```


## Special Thanks to

- Julien Arrault (Azure recipes)
- Thomas Rollain (tests & some vulns writing)
- Quentin Galliou (tests)

## Socials

<a target="_blank" rel="noopener noreferrer" href="https://twitter.com/intent/follow?screen_name=M4yFly" title="Follow"><img src="https://img.shields.io/twitter/follow/M4yFly?label=@M4yFly&style=social" width="100"  height="30" alt="Twitter Mayfly"></a>
<a target="_blank" rel="noopener noreferrer" href="https://discord.gg/NYy7rsMf3u" title="Join us on Discord"><img src="./docs/img/discord.png" width="100" height="30" alt="Join us on Discord"></a>

## Links
- https://unicornsec.com/home/siem-home-lab-series-part-1
- https://github.com/jckhmr/adlab
- https://www.jonathanmedd.net/2019/09/ansible-windows-and-powershell-the-basics-introduction.html
- https://www.secframe.com/badblood/
- https://josehelps.com/blog/2019-08-06_building-a-windows-2016-dc/
- https://medium.com/@vartaisecurity/lab-building-guide-virtual-active-directory-5f0d0c8eb907
- https://www.ansible.com/blog/an-introduction-to-windows-security-with-ansible
- https://github.com/rgl/windows-domain-controller-vagrant
- https://www.sconstantinou.com/powershell-active-directory-delegation-part-1/
- https://www.shellandco.net/playing-acl-active-directory-objects/
- https://github.com/clong/DetectionLab
- https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces
- ...

## Note
- This repo is based on the work of [jckhmr](https://github.com/jckhmr/adlab) and [kkolk](https://github.com/kkolk/mssql)
