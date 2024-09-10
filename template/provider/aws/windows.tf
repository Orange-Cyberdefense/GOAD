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
    {{windows_vms}}
  }
}


resource "aws_network_interface" "goad-vm-nic" {
  for_each = var.vm_config
  subnet_id   = aws_subnet.goad_private_network.id
  private_ips = [each.value.private_ip_address]
  security_groups = [aws_security_group.goad_security_group.id]
  tags = {
    Lab = "{{lab_identifier}}"
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

  user_data = templatefile("${path.module}/instance-init.ps1.tpl", {
                                username = var.username
                                password = each.value.password
                                domain = each.value.domain
                           })

  key_name = "{{lab_identifier}}-windows-keypair"

  tags = {
    Name = "{{lab_name}}-${each.value.name}"
    Lab = "{{lab_identifier}}"
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.windows.private_key_pem}' > ../ssh_keys/id_rsa_windows && echo '${tls_private_key.windows.public_key_pem}' > ../ssh_keys/id_rsa_windows.pub && chmod 600 ../ssh_keys/id_rsa*"
  }
}

