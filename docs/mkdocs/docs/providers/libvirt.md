# :simple-libvirt: Libvirt

<div align="center">
  <img alt="vagrant" width="153" height="150" src="../img/icon_vagrant.png">
  <img alt="icon_libvirt" width="150"  height="150" src="../img/icon_libvirt.png">
  <img alt="icon_ansible" width="150"  height="150" src="../img/icon_ansible.png">
</div>

## Prerequisites

- Providing
    - [Libvirt](https://libvirt.org/)
    - [Vagrant](https://developer.hashicorp.com/vagrant/docs)
    - Vagrant plugins:
        - vagrant-reload
        - vagrant-libvirt
        - winrm
        - winrm-fs
        - winrm-elevated

- Provisioning
    - Python3 >=3.8
    - goad requirements
    - ansible-galaxy goad requirements


## Check dependencies

```bash
./goad.sh -p libvirt
GOAD/libvirt/local/192.168.56.X > check
```

```bash
GOAD/libvirt/local/192.168.56.X > check
[+] vagrant found in PATH 
[-] not enough disk space, only 69.75680923461914 Gb available 
[+] ansible-playbook found in PATH 
[+] Ansible galaxy collection ansible.windows is installed 
[+] Ansible galaxy collection community.general is installed 
[+] Ansible galaxy collection community.windows is installed 
[+] vagrant plugin vagrant-reload is installed 
[+] libvirtd is running 
[+] vagrant plugin vagrant-libvirt is installed 
```

!!! info
    If there is some missing dependencies goes to the [installation](../installation/index.md) chapter and follow the guide according to your os.

!!! note
    check give mandatory dependencies in red and non mandatory in yellow (but you should be compliant with them too depending one your operating system)

## Install

- To install run the goad script and launch install or use the goad script arguments

```bash
./goad.sh -p libvirt
GOAD/libvirt/local/192.168.56.X > set_lab <lab>  # here choose the lab you want (GOAD/GOAD-Light/NHA/SCCM)
GOAD/libvirt/local/192.168.56.X > set_ip_range <ip_range>  # here choose the  ip range you want to use ex: 192.168.56
GOAD/libvirt/local/192.168.56.X > install
```

- or all in command line with arguments

```bash
./goad.sh -t install -p libvirt -l <lab> -ip <ip_range_to_use>
```