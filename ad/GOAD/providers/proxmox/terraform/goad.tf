resource "proxmox_virtual_environment_vm" "dc01" {
  name        = "GOAD-DC01"
  description = "DC01 - windows server 2019 - 192.168.10.10"
  node_name   = var.pm_node
  pool_id     = var.pm_pool

  operating_system {
    type = "win10"
  }

  cpu {
    cores   = 2
    sockets = 1
  }

  memory {
    dedicated = 3096
  }

  clone {
    vm_id = var.vm_id_winsrv2019
    full  = var.pm_full_clone
  }
  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = true
  }

  network_device {
    bridge  = "vmbr3"
    model   = "e1000"
    vlan_id = 10
  }

  initialization {
    datastore_id = var.storage
    dns {
      servers = [
        "192.168.10.1",
        "1.1.1.1",
      ]
    }
    ip_config {
      ipv4 {
        address = "192.168.10.10/24"
        gateway = "192.168.10.1"
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "dc02" {
  name        = "GOAD-DC02"
  description = "DC02 - windows server 2019 - 192.168.10.11"
  node_name   = var.pm_node
  pool_id     = var.pm_pool

  operating_system {
    type = "win10"
  }

  cpu {
    cores   = 2
    sockets = 1
  }

  memory {
    dedicated = 3096
  }

  clone {
    vm_id = var.vm_id_winsrv2019
    full  = var.pm_full_clone
  }

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = true
  }

  network_device {
    bridge  = "vmbr3"
    model   = "e1000"
    vlan_id = 10
  }

  initialization {
    datastore_id = var.storage
    dns {
      servers = [
        "192.168.10.1",
        "1.1.1.1",
      ]
    }
    ip_config {
      ipv4 {
        address = "192.168.10.11/24"
        gateway = "192.168.10.1"
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "dc03" {
  name        = "GOAD-DC03"
  description = "DC03 - windows server 2016 - 192.168.10.12"
  node_name   = var.pm_node
  pool_id     = var.pm_pool

  operating_system {
    type = "win10"
  }

  cpu {
    cores   = 2
    sockets = 1
  }

  memory {
    dedicated = 3096
  }

  clone {
    vm_id = var.vm_id_winsrv2016
    full  = var.pm_full_clone
  }

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = true
  }

  network_device {
    bridge  = "vmbr3"
    model   = "e1000"
    vlan_id = 10
  }

  initialization {
    datastore_id = var.storage
    dns {
      servers = [
        "192.168.10.1",
        "1.1.1.1",
      ]
    }
    ip_config {
      ipv4 {
        address = "192.168.10.12/24"
        gateway = "192.168.10.1"
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "srv02" {
  name        = "GOAD-SRV02"
  description = "SRV02 - windows server 2019 - 192.168.10.22"
  node_name   = var.pm_node
  pool_id     = var.pm_pool

  operating_system {
    type = "win10"
  }

  cpu {
    cores   = 2
    sockets = 1
  }

  memory {
    dedicated = 4096
  }

  clone {
    vm_id = var.vm_id_winsrv2019
    full  = var.pm_full_clone
  }

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = true
  }

  network_device {
    bridge  = "vmbr3"
    model   = "e1000"
    vlan_id = 10
  }

  initialization {
    datastore_id = var.storage
    dns {
      servers = [
        "192.168.10.1",
        "1.1.1.1",
      ]
    }
    ip_config {
      ipv4 {
        address = "192.168.10.22/24"
        gateway = "192.168.10.1"
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "srv03" {
  name        = "GOAD-SRV03"
  description = "SRV03 - windows server 2016 - 192.168.10.23"
  node_name   = var.pm_node
  pool_id     = var.pm_pool

  operating_system {
    type = "win10"
  }

  cpu {
    cores   = 2
    sockets = 1
  }

  memory {
    dedicated = 4096
  }

  clone {
    vm_id = var.vm_id_winsrv2016
    full  = var.pm_full_clone
  }

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = true
  }

  network_device {
    bridge  = "vmbr3"
    model   = "e1000"
    vlan_id = 10
  }

  initialization {
    datastore_id = var.storage
    dns {
      servers = [
        "192.168.10.1",
        "1.1.1.1",
      ]
    }
    ip_config {
      ipv4 {
        address = "192.168.10.23/24"
        gateway = "192.168.10.1"
      }
    }
  }
}
