resource "tls_private_key" "windows" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

variable "vm_config" {
  type = map(object({
    name               = string
    domain             = string
    windows_sku        = string
    ami                = string
    instance_type      = string
    private_ip_address = string
    password           = string
  }))

  default = {
    "dc01" = {
      name               = "dc01"
      domain             = "sevenkingdoms.local"
      windows_sku        = "2019-Datacenter"
      ami                = "ami-018ebfbd6b0a4c605"
      instance_type      = "t2.medium"
      private_ip_address = "192.168.56.10"
      password           = "8dCT-DJjgScp"
    }
    "dc02" = {
      name               = "dc02"
      domain             = "north.sevenkingdoms.local"
      windows_sku        = "2019-Datacenter"
      ami                = "ami-018ebfbd6b0a4c605"
      instance_type      = "t2.medium"
      private_ip_address = "192.168.56.11"
      password           = "NgtI75cKV+Pu"
    }
    "dc03" = {
      name               = "dc03"
      domain             = "essos.local"
      windows_sku        = "2016-Datacenter"
      ami                = "ami-03a5b89a2fbe7dd3d"
      instance_type      = "t2.medium"
      private_ip_address = "192.168.56.12"
      password           = "Ufe-bVXSx9rk"
    }
    "srv02" = {
      name               = "srv02"
      domain             = "north.sevenkingdoms.local"
      windows_sku        = "2019-Datacenter"
      ami                = "ami-018ebfbd6b0a4c605"
      instance_type      = "t2.medium"
      private_ip_address = "192.168.56.22"
      password           = "NgtI75cKV+Pu"
    }
    "srv03" = {
      name               = "srv03"
      domain             = "essos.local"
      windows_sku        = "2016-Datacenter"
      ami                = "ami-03a5b89a2fbe7dd3d"
      instance_type      = "t2.medium"
      private_ip_address = "192.168.56.23"
      password           = "978i2pF43UJ-"
    }
  }
}


resource "aws_network_interface" "goad-vm-nic" {
  for_each = var.vm_config
  subnet_id   = aws_subnet.goad_private_network.id
  private_ips = [each.value.private_ip_address]
  security_groups = [aws_security_group.goad_security_group.id]
  tags = {
    Lab = "GOAD"
  }
}

resource "aws_instance" "goad-vm" {
  for_each = var.vm_config

  ami                    = each.value.ami
  instance_type          = each.value.instance_type

  network_interface {
    network_interface_id = aws_network_interface.goad-vm-nic[each.key].id
    device_index = 0
  }

  user_data = templatefile("${path.module}/user_data/instance-init.ps1.tpl", {
                                username = var.username
                                password = each.value.password
                                domain = each.value.domain
                           })
  key_name = "GOAD-windows-keypair"
  tags = {
    Name = "GOAD-${each.value.name}"
    Lab = "GOAD"
  }
  provisioner "local-exec" {
    command = "echo '${tls_private_key.windows.private_key_pem}' > ../ssh_keys/id_rsa_windows && echo '${tls_private_key.windows.public_key_pem}' > ../ssh_keys/id_rsa_windows.pub && chmod 600 ../ssh_keys/id_rsa*"
  }
}

