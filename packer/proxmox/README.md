# Promox VM packer

## BUILD
```
packer validate -var-file=config.json windows_server2019_proxmox.json
packer build -var-file=config.json windows_server2019_proxmox.json
```


## ubuntu vm : install packer
apt update
apt -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update
apt install packer

## cloudbase init 
download here : https://cloudbase.it/cloudbase-init/

put the msi at : /proxmox/packer/scripts/sysprep/CloudbaseInitSetup_1_1_2_x64.msi (54,7M)