resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "proxmox_virtual_environment_vm" "goadv3-jumpbox" {
  name      = "goadv3-jumpbox"
  description = "GOADv3 jumpbox Ubuntu"
  node_name   = "${var.pm_node}"
  pool_id     = "${var.pm_pool}"

  operating_system {
    type = "l26" # Linux system for Ubuntu
  }

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 2048
  }

  agent {
    enabled = true
  }

  clone {
    vm_id = var.vm_template_id["ubuntu_jumpbox"]
    full  = var.pm_full_clone
    retries = 2
  }

  lifecycle {
    ignore_changes = [
      vga,
    ]
  }

  disk {
    datastore_id = "${var.storage}"
    interface    = "scsi0"
    size         = 20
  }

  network_device {
    bridge = "${var.network_bridge_jump}"
    model  = "virtio"
  }

  network_device {
    bridge = "${var.network_bridge}"
    model  = "virtio"
  }

  initialization {
    datastore_id = "${var.storage}"

    dns {
      servers = "${var.dns_servers}"
    }

    ip_config {
      ipv4 {
        address = "${var.jumpbox_public_ip}${var.jumpbox_public_ip_netmask}"
        gateway = "${var.jumpbox_gateway}"
      }
    }

    ip_config {
      ipv4 {
        address = "{{ip_range}}.200/24"
      }
    }

    user_account {
      username = "${var.jumpbox_username}"
      keys = [tls_private_key.ssh.public_key_openssh]
    }
  }
  
  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh.private_key_pem}' > ../ssh_keys/ubuntu-jumpbox.pem && chmod 600 ../ssh_keys/ubuntu-jumpbox.pem"
  }
}