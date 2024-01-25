resource "proxmox_vm_qemu" "dc01" {
    name = "NHA-DC01"
    desc = "DC01 - windows server 2019 - 192.168.20.10"
    qemu_os = "win10"
    target_node = var.pm_node
    pool = var.pm_pool

    sockets = 1
    cores = 2
    memory = 3096
    agent = 1
    clone = "WinServer2019x64-cloudinit-qcow2"

   network {
     bridge    = "vmbr3"
     model     = "e1000"
     tag       = 20
   }
    lifecycle {
      ignore_changes = [
        disk,
      ]
    }
   nameserver = "192.168.20.1"
   ipconfig0 = "ip=192.168.20.10/24,gw=192.168.20.1"
}

resource "proxmox_vm_qemu" "dc02" {
    name = "NHA-DC02"
    desc = "DC02 - windows server 2019 - 192.168.20.11"
    qemu_os = "win10"
    target_node = var.pm_node
    pool = var.pm_pool
    sockets = 1
    cores = 2
    memory = 3096
    agent = 1
    clone = "WinServer2019x64-cloudinit-qcow2"
    network {
      bridge    = "vmbr3"
      model     = "e1000"
      tag       = 20
    }
    lifecycle {
      ignore_changes = [
        disk,
      ]
    }
   nameserver = "192.168.20.1"
   ipconfig0 = "ip=192.168.20.11/24,gw=192.168.20.1"
}

resource "proxmox_vm_qemu" "srv01" {
    name = "NHA-SRV01"
    desc = "SRV01 - windows server 2019 - 192.168.20.21"
    qemu_os = "win10"
    target_node = var.pm_node
    pool = var.pm_pool
    sockets = 1
    cores = 2
    memory = 4096
    agent = 1
    clone = "WinServer2019x64-cloudinit-qcow2"

    network {
      bridge    = "vmbr3"
      model     = "e1000"
      tag       = 20
    }
    lifecycle {
      ignore_changes = [
        disk,
      ]
    }
    nameserver = "192.168.20.1"
    ipconfig0 = "ip=192.168.20.21/24,gw=192.168.20.1"
    #ipconfig1 = "ip=172.16.0.10/24,gw=172.16.0.1"
}

resource "proxmox_vm_qemu" "srv02" {
    name = "NHA-SRV02"
    desc = "SRV02 - windows server 2019 - 192.168.20.22"
    qemu_os = "win10"
    target_node = var.pm_node
    pool = var.pm_pool
    sockets = 1
    cores = 2
    memory = 4096
    agent = 1
    clone = "WinServer2019x64-cloudinit-qcow2"

    network {
      bridge    = "vmbr3"
      model     = "e1000"
      tag       = 20
    }
    lifecycle {
      ignore_changes = [
        disk,
      ]
    }
    nameserver = "192.168.20.1"
    ipconfig0 = "ip=192.168.20.22/24,gw=192.168.20.1"
}

resource "proxmox_vm_qemu" "srv03" {
    name = "NHA-SRV03"
    desc = "SRV03 - windows server 2016 - 192.168.20.23"
    qemu_os = "win10"
    target_node = var.pm_node
    pool = var.pm_pool
    sockets = 1
    cores = 2
    memory = 4096
    agent = 1
    clone = "WinServer2019x64-cloudinit-qcow2"

    network {
      bridge    = "vmbr3"
      model     = "e1000"
      tag       = 20
    }
    
    lifecycle {
      ignore_changes = [
        disk,
      ]
    }
    nameserver = "192.168.20.1"
    ipconfig0 = "ip=192.168.20.23/24,gw=192.168.20.1"
}
