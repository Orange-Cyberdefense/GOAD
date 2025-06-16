# Promox VM packer

## Infos 
[https://mayfly277.github.io/posts/GOAD-on-proxmox-part2-packer/](https://mayfly277.github.io/posts/GOAD-on-proxmox-part2-packer/)

## Prerequisites

### Install Packer
```bash
apt update
apt -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update
apt install packer
```

### Install mkisofs
```bash
sudo apt-get install mkisofs
```

## Windows ISO References

Windows ISO evaluation versions used in the build process:

- [Windows-10-22h2_x64_en-us.iso](https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66750/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso)
- [Windows-11-24h2_x64_en-us.iso](https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso)
- [windows_server_2016_14393.0_eval_x64.iso](https://software-static.download.prss.microsoft.com/pr/download/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO)
- [windows_server2019_x64FREE_en-us.iso](https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66749/17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso)

## Build Process

### Preparation Phase
When running `./build_proxmox_iso.sh`, the following happens:
1. Downloads all required Windows ISOs
2. Downloads and builds the Autounattend ISO containing:
   - Windows answer files
   - Post-installation scripts
   - Cloudbase-init setup
3. Downloads VirtIO drivers
4. Updates all checksums in the HCL files

### Packer Build Phase
When running `packer build`, the following sequence occurs:
1. All required ISOs are automatically uploaded to the Proxmox ISO storage
2. A new VM is created and started
3. The Autounattend file automatically configures Windows installation
4. If using the `_uptodate` variant, Windows updates are installed
5. Cloudbase-init is installed and configured
6. Sysprep is run to prepare the VM
7. The VM is shut down and converted to a template

### Configuration and Build

1. Configure Packer variables:
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

2. Build the templates:
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