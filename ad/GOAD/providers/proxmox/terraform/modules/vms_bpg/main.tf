resource "proxmox_virtual_environment_vm" "windows_vm" {
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