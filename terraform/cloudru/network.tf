resource "sbercloud_vpc" "goad_vpc" {
  name   = var.vpc_name
  cidr   = "192.168.0.0/16"
  region = var.region
}

resource "sbercloud_vpc_subnet" "goad_subnet" {
  name       = "goad-vm-subnet"
  cidr       = "192.168.56.0/24"
  gateway_ip = "192.168.56.1"
  vpc_id     = sbercloud_vpc.goad_vpc.id
}

resource "sbercloud_vpc_eip" "goad_nat_public_ip" {
  region = var.region

  publicip {
    type = "5_bgp"
  }

  bandwidth {
    name        = "goad-nat-public-ip"
    share_type  = "PER"
    size        = var.eip_bandwidth_size
    charge_mode = "traffic"
  }
}

resource "sbercloud_nat_gateway" "goad_nat" {
  name      = "goad-nat"
  spec      = var.nat_gateway_spec
  vpc_id    = sbercloud_vpc.goad_vpc.id
  subnet_id = sbercloud_vpc_subnet.goad_subnet.id
}

resource "sbercloud_nat_snat_rule" "goad_snat" {
  nat_gateway_id = sbercloud_nat_gateway.goad_nat.id
  subnet_id      = sbercloud_vpc_subnet.goad_subnet.id
  floating_ip_id = sbercloud_vpc_eip.goad_nat_public_ip.id
}

resource "sbercloud_networking_secgroup" "secgroup_allow_any" {
  name                 = "goad-allow-any"
  delete_default_rules = true
}

resource "sbercloud_networking_secgroup_rule" "secgroup_allow_any_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  action            = "allow"
  security_group_id = sbercloud_networking_secgroup.secgroup_allow_any.id
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "sbercloud_networking_secgroup_rule" "secgroup_allow_any_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  action            = "allow"
  security_group_id = sbercloud_networking_secgroup.secgroup_allow_any.id
  remote_ip_prefix  = "0.0.0.0/0"
}
