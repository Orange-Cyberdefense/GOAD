# Provisioning

- Now you got all the VMS created, great!
- The next step is the provisioning with ansible.
- You can run ansible from :
  - a docker container
  - OR your linux host
  - OR a linux VM with an host only adapter on the same network as the lab's vms.

## Run ansible with docker

- If you want to do the provisioning from a docker container you could launch the following command to prepare the container

```bash
cd /opt/goad
sudo docker build -t goadansible .
```

- And launch the provisioning with :

```bash
sudo docker run -ti --rm --network host -h goadansible -v $(pwd):/goad -w /goad/ansible goadansible ansible-playbook -i ../ad/<LAB>/data/inventory -i ../ad/<LAB>/providers/<PROVIDER>/inventory main.yml
```

- This will launch ansible on the docker container.
- The --network host option will launch it on your host network so the vms should be accessible by docker for 192.168.56.1/24
- The -v mount the local repository containing goad in the folder /goad of the docker container
- The -i indicate the global inventory to use with ansible (must not contains variables)
- The second -i indicate the provider inventory to use with ansible (must contains the variables)
- And than the playbook main.yml is launched
- Please note that the vms must be in a running state, so vagrant up must have been done and finished before launching the ansible playbook.


#### Run ansible on your host (or from a linux vm in the same network as the lab)

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
ansible-galaxy install -r requirements.yml
```

- And than you can launch the ansible provisioning with (note that the vms must be in a running state, so vagrant up must have been done before that)

```bash
ansible-playbook -i ../ad/GOAD/data/inventory -i ../ad/GOAD/providers/virtualbox/inventory main.yml # this will configure the vms in order to play ansible when the vms are ready (for virtualbox provider and goad lab)
```

### Start / Setup / Run
The default domain will be **sevenkingdoms.local**, on the subnet 192.168.56.1/24 and each machine has been allocated with 2CPU and 4GB of memory. If you want to change some of these performance settings you can modify the Vagrantfile (please note that with less RAM the install process sometimes crash, if it append just relaunch the ansible playbook).

To have the lab up and running this is the commands you should do:

- VMs start/creation if not exist

```bash
pwd
/opt/GOAD  # place yourself in the GOAD folder (where you cloned the project)
vagrant up # this will create the vms (this command must be run in the folder where the Vagrantfile is present)
```

- VMs provisioning
  - in one command just play :

```bash
ansible-playbook -i ../ad/<LAB>/data/inventory -i ../ad/<LAB>/providers/<PROVIDER>/inventory main.yml # this will configure the vms in order to play ansible when the vms are ready
```

- To run the provisioning from the docker container run (you should be in the same folder as the Dockerfile):

```bash
sudo docker run -ti --rm --network host -h goadansible -v $(pwd):/goad -w /goad/ansible goadansible ansible-playbook -i ../ad/<LAB>/data/inventory -i ../ad/<LAB>/providers/<PROVIDER>/inventory main.yml
```

- Or you can run playbooks one by one (mostly for debug or if you get trouble during install)
  - The main.yml playbook is build in multiples parts. each parts can be re-run independently but the play order must be keep in cas you want to play one by one :

```
ANSIBLE_COMMAND="ansible-playbook -i ../ad/GOAD/data/inventory -i ../ad/GOAD/providers/virtualbox/inventory"
$ANSIBLE_COMMAND build.yml            # Install stuff and prepare vm
$ANSIBLE_COMMAND ad-servers.yml       # create main domains, child domain and enroll servers
$ANSIBLE_COMMAND ad-parent_domain.yml # create parent domain
$ANSIBLE_COMMAND ad-child_domain.yml  # create child domain
sleep 5m
$ANSIBLE_COMMAND ad-members.yml       # add child members
$ANSIBLE_COMMAND ad-trusts.yml        # create the trust relationships
$ANSIBLE_COMMAND ad-data.yml          # import the ad datas : users/groups...
$ANSIBLE_COMMAND ad-gmsa.yml          # run gmsa
$ANSIBLE_COMMAND laps.yml             # run laps
$ANSIBLE_COMMAND ad-relations.yml     # set the rights and the group domains relations
$ANSIBLE_COMMAND adcs.yml             # Install ADCS on essos
$ANSIBLE_COMMAND ad-acl.yml           # set the ACE/ACL
$ANSIBLE_COMMAND servers.yml          # Install IIS and MSSQL
$ANSIBLE_COMMAND security.yml         # Configure some securities (adjust av enable/disable)
$ANSIBLE_COMMAND vulnerabilities.yml  # Configure some vulnerabilities
$ANSIBLE_COMMAND reboot.yml           # reboot all
```

- When you finish playing you could do :

```bash
vagrant halt # will stop all the vm
```

- To just relaunch the lab (no need to replay ansible as you already do that in the first place)

```bash
vagrant up   # will start the lab
```

- If you got some errors see the troubleshooting section at the end of the document, but in most case if you get errors during install, don't think and just replay the main playbook (most of the errors which could came up are due to windows latency during installation, wait few minutes and replay the playbook)

Additionally, all of the above features are nicelly wrapped into a `goad.sh` script that makes provisioning a breeze. Additionally there are `check.sh` script and various `setup.sh` scripts inside `scripts/` that makes preparing the environment easier.

## Enabling and disabling default vagrant user

*It is again important to mention that all the environments are deployed with default credentials of `vagrant:vagrant` because of the underlying templates. This is a lab environment which is inherently insecure.*

However you might not want this default credentials to be available so there are no unintended solutions for the lab. This was made easier with ansible roles that disable this.

```bash
ansible-playbook -i ../ad/<LAB>/data/inventory -i ../ad/<LAB>/providers/<PROVIDER>/inventory disable_vagrant.yml
```

If you want again to manage the lab you can reenable the user.

```bash
ansible-playbook -i ../ad/<LAB>/data/inventory -i ../ad/<LAB>/providers/<PROVIDER>/inventory enable_vagrant.yml
```

The same can be also achieved with the `goad.sh` wrapper for example:

```bash
./goad.sh -t disablevagrant -l GOAD -p vmware_esxi -m local
```