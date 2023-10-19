resource "proxmox_vm_qemu" "dc01" {
    name = "GOAD-DC01"
    desc = "DC01 - windows server 2019 - 192.168.10.10"
    qemu_os = "win10"
    target_node = var.pm_node
    pool = var.pm_pool

    sockets = 1
    cores = 2
    memory = 3096
    agent = 1
    clone = "WinServer2019x64-cloudinit-qcow2"
    full_clone = var.pm_full_clone

   network {
     bridge    = "vmbr3"
     model     = "e1000"
     tag       = 10
   }
    lifecycle {
      ignore_changes = [
        disk,
      ]
    }
   nameserver = "192.168.10.1"
   ipconfig0 = "ip=192.168.10.10/24,gw=192.168.10.1"
}

resource "proxmox_vm_qemu" "dc02" {
    name = "GOAD-DC02"
    desc = "DC02 - windows server 2019 - 192.168.10.11"
    qemu_os = "win10"
    target_node = var.pm_node
    pool = var.pm_pool
    sockets = 1
    cores = 2
    memory = 3096
    agent = 1
    clone = "WinServer2019x64-cloudinit-qcow2"
    full_clone = var.pm_full_clone

    network {
      bridge    = "vmbr3"
      model     = "e1000"
      tag       = 10
    }
    lifecycle {
      ignore_changes = [
        disk,
      ]
    }
   nameserver = "192.168.10.1"
   ipconfig0 = "ip=192.168.10.11/24,gw=192.168.10.1"
}

resource "proxmox_vm_qemu" "DC03" {
    name = "GOAD-DC03"
    desc = "DC03 - windows server 2016 - 192.168.10.12"
    qemu_os = "win10"

    target_node = var.pm_node
    pool = var.pm_pool

    sockets = 1
    cores = 2
    memory = 3096
    agent = 1
    clone = "WinServer2016x64-cloudinit-qcow2"
    full_clone = var.pm_full_clone

    network {
      bridge    = "vmbr3"
      model     = "e1000"
      tag       = 10 
    }
    lifecycle {
      ignore_changes = [
        disk,
      ]
    }
   nameserver = "192.168.10.1"
   ipconfig0 = "ip=192.168.10.12/24,gw=192.168.10.1"
}

resource "proxmox_vm_qemu" "srv02" {
    name = "GOAD-SRV02"
    desc = "SRV02 - windows server 2019 - 192.168.10.22"
    qemu_os = "win10"
    target_node = var.pm_node
    pool = var.pm_pool
    sockets = 1
    cores = 2
    memory = 4096
    agent = 1
    clone = "WinServer2019x64-cloudinit-qcow2"
    full_clone = var.pm_full_clone

    network {
      bridge    = "vmbr3"
      model     = "e1000"
      tag       = 10
    }
    lifecycle {
      ignore_changes = [
        disk,
      ]
    }
    nameserver = "192.168.10.1"
    ipconfig0 = "ip=192.168.10.22/24,gw=192.168.10.1"
}

resource "proxmox_vm_qemu" "srv03" {
    name = "GOAD-SRV03"
    desc = "SRV03 - windows server 2016 - 192.168.10.23"
    qemu_os = "win10"
    target_node = var.pm_node
    pool = var.pm_pool
    sockets = 1
    cores = 2
    memory = 4096
    agent = 1
    clone = "WinServer2016x64-cloudinit-qcow2"
    full_clone = var.pm_full_clone

    network {
      bridge    = "vmbr3"
      model     = "e1000"
      tag       = 10
    }
    
    lifecycle {
      ignore_changes = [
        disk,
      ]
    }
    nameserver = "192.168.10.1"
    ipconfig0 = "ip=192.168.10.23/24,gw=192.168.10.1"
}

