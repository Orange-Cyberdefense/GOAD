# Proxmox setup

<div align="center">
  <img alt="terraform" width="150" height="150" src="./img/icon_terraform.png">
  <img alt="terraform" width="150" height="150" src="./img/icon_proxmox.png">
  <img alt="icon_ansible" width="150"  height="150" src="./img/icon_ansible.png">
</div>

- A complete guide to proxmox installation is available here : [https://mayfly277.github.io/categories/proxmox/](https://mayfly277.github.io/categories/proxmox/)

## Prerequisites

- [Packer](https://developer.hashicorp.com/packer/downloads?product_intent=packer)
- [Terraform](https://www.terraform.io/downloads.html)

## Installation

- Once you have prepared your provisioning vm (you can use the scripts/setup_proxmox.sh for prerequistes installation)
- And once your prerequisites are ready see [https://mayfly277.github.io/posts/GOAD-on-proxmox-part2-packer/](https://mayfly277.github.io/posts/GOAD-on-proxmox-part2-packer/) to prepare the template for proxmox


- You can run the automatic installation

```bash
# check prerequisites
./goad.sh -t check -l GOAD -p proxmox
# Install
./goad.sh -t install -l GOAD -p proxmox
```

- Details on the provisioning process are here : [provisioning.md](./provisioning.md)