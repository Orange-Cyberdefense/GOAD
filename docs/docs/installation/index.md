# 🚀 Installation

In the last version, GOAD use no more bash for the installation/management script.
The goad management script is now written in :simple-python: python to permit more flexibility and cover the needs to create a Windows WSL support.

- First prepare you system for GOAD execution:
    - :material-linux: [Linux](/installation/linux)
    - :material-microsoft-windows: [Windows](/installation/windows)

- Installation depend of the provider you use, please follow the appropriate guide :
    - :simple-virtualbox: [Install with Virtualbox](/providers/virtualbox)
    - :simple-vmware: [Install with VmWare](/providers/vmware)
    - :simple-proxmox: [Install with Proxmox](/providers/proxmox)
    - :material-microsoft-azure: [Install with Azure](/providers/azure)
    - :simple-amazon: [Install with Aws](/providers/aws)
    - 🏟️ [Install with Ludus](/providers/ludus)

## TLDR - quick install

??? info "TLDR : ubuntu 22.04 quick install"

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