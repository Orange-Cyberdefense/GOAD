# 🚀 Installation

In the last version, GOAD use no more bash for the installation/management script.
The goad management script is now written in :simple-python: python to permit more flexibility and cover the needs to create a Windows WSL support.

- First prepare you system for GOAD execution:
    - :material-linux: [Linux](linux.md)
    - :material-microsoft-windows: [Windows](windows.md)

- Installation depend of the provider you use, please follow the appropriate guide :
    - :simple-virtualbox: [Install with Virtualbox](../providers/virtualbox.md)
    - :simple-vmware: [Install with VmWare](../providers/vmware.md)
    - :simple-proxmox: [Install with Proxmox](../providers/proxmox.md)
    - :material-microsoft-azure: [Install with Azure](../providers/azure.md)
    - :simple-amazon: [Install with Aws](../providers/aws.md)
    - 🏟️ [Install with Ludus](../providers/ludus.md)

## TLDR - quick install

??? info "TLDR : :material-ubuntu: ubuntu 22.04 quick install"

    ```bash
    # Install vbox
    sudo apt install virtualbox

    # Install vagrant
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install vagrant

    # Install Vagrant plugins
    vagrant plugin install vagrant-reload vagrant-vbguest winrm winrm-fs winrm-elevated
    
    # Add some dependencies
    sudo apt install sshpass lftp rsync openssh-client python3.10-venv

    git clone https://github.com/Orange-Cyberdefense/GOAD.git
    cd GOAD
    # verify installation
    ./goad.sh -t check -l GOAD -p virtualbox

    # install
    ./goad.sh -t install -l GOAD -p virtualbox

    # launch goad in interactive mode
    ./goad.sh
    ```

## Installation

- Installation is in three parts :
    - Templating : this will create the template to use (needed only for proxmox and ludus)
    - Providing : this will instantiate the virtual machines depending on your provider
    - Provisioning : it is always made with ansible, it will install all the stuff to create the lab

- GOAD script cover the providing and provisioning part

- The install script take multiple parameters:
    - `-p`  : the provider to use (vmware/virtualbox/proxmox/ludus/azure/aws)
    - `-l`  : the lab to install (GOAD/GOAD-Light/SCCM/NHA/MINILAB)
    - `-m`  : the method of installation (local/runner/docker/remote), most of the time don't change it
    - `-ip` : the ip range to use

- The easy way is just launch `./goad.sh` and use help `?`in the interactive prompt


### Python Dependencies

- Goad in :simple-python: python come with a lot of dependencies as you can see in the `requirements.yml` file on the root of the project.
- If you don't want to run the provisioning from your python venv but only from docker you can use `goad_docker.sh` script instead of `goad.sh`. This will run the ansible with the docker method instead of local or runner.

This are the python dependencies used by goad :

- Mandatory for :simple-python: goad.py:
```
rich
psutil
Jinja2
pyyaml
```

- Mandatory for :material-ansible: ansible inside goad (for provisioning method local or runner) :
  - python < 3.11
    ```
    # Ansible
    ansible_runner
    ansible-core==2.12.6
    pywinrm
    ```
  - python >= 3.11
    ```
    # Ansible
    setuptools
    ansible_runner
    ansible-core==2.18.0
    pywinrm
    ```

- Mandatory for :material-microsoft-azure: azure provider :
```
# AZURE
azure-identity
azure-mgmt-compute
azure-mgmt-network
```

- Mandatory for :simple-amazon: aws provider :
```
# AWS
boto3
```

- Mandatory for :simple-proxmox: proxmox provider:
```
# Proxmox
proxmoxer
requests
```

- You can launch goad without installing all the pip package but for that you will have to disable some dependencies with the `-d` arguments:
```
-d vmware     : disable vmware provider
-d virtualbox : disable virtualbox provider
-d azure      : disable azure provider
-d aws        : disable azure provider
-d proxmox    : disable proxmox provider
-d ludus      : disable ludus provider
-d local      : disable local provisioning method (if you use docker only)
-d runner     : disable ansible runner provisioning method (if you use docker only)
-d remote     : disable remote provisioning method
-d docker     : disable docker provisioning method
```

## Configuration files

### $HOME/.goad/goad.ini

- On the first launch goad create a global configuration file at : `$HOME/.goad/goad.ini` this file contains some default configuration and some parameters needed by some providers.

- If you change the `[default]` config it will change the default selection when goad start
- Others configurations are related to specific providers

```
[default]
; lab: goad / goad-light / minilab / nha / sccm
lab = GOAD
; provider : virtualbox / vmware / aws / azure / proxmox
provider = vmware
; provisioner method : local / remote
provisioner = local
; ip_range (3 first ip digits)
ip_range = 192.168.56

[aws]
aws_region = eu-west-3
aws_zone = eu-west-3c

[azure]
az_location = westeurope

[proxmox]
pm_api_url = https://192.168.1.1:8006/api2/json
pm_user = infra_as_code@pve
pm_node = GOAD
pm_pool = GOAD
pm_full_clone = false
pm_storage = local
pm_vlan = 10
pm_network_bridge = vmbr3
pm_network_model = e1000

[proxmox_templates_id]
winserver2019_x64 = 102
winserver2016_x64 = 103
winserver2019_x64_utd = 104
windows10_22h2_x64 = 105

[ludus]
; api key must not have % if you have a % in it, change it by a %%
ludus_api_key = change_me
use_impersonation = yes
```

### Global configuration : globalsettings.ini

- Goad got a global configuration file : `globalsettings.ini` used by the ansible provisioning
- This file is an ansible inventory file.
- This file is always added at the end of the ansible inventory file list so you can override values here
- You can change it before running the installation to modify :
    - keyboard_layouts
    - proxy configuration
    - add a route to the vm
    - change the default dns_forwarder
    - disable ssl for winrm communication
