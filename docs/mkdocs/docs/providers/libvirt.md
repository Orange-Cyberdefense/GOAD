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


??? info ":material-debian: debian 13 quick install"

    ```bash
    # Add some dependencies
    sudo apt install sshpass lftp rsync openssh-client python3-venv git build-essential gpg wget

    # Install libvirt
    sudo apt install -y qemu-system-x86 libvirt-daemon-system qemu-system-modules-spice ebtables libguestfs-tools ruby-fog-libvirt libvirt-dev

    # Add your user to the kvm and libvirt groups
    sudo usermod -aG kvm,libvirt $USER
    # You now have to relog afterwards in order for this change to take affect.

    # Install vagrant
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install vagrant

    # Install Vagrant plugins
    vagrant plugin install vagrant-reload vagrant-libvirt winrm winrm-fs winrm-elevated

    git clone https://github.com/Orange-Cyberdefense/GOAD.git
    cd GOAD
    # verify installation
    ./goad.sh -t check -l GOAD -p libvirt

    # install
    ./goad.sh -t install -l GOAD -p libvirt

    # launch goad in interactive mode
    ./goad.sh
    ```

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
    If there is some missing dependencies go to the [installation](../installation/index.md) chapter and follow the guide according to your os.

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


#  Troubleshooting / Frequent asked questions
!!! question "I am seeing '[fog][WARNING] Unrecognized arguments: libvirt_ip_command' while providing GOAD"
    This warning originates from `fog-libvirt`, a dependency of the `vagrant-libvirt` plugin.
    Despite the warning, multiple people were able to deploy GOAD (and it's variants) without any issues.


!!! question "Call to virConnectOpen failed: authentication unavailable: no polkit agent available to authenticate action 'org.libvirt.unix.manage"
    This error usually occurs because the user trying to install the GOAD-Lab is not part of the `KVM` and/or `LIBVIRT` group.
    To fix this, the user has to be added to the group using `sudo usermod -aG kvm,libvirt $USER`.
    Afterwards the user has to relog in order for the group assignment to take affect.

    If you are trying to automate the installation of GOAD in a way where relogging is hard/not possible (e.g. when using cloud-init), you can use the `newgrp` command.


!!! question "Error while creating domain: Error saving the server: Call to virDomainDefineXML failed: unsupported configuration: domain configuration does not support video model 'qxl'"
    This error indicates that you didn't install a package that provides qemu with a spice display.
    On Debian, this can be fixed by installing `qemu-system-modules-spice`.


!!! question "I am using qemu/kvm user sessions"
    We currently expect access to the `default` libvirt network.
    If this is not the case, then you will experience errors during the installation.

    To fix this, you need to point to the system session using `export VIRSH_DEFAULT_CONNECT_URI=qemu:///system`.
    Depending on the software versions that you are using, you need to use `LIBVIRT_DEFAULT_URI` (see [Specifying URIs to virsh, virt-manager and virt-install](https://libvirt.org/uri.html#specifying-uris-to-virsh-virt-manager-and-virt-install))
