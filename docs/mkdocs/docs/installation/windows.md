# :material-microsoft-windows: Windows

!!! info 
    To use GOAD on windows you will need WSL.

- First you will prepare your windows host for an hypervisor
- Second you will install debian 12 with WSL to run goad install script

## Prepare Windows Host

=== ":simple-virtualbox: Virtualbox"
    If you want to use virtualbox as an hypervisor to create your vm.

    - VAGRANT

        If you want to create the lab on your windows computer you will need vagrant. Vagrant will be responsible to automate the process of vm download and creation.

        - Download and install visual c++ 2019   : [https://aka.ms/vs/17/release/vc_redist.x64.exe](https://aka.ms/vs/17/release/vc_redist.x64.exe)
        - Install vagrant : [https://developer.hashicorp.com/vagrant/install](https://developer.hashicorp.com/vagrant/install)

    - Virtualbox

        - Install virtualbox <= 7.0 (vagrant support only to vbox7.0 at the time of writing) : [https://www.virtualbox.org/wiki/Download_Old_Builds_7_0](https://www.virtualbox.org/wiki/Download_Old_Builds_7_0)

        - Install the following vagrant plugins:

        ```
        vagrant.exe plugin install vagrant-reload vagrant-vbguest winrm winrm-fs winrm-elevated
        ```

    !!! warning "Disk space"
        The lab takes about 77GB (but you have to get the space for the vms vagrant images windows server 2016 (22GB) / windows server 2019 (14GB) / ubuntu 18.04 (502M))
        The total space needed for the lab is ~115 GB (depend on the lab you use and it will take more space if you take snapshots), be sure you have enough disk space before install.

    !!! warning "RAM"
        Depending on the lab you will need a lot of ram to run all the virtual machines. Be sure to have at least 20GB for GOAD-Light and 24GB for GOAD.

=== ":simple-vmware: Vmware Workstation"

    If you want to use vmware workstation as an hypervisor to create your vm.

    !!! tip
        Vmware workstation is now free for personal use !

    - VAGRANT

        If you want to create the lab on your windows computer you will need vagrant. Vagrant will be responsible to automate the process of vm download and creation.

        - Download and install visual c++ 2019   : [https://aka.ms/vs/17/release/vc_redist.x64.exe](https://aka.ms/vs/17/release/vc_redist.x64.exe)
        - Install vagrant : [https://developer.hashicorp.com/vagrant/install](https://developer.hashicorp.com/vagrant/install)

    - Vmware Workstation
        - Install vmware workstation : [https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Workstation+Pro](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Workstation+Pro)

        !!! bug "vmware workstation install bug"
            if you got an error about groups and permission during vmware workstation install consider running this in an administrator cmd prompt:
            ```
            net localgroup /add "Users"
            net localgroup /add "Authenticated Users"
            ```

        - Install vagrant vmware utility : [https://developer.hashicorp.com/vagrant/install/vmware](https://developer.hashicorp.com/vagrant/install/vmware)

        - Install the following vagrant plugins:

        ```
        vagrant.exe plugin install vagrant-reload vagrant-vmware-desktop winrm winrm-fs winrm-elevated
        ```

    !!! warning "Disk space"
        The lab takes about 77GB (but you have to get the space for the vms vagrant images windows server 2016 (22GB) / windows server 2019 (14GB) / ubuntu 18.04 (502M))
        The total space needed for the lab is ~115 GB (depend on the lab you use and it will take more space if you take snapshots), be sure you have enough disk space before install.

    !!! warning "RAM"
        Depending on the lab you will need a lot of ram to run all the virtual machines. Be sure to have at least 20GB for GOAD-Light and 24GB for GOAD.


=== ":simple-amazon: Aws"
    Nothing to prepare on windows host, install and prepare wsl and next follow linux install from your wsl console : [see aws linux install](linux.md/#__tabbed_1_4)

=== ":material-microsoft-azure: Azure"
    Nothing to prepare on windows host, install and prepare wsl and next linux install from your wsl console [see azure linux install](linux.md/#__tabbed_1_3)

=== ":simple-proxmox: Promox"
    Not supported, you will have to create a provisioning machine on your proxmox and run goad from then ([see proxmox linux install](linux.md/#__tabbed_1_5))

=== "🏟️  Ludus"
    Not supported, you will have to act from your ludus server ([see ludus linux install](linux.md/#__tabbed_1_6))

## Prepare WSL environment

Now your host environment is ready for virtual machine creation. Now we will install WSL to run the goad installation script.

### Install WSL

- First install wsl on your environment [https://learn.microsoft.com/en-us/windows/wsl/install](https://learn.microsoft.com/en-us/windows/wsl/install)
- Next go to the microsoft store and install debian (debian12)

### Prepare WSL distribution
- Open debian console then :

    - Verify you are using python version <= 11
    ```bash
    python3 --version
    ```

    - Install python packages
    ```bash
    sudo apt update
    sudo apt install python3 python3-pip python3-venv libpython3-dev
    ```

- Next you can clone and run goad

```bash
cd /mnt/c/whatever_folder_you_want
git clone https://github.com/Orange-Cyberdefense/GOAD.git
cd GOAD
./goad.sh
```
