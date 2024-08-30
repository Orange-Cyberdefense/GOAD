## VARIABLES

variable "elk_username" {
  description = "Username for elk SSH user"
  type    = string
  default = "goad"
}

variable "elk_disk_size" {
  description = "elk root disk size, defaults to 30 Go"
  type    = number
  default = 30
}

## RECIPE
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_network_interface" "goad-vm-nic-elk" {
  subnet_id   = aws_subnet.goad_public_network.id
  private_ips = ["192.168.56.51"]
  security_groups = [aws_security_group.goad_security_group.id]
  tags = {
    Lab = "GOAD"
  }
}

resource "aws_instance" "goad-vm-elk" {
  ami                    = "ami-00c71bd4d220aa22a"
  instance_type          = "t2.medium"

  network_interface {
    network_interface_id = aws_network_interface.goad-vm-nic-elk.id
    device_index = 0
  }

  user_data = templatefile("${path.module}/user_data/instance-init.sh.tpl", {
                                username = var.elk_username
                           })

  key_name = "GOAD-elk-keypair"
  tags = {
    Name = "GOAD-elk"
    Lab = "GOAD"
  }

  root_block_device {
    volume_size = var.elk_disk_size
    tags = {
      Name = "elk-root"
      Lab = "GOAD"
    }
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh.private_key_openssh}' > ../ssh_keys/ubuntu-elk.pem && echo '${tls_private_key.ssh.public_key_openssh}' > ../ssh_keys/ubuntu-elk.pub && chmod 600 ../ssh_keys/*"
  }
}
