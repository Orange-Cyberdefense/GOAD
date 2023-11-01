# Promox VM packer

## Infos 
[https://mayfly277.github.io/posts/GOAD-on-proxmox-part2-packer/](https://mayfly277.github.io/posts/GOAD-on-proxmox-part2-packer/)

## Windows iso

Windows iso evaluation to download and put inside the iso storage of proxmox

- [Windows-10-22h2_x64_en-us.iso](https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66750/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso)
- [windows_server_2016_14393.0_eval_x64.iso](https://software-download.microsoft.com/download/pr/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO)
- [windows_server2019_x64FREE_en-us.iso](https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66749/17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso)

- Be sure to name the iso like the name inside 
## Cloudbase init 

- Download here : https://cloudbase.it/cloudbase-init/
- Put the msi at : /packer/proxmox/scripts/sysprep/CloudbaseInitSetup_Stable_x64.msi (54,7M)


## Windows update
- If you want to create updated template change the `<!-- no updates -->` and `<!-- WITH WINDOWS UPDATES ` comment in the answerfiles/Autounattend.xml files.


## Prepare

```bash
sudo apt-get install mkisofs
cd /root/GOAD/packer/proxmox/
./build_proxmox_iso.sh
```
- Put the packer/proxmox/iso/scripts_withcloudinit.iso into proxmox's iso folder

## Configure

```bash
cp config.auto.pkrvars.hcl.template config.auto.pkrvars.hcl
```
- And adapt the value to your proxmox config

## ubuntu vm : install packer

```bash
apt update
apt -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update
apt install packer
```

## BUILD

```
packer validate -var-file=config.json windows_server2019_proxmox.json
packer build -var-file=config.json windows_server2019_proxmox.json
```