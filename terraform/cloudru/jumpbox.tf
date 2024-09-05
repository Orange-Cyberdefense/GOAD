resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "sbercloud_nat_dnat_rule" "goad_dnat_jumpbox" {
  floating_ip_id              = sbercloud_vpc_eip.goad_nat_public_ip.id
  nat_gateway_id              = sbercloud_nat_gateway.goad_nat.id
  port_id                     = sbercloud_compute_instance.jumpbox.network[0].port
  protocol                    = "tcp"
  internal_service_port_range = "1-65535"
  external_service_port_range = "1-65535"
}

resource "sbercloud_compute_instance" "jumpbox" {
  name               = "${var.vpc_name}-jumpbox-ubuntu"
  region             = var.region
  image_name         = "Ubuntu 22.04 server 64bit"
  flavor_id          = var.vm_size
  user_data          = "#!/bin/sh\necho '${tls_private_key.ssh.public_key_openssh}' > /root/.ssh/authorized_keys"
  security_group_ids = [sbercloud_networking_secgroup.secgroup_allow_any.id]

  system_disk_type = "SAS"
  system_disk_size = 60 # to install tools like exegol

  network {
    uuid        = sbercloud_vpc_subnet.goad_subnet.id
    fixed_ip_v4 = "192.168.56.100"
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh.private_key_pem}' > ../ssh_keys/ubuntu-jumpbox.pem && chmod 600 ../ssh_keys/ubuntu-jumpbox.pem"
  }
}
