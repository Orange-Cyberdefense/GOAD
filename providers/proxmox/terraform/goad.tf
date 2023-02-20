resource "proxmox_vm_qemu" "dc01" {
    name = "DC01"
    desc = "DC01 - windows server 2019 - 192.168.56.10"

    target_node = var.pm_node
    pool = var.pm_pool

    sockets = 1
    cores = 2
    memory = 4096
    agent = 1
    clone = "WinServer2019x64-cloudinit"

   network {
     bridge    = "vmbr1"
     model     = "e1000"
     tag       = 1 
   }
   network {
     bridge    = "vmbr1"
     model     = "e1000"
     tag       = 1
   }

   ipconfig0 = "ip=192.168.56.10/24"
   ipconfig1 = "gw=192.168.56.2,ip=dhcp"
}

resource "proxmox_vm_qemu" "dc02" {
    name = "DC02"
    desc = "DC02 - windows server 2019 - 192.168.56.11"
    target_node = var.pm_node
    pool = var.pm_pool
    sockets = 1
    cores = 2
    memory = 4096
    agent = 1
    clone = "WinServer2019x64-cloudinit"
    network {
      bridge    = "vmbr1"
      model     = "e1000"
      tag       = 1 
    }
    network {
      bridge    = "vmbr1"
      model     = "e1000"
      tag       = 1 
    }
   ipconfig0 = "ip=192.168.56.11/24"
   ipconfig1 = "gw=192.168.56.2,ip=dhcp"
}

resource "proxmox_vm_qemu" "DC03" {
    name = "DC03"
    desc = "DC03 - windows server 2016 - 192.168.56.12"

    target_node = var.pm_node
    pool = var.pm_pool

    sockets = 1
    cores = 2
    memory = 4096
    agent = 1
    clone = "WinServer2016x64-cloudinit"

    network {
      bridge    = "vmbr1"
      model     = "e1000"
      tag       = 1 
    }
    network {
      bridge    = "vmbr1"
      model     = "e1000"
      tag       = 1 
    }

   ipconfig0 = "ip=192.168.56.12/24"
   ipconfig1 = "gw=192.168.56.2,ip=dhcp"
}

resource "proxmox_vm_qemu" "srv02" {
    name = "SRV02"
    desc = "SRV02 - windows server 2019 - 192.168.56.22"
    target_node = var.pm_node
    pool = var.pm_pool
    sockets = 1
    cores = 2
    memory = 4096
    agent = 1
    clone = "WinServer2019x64-cloudinit"

    network {
      bridge    = "vmbr1"
      model     = "e1000"
      tag       = 1
    }
    network {
     bridge    = "vmbr1"
     model     = "e1000"
     tag       = 1 
    }
    ipconfig0 = "ip=192.168.56.22/24"
    ipconfig1 = "gw=192.168.56.2,ip=dhcp"
}

resource "proxmox_vm_qemu" "srv03" {
    name = "SRV03"
    desc = "SRV03 - windows server 2016 - 192.168.56.23"
    target_node = var.pm_node
    pool = var.pm_pool
    sockets = 1
    cores = 2
    memory = 4096
    agent = 1
    clone = "WinServer2016x64-cloudinit"

    network {
      bridge    = "vmbr1"
      model     = "e1000"
      tag       = 1
    }
    network {
     bridge    = "vmbr1"
     model     = "e1000"
     tag       = 1 
    }
    ipconfig0 = "ip=192.168.56.23/24"
    ipconfig1 = "gw=192.168.56.2,ip=dhcp"
}
