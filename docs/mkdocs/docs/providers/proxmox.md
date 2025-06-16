# :simple-proxmox: Proxmox

<div align="center">
  <img alt="terraform" width="166" height="150" src="./../img/icon_terraform.png">
  <img alt="terraform" width="205" height="150" src="./../img/icon_proxmox.png">
  <img alt="icon_ansible" width="150"  height="150" src="./../img/icon_ansible.png">
</div>

- A complete guide to proxmox installation is available here : [https://mayfly277.github.io/categories/proxmox/](https://mayfly277.github.io/categories/proxmox/)

## Prerequisites

- [Packer](https://developer.hashicorp.com/packer/downloads?product_intent=packer)
- [Terraform](https://www.terraform.io/downloads.html)

## Installation

This guide will walk you through setting up GOAD on Proxmox. The installation process consists of several key steps:

1. Creating a dedicated user for infrastructure as code
2. Setting up software-defined networking
3. Creating the jumpbox template
4. Choosing your installation method
5. Building Windows VM templates
6. Configuring and running GOAD

### 1. Create Infrastructure User

First, create a dedicated user that will be used for the GOAD setup:

```bash
# Create user and set password
pveum useradd infra_as_code@pve
pveum passwd infra_as_code@pve

# Create Packer role with necessary permissions
pveum roleadd Packer -privs "VM.Config.Disk VM.Config.CPU VM.Config.Memory VM.Clone Datastore.AllocateTemplate Datastore.Audit Datastore.AllocateSpace Sys.Modify VM.Config.Options VM.Allocate VM.Audit VM.Console VM.Config.CDROM VM.Config.Cloudinit VM.Config.Network VM.PowerMgmt VM.Config.HWType VM.Monitor SDN.Use Pool.Allocate"

# Assign Packer role to the user
pveum acl modify / -user 'infra_as_code@pve' -role Packer
```

### 2. Configure Software-Defined Networking

Set up the network infrastructure for GOAD. You can customize the subnet according to your needs:

```bash
# Create SDN zone
pvesh create cluster/sdn/zones --type simple --ipam pve --zone goad

# Create virtual network
pvesh create cluster/sdn/vnets --vnet vgoad --zone goad

# Configure subnet
pvesh create cluster/sdn/vnets/vgoad/subnets/ --subnet 192.168.56.0/24 --type subnet --gateway 192.168.56.1

# Apply SDN configuration
pvesh set cluster/sdn
```

### 3. Create Jumpbox Template

Create a jumpbox template using Ubuntu Cloud image. Save the following script as `create_jumpbox.sh`:

```bash
#!/bin/bash

# Configuration variables - adjust these according to your environment
VMID=1000
BRIDGE="vmbr0"
STORAGE="local-zfs"
VMNAME="ubuntu2204-cloud"

# Update system and install required tools
apt update -y && apt install libguestfs-tools -y

# Download Ubuntu Cloud image
wget -N https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

# Customize the image
virt-customize -a jammy-server-cloudimg-amd64.img --install qemu-guest-agent
virt-customize -a jammy-server-cloudimg-amd64.img --run-command "echo -n > /etc/machine-id"

# Create and configure VM
qm create "$VMID" --memory 2048 --core 2 --name "$VMNAME" --net0 virtio,bridge="$BRIDGE"
qm importdisk "$VMID" jammy-server-cloudimg-amd64.img "$STORAGE"
qm set "$VMID" --scsihw virtio-scsi-single --scsi0 "$STORAGE:vm-${VMID}-disk-0",cache=writeback,discard=on
qm set "$VMID" --boot c --bootdisk scsi0
qm set "$VMID" --scsi1 "$STORAGE:cloudinit"
qm set "$VMID" --agent enabled=1
qm set "$VMID" --ostype l26
qm set "$VMID" --serial0 socket
qm set "$VMID" --vga serial0
qm set "$VMID" --cpu cputype=host

# Convert to template
qm template "$VMID"
```

Make the script executable, modify the variables VMID, BRIDGE, STORAGE and VMNAME and run it:
```bash
chmod +x create_jumpbox.sh
./create_jumpbox.sh
```

### 4. Choose Your Installation Method

There are two distinct ways to set up and run GOAD:

#### Method 1: Remote Installation (from your local machine)
This method requires you to:
- Run `goad.sh` from your local machine
- Have Linux or WSL on your local machine
- Have Packer and Terraform installed on your local machine

A jumpbox will be automatically created during the GOAD installation process.

#### Method 2: Local Installation (from jumpbox)
This method is ideal if you:
- Don't have Linux or WSL on your local machine
- Don't want to install Packer/Terraform on your local machine
- Prefer to do everything from within the lab environment

You'll need to manually create and configure the jumpbox BEFORE starting the GOAD installation:

Create a jumpbox VM with two network interfaces:
- First NIC: Connected to your main network (e.g., vmbr0)
- Second NIC: Connected to the GOAD network (vgoad)

Choose the method that best fits your environment and requirements.

### 5. Build Windows VM Templates

#### Method 1: Remote Installation
1. Clone the GOAD repository on your local machine:
```bash
git clone https://github.com/Orange-Cyberdefense/GOAD
cd GOAD/packer/proxmox
```

2. Configure Packer variables:
```bash
cp config.auto.pkrvars.hcl.template config.auto.pkrvars.hcl
```

Edit `config.auto.pkrvars.hcl` with your Proxmox settings:
```hcl
proxmox_url             = "https://192.168.1.1:8006/api2/json"
proxmox_username        = "infra_as_code@pve"
proxmox_password        = "CHANGEME"
proxmox_skip_tls_verify = "true"
proxmox_node            = "proxmox-goad"
proxmox_pool            = "Templates"
proxmox_iso_storage     = "local"
proxmox_vm_storage      = "local-lvm"
proxmox_bridge          = "vmbr0"
```

3. Build the templates:
```bash
# Create ISO files and update Windows variable files
./build_proxmox_iso.sh

# Initialize Packer
packer init .

# Build Windows Server templates
# Note: For the normal GOAD Lab you only need to build one Windows Server 2016 and one Windows Server 2019 Template
# Optional: Use the *_uptodate variants (e.g. windows_server2019_proxmox_cloudinit_uptodate.pkvars.hcl) 
# to apply updates during the build process
packer build -var-file=windows_server2019_proxmox_cloudinit.pkvars.hcl .
packer build -var-file=windows_server2016_proxmox_cloudinit.pkvars.hcl .
```

#### Method 2: Local Installation
1. Clone the GOAD repository on the jumpbox:
```bash
git clone https://github.com/Orange-Cyberdefense/GOAD
cd GOAD/packer/proxmox
```

2. Follow the same steps as Method 1 to configure Packer and build templates

### 6. Configure and Run GOAD

#### Method 1: Remote Installation
1. Run `goad.sh` once to set up dependencies:
```bash
./goad.sh
```

2. Configure GOAD settings in `~/.goad/goad.ini`:
```ini
[proxmox]
pm_api_url = https://192.168.1.1:8006/api2/json               # Proxmox URL
pm_user = infra_as_code@pve                                   # Proxmox User Account
pm_node = GOAD                                                # Proxmox Node (server name)
pm_pool = GOAD                                                # Proxmox Pool Name
pm_full_clone = false                                         # Full clone of the templates
pm_storage = local                                            # Storage of vms (commonly local-lvm or local-zfs)
pm_network_bridge = vgoad                                     # Network Bridge in your software defined network
pm_network_bridge_jump = vmbr0                                # Reachable network bridge to your jumpbox
pm_network_model = e1000                                      # DO NOT MODIFY
pm_dns_server = 1.1.1.1                                       # DNS Server during the provisioning, before domain creation
pm_jumpbox_public_ip = 192.168.1.100                          # IP Address of your jumpbox
pm_jumpbox_public_ip_netmask = /24                            # Subnet Mask of you jumpbox
pm_jumpbox_gateway = 192.168.1.1                              # Gateway of your jumpbox

[proxmox_templates_id]
winserver2019_x64 = 102
winserver2016_x64 = 103
winserver2019_x64_utd = 104
windows10_22h2_x64 = 105
ubuntu_jumpbox = 106
```

3. Install GOAD (this will automatically create the jumpbox):
```bash
./goad.sh -t install -l GOAD -p proxmox -m remote -ip 192.168.56
```

#### Method 2: Local Installation (on jumpbox)
1. Run `goad.sh` once to set up dependencies:
```bash
./goad.sh
```

2. Configure GOAD settings in `~/.goad/goad.ini` (same as Method 1)

3. Install GOAD (using your manually created jumpbox):
```bash
./goad.sh -t install -l GOAD -p proxmox -m local -ip 192.168.56
```