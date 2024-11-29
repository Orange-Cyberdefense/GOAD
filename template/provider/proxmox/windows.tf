variable "vm_config" {
  type = map(object({
    name               = string
    desc               = string
    cores              = number
    memory             = number
    clone              = string
    dns                = string
    ip                 = string
    gateway            = string
  }))

  default = {
    {{windows_vms}}
  }
}

resource "proxmox_virtual_environment_vm" "bgp" {
  for_each = var.vm_config

    name = each.value.name
    description = each.value.desc
    node_name   = var.pm_node
    pool_id     = var.pm_pool

    operating_system {
      type = "win10"
    }

    cpu {
      cores   = each.value.cores
      sockets = 1
    }

    memory {
      dedicated = each.value.memory
    }

    clone {
      vm_id = lookup(var.vm_template_id, each.value.clone, -1)
      full  = var.pm_full_clone
      retries = 2
    }

    agent {
      # read 'Qemu guest agent' section, change to true only when ready
      enabled = true
    }

    network_device {
      bridge  = var.network_bridge
      model   = var.network_model
      vlan_id = var.network_vlan
    }

    lifecycle {
      ignore_changes = [
        vga,
      ]
    }

    initialization {
      datastore_id = var.storage
      dns {
        servers = [
          each.value.dns
        ]
      }
      ip_config {
        ipv4 {
          address = each.value.ip
          gateway = each.value.gateway
        }
      }
    }
}

# # "Telmate/proxmox" "3.0.1-rc1" template (change clone value to template name to use it and change the provider in main)
# resource "proxmox_vm_qemu" "telmate-proxmox8" {
#     for_each = var.vm_config
# 
#     name = each.value.name
#     desc = each.value.desc
#     qemu_os = "win10"
#     target_node = var.pm_node
#     sockets = 1
#     cores = each.value.cores
#     memory = each.value.memory
#     agent = 1
#     clone = lookup(var.vm_template_name, each.value.clone, "")
#     full_clone = var.pm_full_clone
#     os_type     = "cloud-init"
#     boot        = "order=sata0;ide3"
#     # disk type need to match with disk type in template, in this case sata0
#     bootdisk    = "sata0"
#     disks{
#       sata {
#         sata0 {
#           disk {
#             size      = 40
#             storage   = var.storage
#           }
#         }
#       }
#     }
#     # Specify the cloud-init cdrom storage
#     cloudinit_cdrom_storage = var.storage
#     network {
#       bridge    = var.network_bridge
#       model     = var.network_model
#       tag       = var.network_vlan
#     }
#     nameserver = each.value.dns
#     ipconfig0 = "ip=${each.value.ip},gw=${each.value.gateway}"
# }
# 


# # old telmate template (change clone value to template name to use it) and change the provider in main
# resource "proxmox_vm_qemu" "telmate-proxmox7" {
#     for_each = var.vm_config
# 
#     name = each.value.name
#     desc = each.value.desc
#     qemu_os = "win10"
#     target_node = var.pm_node
#     pool = var.pm_pool
#     sockets = 1
#     cores = each.value.cores
#     memory = each.value.memory
#     agent = 1
#     clone = lookup(var.vm_template_name, each.value.clone, "")
#     full_clone = var.pm_full_clone
# 
#     network {
#       bridge    = var.network_bridge
#       model     = var.network_model
#       tag       = var.network_vlan
#     }
#     
#     lifecycle {
#       ignore_changes = [
#         disk,
#       ]
#     }
#     nameserver = each.value.dns
#     ipconfig0 = "ip=${each.value.ip},gw=${each.value.gateway}"
# }