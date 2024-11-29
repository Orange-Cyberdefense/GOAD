# :simple-vmware: Vmware

!!! quote
    "Virtualbox c'est no way" @mpgn

<div align="center">
  <img alt="vagrant" width="153" height="150" src="../img/icon_vagrant.png">
  <img alt="icon_vwmare" width="176"  height="150" src="../img/icon_vwmare.png">
  <img alt="icon_ansible" width="150"  height="150" src="../img/icon_ansible.png">
</div>

## Prerequisites

- Providing 
    - [Vmware workstation](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Workstation+Pro)
    - [Vagrant](https://developer.hashicorp.com/vagrant/docs)
    - [Vmware utility driver](https://developer.hashicorp.com/vagrant/install/vmware)
    - Vagrant plugins:
        - vagrant-reload
        - vagrant-vmware-desktop
        - winrm
        - winrm-fs
        - winrm-elevated

- Provisioning
    - Python3 >=3.8
    - goad requirements
    - ansible-galaxy goad requirements


## check dependencies

```bash
./goad.sh -p vmware
GOAD/vmware/local/192.168.56.X > check
```

![vmware_check.png](./../img/vmware_check.png)

!!! info
    If there is some missing dependencies goes to the [installation](../installation/index.md) chapter and follow the guide according to your os.

!!! note
    check give mandatory dependencies in red and non mandatory in yellow (but you should be compliant with them too depending one your operating system)

## Install

- To install run the goad script and launch install or use the goad script arguments

```bash
./goad.sh -p vmware
GOAD/vmware/local/192.168.56.X > set_lab <lab>  # here choose the lab you want (GOAD/GOAD-Light/NHA/SCCM)
GOAD/vmware/local/192.168.56.X > set_ip_range <ip_range>  # here choose the  ip range you want to use ex: 192.168.56 (only the first three digits)
GOAD/vmware/local/192.168.56.X > install
```

![vmware_install](./../img/vmware_install.png)

- or all in command line with arguments

```bash
./goad.sh -t install -p vmware -l <lab> -ip <ip_range_to_use>
```
