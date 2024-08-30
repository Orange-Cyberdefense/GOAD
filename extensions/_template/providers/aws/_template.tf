## VARIABLES

variable "_template_username" {
  description = "Username for _template SSH user"
  type    = string
  default = "goad"
}

variable "_template_disk_size" {
  description = "_template root disk size, defaults to 30 Go"
  type    = number
  default = 30
}

## RECIPE
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_network_interface" "goad-vm-nic-_template" {
  subnet_id   = aws_subnet.goad_public_network.id
  private_ips = ["192.168.56.51"]
  security_groups = [aws_security_group.goad_security_group.id]
  tags = {
    Lab = "GOAD"
  }
}

resource "aws_instance" "goad-vm-_template" {
  ami                    = "ami-00c71bd4d220aa22a"
  instance_type          = "t2.medium"

  network_interface {
    network_interface_id = aws_network_interface.goad-vm-nic-_template.id
    device_index = 0
  }

  user_data = templatefile("${path.module}/user_data/instance-init.sh.tpl", {
                                username = var._template_username
                           })

  key_name = "GOAD-_template-keypair"
  tags = {
    Name = "GOAD-_template"
    Lab = "GOAD"
  }

  root_block_device {
    volume_size = var._template_disk_size
    tags = {
      Name = "_template-root"
      Lab = "GOAD"
    }
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh.private_key_openssh}' > ../ssh_keys/ubuntu-_template.pem && echo '${tls_private_key.ssh.public_key_openssh}' > ../ssh_keys/ubuntu-_template.pub && chmod 600 ../ssh_keys/*"
  }
}
