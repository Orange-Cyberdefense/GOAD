variable "linux_vm_config" {
  type = map(object({
    name               = string
    linux_sku          = string
    linux_version      = string
    ami                = string
    instance_type      = string
    private_ip_address = string
    password           = string
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
  subnet_id   = {% if use_existing_vpc %}var.existing_subnet_id{% else %}aws_subnet.goad_private_network.id{% endif %}
  private_ips = [each.value.private_ip_address]
  security_groups = [{% if use_existing_vpc %}var.existing_security_group_id{% else %}aws_security_group.goad_security_group.id{% endif %}]
  tags = {
    Lab = "{{lab_identifier}}"
  }
}

data "aws_ami" "ubuntu_22_04_linux" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "linux-goad-vm" {
  for_each = var.linux_vm_config

  ami                    = data.aws_ami.ubuntu_22_04_linux.id
  instance_type          = each.value.instance_type

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

