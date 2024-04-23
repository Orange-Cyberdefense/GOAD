resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_network_interface" "goad-vm-nic-jumpbox" {
  subnet_id   = aws_subnet.goad_public_network.id
  private_ips = ["192.168.56.100"]
  security_groups = [aws_security_group.goad_security_group.id]
  tags = {
    Lab = "GOAD"
  }
}

resource "aws_instance" "goad-vm-jumpbox" {
  ami                    = "ami-00c71bd4d220aa22a"
  instance_type          = "t2.medium"

  network_interface {
    network_interface_id = aws_network_interface.goad-vm-nic-jumpbox.id
    device_index = 0
  }

  user_data = templatefile("${path.module}/user_data/instance-init.sh.tpl", {
                                username = var.jumpbox_username
                           })

  key_name = "GOAD-jumpbox-keypair"
  tags = {
    Name = "GOAD-jumpbox"
    Lab = "GOAD"
  }

  root_block_device {
    volume_size = var.jumpbox_disk_size
    tags = {
      Name = "JumpBox-root"
      Lab = "GOAD"
    }
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh.private_key_openssh}' > ../ssh_keys/ubuntu-jumpbox.pem && echo '${tls_private_key.ssh.public_key_openssh}' > ../ssh_keys/ubuntu-jumpbox.pub && chmod 600 ../ssh_keys/*"
  }
}

