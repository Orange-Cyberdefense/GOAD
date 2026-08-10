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
  name               = "${var.name_prefix}-jumpbox-ubuntu"
  region             = var.region
  image_name         = "Ubuntu 24.04 server 64bit"
  flavor_id          = var.jumpbox_size
  security_group_ids = [sbercloud_networking_secgroup.secgroup_allow_any.id]

  system_disk_type = "SAS"
  system_disk_size = var.jumpbox_disk_size

  user_data = templatefile("${path.module}/instance-init-linux.yml.tpl", {
    username = var.jumpbox_username
    password = ""
    key      = tls_private_key.ssh.public_key_openssh
  })

  network {
    uuid        = sbercloud_vpc_subnet.goad_subnet.id
    fixed_ip_v4 = "{{ip_range}}.100"
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh.private_key_pem}' > ../ssh_keys/ubuntu-jumpbox.pem && chmod 600 ../ssh_keys/ubuntu-jumpbox.pem"
  }
}
