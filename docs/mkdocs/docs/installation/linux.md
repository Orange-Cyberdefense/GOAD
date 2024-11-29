# :material-linux: Linux

- First you will prepare your host for an hypervisor
- Second you will prepare your python environment

## Prepare your Provider

=== ":simple-virtualbox: Virtualbox"

    - Vagrant
        - In order to download vm and create them on virtualbox you need to install vagrant
        - [https://developer.hashicorp.com/vagrant/install#linux](https://developer.hashicorp.com/vagrant/install#linux)
    
    - Virtualbox
        - Install virtualbox
        ```bash
        sudo apt install virtualbox
        ```

    - Install vagrant plugins
    ```bash
    vagrant plugin install vagrant-reload vagrant-vbguest winrm winrm-fs winrm-elevated
    ```

    !!! warning "Disk space"
        The lab takes about 77GB (but you have to get the space for the vms vagrant images windows server 2016 (22GB) / windows server 2019 (14GB) / ubuntu 18.04 (502M))
        The total space needed for the lab is ~115 GB (depend on the lab you use and it will take more space if you take snapshots), be sure you have enough disk space before install.

    !!! warning "RAM"
        Depending on the lab you will need a lot of ram to run all the virtual machines. Be sure to have at least 20GB for GOAD-Light and 24GB for GOAD.

=== ":simple-vmware: Vmware workstation"

    !!! tip
        Vmware workstation is now free for personal use !

    - Vagrant
        - In order to download vm and create them on virtualbox you need to install vagrant
        - [https://developer.hashicorp.com/vagrant/install#linux](https://developer.hashicorp.com/vagrant/install#linux)
    
    - Vmware workstation
        - Install vmware workstation [https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Workstation+Pro](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Workstation+Pro)

    - Install vagrant vmware utility : [https://developer.hashicorp.com/vagrant/install/vmware](https://developer.hashicorp.com/vagrant/install/vmware#linux)

    - Install the following vagrant plugins:
        ```
        vagrant plugin install vagrant-reload vagrant-vmware-desktop winrm winrm-fs winrm-elevated
        ```

    !!! warning "Disk space"
        The lab takes about 77GB (but you have to get the space for the vms vagrant images windows server 2016 (22GB) / windows server 2019 (14GB) / ubuntu 18.04 (502M))
        The total space needed for the lab is ~115 GB (depend on the lab you use and it will take more space if you take snapshots), be sure you have enough disk space before install.

    !!! warning "RAM"
        Depending on the lab you will need a lot of ram to run all the virtual machines. Be sure to have at least 20GB for GOAD-Light and 24GB for GOAD.

=== ":material-microsoft-azure: Azure"
    - Azure CLI
        - Install azure cli
            [https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots)
        - Connect to azure :
            ```bash
            az login
            ```
    - Terraform
        - The installation to Azure use terraform so you will have to install it: [https://developer.hashicorp.com/terraform/install](https://developer.hashicorp.com/terraform/install)


=== ":simple-amazon: Aws"
    - AWS CLI

        - Install aws cli 
            [https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions)
        - Create an aws access key and secret for goad usage
            - Go to IAM > User > your user > Security credentials
            - Click the Create access key button
            - Create a group "[goad]" in credentials file ~/.aws/credentials
                ```
                [goad]
                aws_access_key_id = changeme
                aws_secret_access_key = changeme
                ```
            - Be sure to chmod 400 the file

            !!! warning "credentials in plain text"
                Storing credentials in plain text is always a bad idea, but aws cli work like that be sure to restrain the right access to this file

    - Terraform
        - The installation to Aws use terraform so you will have to install it: [https://developer.hashicorp.com/terraform/install](https://developer.hashicorp.com/terraform/install)

=== ":simple-proxmox: Proxmox"

    - Proxmox install is very complex and use a lot of steps
    - A complete guide to proxmox installation is available here : [https://mayfly277.github.io/categories/proxmox/](https://mayfly277.github.io/categories/proxmox/)

=== "🏟️  Ludus"

    - To add GOAD on Ludus please use goad directly on the server.
    - By now goad can work only directly on the server and not from a workstation client.

    - Install Ludus : [https://docs.ludus.cloud/docs/quick-start/install-ludus/](https://docs.ludus.cloud/docs/quick-start/install-ludus/)

    - Be sure to create an administrator user and keep his api key

    - Once your installation is complete on ludus server (debian 12) and your user is created do :
    
    ```bash
    git clone https://github.com/Orange-Cyberdefense/GOAD.git
    cd GOAD
    sudo apt install python3.11-venv
    ./goad.sh
    ...>exit
    vim ~/.goad/goad.ini # add the api_key in the config file (keep impersonate to yes and use an admin user)
    ./goad.sh -p ludus
    ...>set_lab XXX # GOAD/GOAD-Light/NHA/SCCM
    ...>install
    ```

## Prepare your python environment for goad.py

=== "Classic"
    
    - To run the Goad installation/management script you will need : **Python version >=3.8** with venv module installed
    
    - Install the python3-venv corresponding to your python version 
    
    ```bash
    sudo apt install python<version>-venv
    ```
    
    - Example:
    
    ```bash
    sudo apt install python3.10-venv
    ```

    - Then you are ready to launch 

    ```
    ./goad.sh
    ```

    - The script will :
        - verify python version >=3.8
        - create a venv in `~/.goad/.venv`
        - launch python requirements installation
        - launch ansible-galaxy collections requirements installation
        - start goad.py with the venv created

    !!! tip
        if you got an error during requirements installation, look at the error and delete `~/.goad/.venv` before try again

    !!! tip
        if you need to force a python version change the variable `py=python3` to `py=python3.10` for example in the `goad.sh` script

=== "With poetry"

    - Install python dependencies:
    ```
    poetry install
    ``` 

    - Install ansible-galaxy requirements:
        - If python < 3.11
        ```
        poetry run ansible-galaxy ansible/requirements.yml
        ```

        - If python >= 3.11
        ```
        poetry run ansible-galaxy ansible/requirements_311.yml
        ```

    - Run goad:
    ```
    poetry run python3 goad.py
    ```

=== "Provisioning with docker"
    
    !!! info
        With this method ansible-core will not be installed locally on your venv
    
    - [x] be sure you have docker installed on your os for the provisioning part (ansible will be run from the container)
    - [x] To run the Goad installation/management script you will need :
        -  Python (version >= 3.8) with venv module installed
    
    - Install the python3-venv corresponding to your python version 
    
    ```bash
    sudo apt install python<version>-venv
    ```
    
    - Example:
    
    ```bash
    sudo apt install python3.10-venv
    ```
    
    - Run goad with `./goad_docker.sh` instead of `./goad.sh` to install the dependencies without the ansible part (local and runner provisioning method will not be available)