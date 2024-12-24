# VMware ESXi setup (aka "Virtualbox c'est no way")

<div align="center">
  <img alt="vagrant" width="150" height="150" src="./img/icon_vagrant.png">
  <img alt="icon_vwmare" width="150"  height="150" src="./img/icon_vmware_esxi.png">
  <img alt="icon_ansible" width="150"  height="150" src="./img/icon_ansible.png">
</div>

## Prerequisites

- Providing
  - [VMWare ESXi](https://www.vmware.com/products/esxi-and-esx.html) - [no longer free](https://kb.vmware.com/s/article/2107518)
  - [Vagrant](https://developer.hashicorp.com/vagrant/docs)
  - Vagrant plugins:
    - vagrant-reload
    - vagrant-vmware-esxi
    - vagrant-env
    - on some distribution also the vagrant plugins :
      - winrm
      - winrm-fs
      - winrm-elevated
  - ovftool (https://developer.broadcom.com/tools/open-virtualization-format-ovf-tool/latest)

- Provisioning with python
  - Python3 (>=3.8)
  - [ansible-core==2.12.6](https://docs.ansible.com/ansible/latest/index.html)
  - pywinrm

- Or provisioning With Docker
  - [Docker](https://www.docker.com/)


## check dependencies

- If you run ansible locally

```bash
./goad.sh -t check -l GOAD -p vmware_esxi -m local
```

- If you run ansible with docker

```bash
./goad.sh -t check -l GOAD -p vmware_esxi -m docker
```

## Install dependencies

> If the check is not ok you will have to install the dependencies (no automatic install is provided as it depend of your package manager and distribution). Here some install command lines are given for ubuntu.

### Install VMWare ESXi

Consult their [docs](https://docs.vmware.com/en/VMware-vSphere/8.0/vsphere-esxi-installation/GUID-93D0227B-E5ED-40B0-B8E2-71141A32EB00.html)

- Note that you will need to install the vmware-esxi plugin after the vagrant installation : 
```
vagrant plugin install vagrant-vmware-esxi
```

### Install Vagrant

- **vagrant** from their official site [vagrant](https://developer.hashicorp.com/vagrant/downloads). __The version you can install through your favorite package manager (apt, yum, ...) is probably not the latest one__.
- Vagrant installation is well describe in [the official vagrant page](https://developer.hashicorp.com/vagrant/downloads) (tests are ok on 2.3.4)
- Some github issues indicate vagrant got some issue on some version and work well with 2.2.19 (`apt install vagrant=2.2.19`)

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
```

- on some recent versions (ubuntu 23.04), you should consider run also:
```bash
gem install winrm winrm-fs winrm-elevated
```

### Install docker

- If you want to run the ansible install from docker and don't install all the python dependencies just [install docker](https://docs.docker.com/engine/install/)

### Or Install Ansible locally

- If you want to play ansible from your host or a linux vm you should launch the following commands :

- *Create a python >= 3.8 virtualenv*

```bash
sudo apt install git
git clone git@github.com:Orange-Cyberdefense/GOAD.git
cd GOAD/ansible
sudo apt install python3.8-venv
python3.8 -m virtualenv .venv
source .venv/bin/activate
```

- Install ansible and pywinrm in the .venv
  - **ansible** following the extensive guide on their website [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
  - **Tested with ansible-core (2.12)**
  - **pywinrm** be sure you got the pywinrm package installed

```
python3 -m pip install --upgrade pip
python3 -m pip install ansible-core==2.12.6
python3 -m pip install pywinrm
```

- Install all the ansible-galaxy requirements
  - **ansible windows**
  - **ansible community.windows**
  - **ansible chocolatey** (not needed anymore)
  - **ansible community.general**
```
ansible-galaxy install -r ansible/requirements.yml
```

## Install

### Enter credentials

Since ESXi server is remote you will need to provide the environment details of the ESXi server. Those are located inside the `ad/<LAB>/providers/vmware_esxi/.env` file.

```
GOAD_VAGRANT_ESXIHOSTNAME is the IP or hostname of your ESXi server
GOAD_VAGRANT_ESXIUSERNAME is the username for your ESXi server
GOAD_VAGRANT_ESXIPASSWORD is the password for your ESXi server
GOAD_VAGRANT_ESXINETNAT is the ESXi portgroup for a NAT network present that contains your ESXi server and the deployment server
GOAD_VAGRANT_ESXINETDOM is the ESXi portgroup that is isolated domain network for the lab
GOAD_VAGRANT_ESXISTORE is the ESXi datastore where all the LAB files will be stored
```

You can use this file either by sourcing it or if you followed the previous steps that is done automatically with `vagrant-env` plugin.

Sourcing inside a bash shell can be done as:

```bash
source ad/<LAB>/providers/vmware_esxi/.env
```

### Launch installation automatically

- This will launch vagrant up and the ansible playbooks
- If you run ansible locally
```bash
./goad.sh -t install -l GOAD -p vmware_esxi -m local
```

- If you run ansible on docker
```bash
./goad.sh -t install -l GOAD -p vmware_esxi -m docker
```

### Launch installation manually

### Create the vms

- To create the VMs just run 

```bash
cd ad/GOAD/providers/vmware_esxi
vagrant up
```

*note: For some distributions, you may need to run additional commands to install WinRM gems* this can be done via the following commands:

```bash
vagrant plugin install winrm
vagrant plugin install winrm-fs
vagrant plugin install winrm-elevated
```

- At the end of the vagrantup you should have the vms created and running


### Launch provisioning with Docker

- launch the provision script (launch ansible with failover on errors)

```bash
sudo docker run -ti --rm --network host -h goadansible -v $(pwd):/goad -w /goad/ansible goadansible /bin/bash -c "ANSIBLE_COMMAND='ansible-playbook -i ../ad/GOAD/data/inventory -i ../ad/GOAD/providers/vmware_esxi/inventory' ../scripts/provisionning.sh"
```

- or launch ansible from docker directly

```bash
sudo docker run -ti --rm --network host -h goadansible -v $(pwd):/goad -w /goad/ansible goadansible ansible-playbook -i ../ad/GOAD/data/inventory -i ../ad/GOAD/providers/vmware_esxi/inventory main.yml
```

### Launch provisioning with Ansible

- launch the provision script (launch ansible with failover on errors)

```bash
cd ansible
export ANSIBLE_COMMAND="ansible-playbook -i ../ad/GOAD/data/inventory -i ../ad/GOAD/providers/vmware_esxi/inventory"
../scripts/provisionning.sh
```

- or launch ansible directly

```bash
cd ansible/
ansible-playbook -i ../ad/GOAD/data/inventory -i ../ad/GOAD/providers/vmware_esxi/inventory main.yml
```


- Details on the provisioning process are here : [provisioning.md](./provisioning.md)

## Additional features supported for the vmware_esxi provider

### snapshot

It creates a snapshot for all Vagrant deployed boxes in a lab.

Example usage:

```bash
./goad.sh -t snapshot -l GOAD -p vmware_esxi -m local
```

### reset

It reverts to a latest snapshot without deleting it for all Vagrant deployed boxes in a lab.

Example usage:

```bash
./goad.sh -t reset -l GOAD -p vmware_esxi -m local
```