To deploy on Windows we need a few steps over and above standard VMWare setup detailed in install_with_vmware.md.

## Prerequisites

- Tooling to install on Windows
  - [Vmware workstation](https://www.vmware.com/products/workstation-pro/workstation-pro-evaluation.html)
  - [Vagrant for Windows](https://developer.hashicorp.com/vagrant/install?product_intent=vagrant#Windows)
  - [Vmware utility driver](https://developer.hashicorp.com/vagrant/install/vmware)
  - Vagrant plugins:
    - vagrant-reload
    - vagrant-vmware-desktop
- Kali or Ubuntu VM, installed inside VMWare Workstation
    - Ensure the VM has two NICs, one NAT/Bridged for Internet and a second in the same subnet as GOAD default setup which is `192.168.56.0` and `255.255.255.0` netmask via VMWare Workstation's Virtual Network Editor.
    - Install Ansible and Dependencies
    ```
    pip install --upgrade pip
    pip install ansible-core==2.12.6
    pip install pywinrm

    sudo apt install sshpass lftp rsync openssh-client
    git clone https://github.com/Orange-Cyberdefense/GOAD
    ```
    - Install Ansible requirements
        - drop into `GOAD/ansible` on Ubuntu/Kali VM and execute:
        `ansible-galaxy install -r ansible/requirements.yml`


## Setup VMs with Vagrant
Once pre-reqs have been installed, next thing to do is to deploy the baseline VMs with vagrant from cmd/PowerShell.

### Create the vms

- To create the VMs just run 

```powershell
cd ad\GOAD\providers\vmware
vagrant up
```

This will proceed to run through pulling down the five GOAD virtual machines. Once complete you can proceed to the next step which is deploying ansible to confirgure the VMs. 

### Deploy Ansible to Build VMs
Once VMs have all built with Vagrant, the next step is to hop into your Kali/Ubuntu VM and roll with running Ansible to configure them. To do this, navigate to the GOAD directory and run the goad.sh setup script as a standard user:

```
./goad.sh -t install -l GOAD -p vmware -m local -a
```

Provided you've done all the pre-req setup stages, this will run through the setup of all the VMs and configure them to the GOAD Ansible YML file specs.  