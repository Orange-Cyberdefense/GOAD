resource "sbercloud_vpc" "goad_vpc" {
  name   = "${var.name_prefix}-virtual-network"
  cidr   = "{{ip_range}}.0/24"
  region = var.region
}

resource "sbercloud_vpc_subnet" "goad_subnet" {
  name       = "${var.name_prefix}-vm-subnet"
  cidr       = "{{ip_range}}.0/24"
  gateway_ip = "{{ip_range}}.1"
  vpc_id     = sbercloud_vpc.goad_vpc.id
}

resource "sbercloud_vpc_eip" "goad_nat_public_ip" {
  region = var.region

  publicip {
    type = "5_bgp"
  }

  bandwidth {
    name        = "${var.name_prefix}-nat-public-ip"
    share_type  = "PER"
    size        = var.eip_bandwidth_size
    charge_mode = "traffic"
  }
}

resource "sbercloud_nat_gateway" "goad_nat" {
  name      = "${var.name_prefix}-nat"
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
  name                 = "${var.name_prefix}-allow-any"
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
