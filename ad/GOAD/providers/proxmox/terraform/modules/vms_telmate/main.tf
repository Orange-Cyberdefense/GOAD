# "Telmate/proxmox" "3.0.1-rc1" template (change clone value to template name to use it and change the provider in main)
resource "proxmox_vm_qemu" "telmate-proxmox8" {
    for_each = var.vm_config

    name = each.value.name
    desc = each.value.desc
    qemu_os = "win10"
    target_node = var.pm_node
    sockets = 1
    cores = each.value.cores
    memory = each.value.memory
    agent = 1
    clone = lookup(var.vm_template_name, each.value.clone, "")
    full_clone = var.pm_full_clone
    os_type     = "cloud-init"
    boot        = "order=sata0;ide3"
    # disk type need to match with disk type in template, in this case sata0
    bootdisk    = "sata0"
    disks{
      sata {
        sata0 {
          disk {
            size      = 40
            storage   = var.storage
          }
        }
      }
    }
    # Specify the cloud-init cdrom storage
    cloudinit_cdrom_storage = var.storage
    network {
      bridge    = var.network_bridge
      model     = var.network_model
      tag       = var.network_vlan
    }
    nameserver = each.value.dns
    ipconfig0 = "ip=${each.value.ip},gw=${each.value.gateway}"
}
