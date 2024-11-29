variable "linux_vm_config" {
  type = map(object({
    name               = string
    linux_sku          = string
    linux_version      = string
    ami                = string
    instance_type      = string
    private_ip_address = string
    password           = string
    size               = string
  }))

  default = {
    {{linux_vms}}
  }
}

resource "tls_private_key" "linux_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_network_interface" "linux-goad-vm-nic" {
  for_each = var.linux_vm_config
  subnet_id   = aws_subnet.goad_private_network.id
  private_ips = [each.value.private_ip_address]
  security_groups = [aws_security_group.goad_security_group.id]
  tags = {
    Lab = "{{lab_identifier}}"
  }
}

resource "aws_instance" "linux-goad-vm" {
  for_each = var.linux_vm_config

  ami                    = "${each.value.ami}"
  instance_type          = "${each.value.size}"

  network_interface {
    network_interface_id = aws_network_interface.linux-goad-vm-nic[each.key].id
    device_index = 0
  }

  user_data = templatefile("${path.module}/instance-init.sh.tpl", {
                                username = var.username
                                password = each.value.password
                           })

  key_name = "{{lab_identifier}}-linux-keypair"

  tags = {
    Name = "{{lab_name}}-${each.value.name}"
    Lab = "{{lab_identifier}}"
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.linux_ssh.private_key_openssh}' > ../ssh_keys/${each.value.name}_ssh.pem && echo '${tls_private_key.linux_ssh.public_key_openssh}' > ../ssh_keys/${each.value.name}_ssh.pub && chmod 600 ../ssh_keys/*"
  }
}

