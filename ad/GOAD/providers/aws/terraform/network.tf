locals {
  zone = "${data.aws_region.current.name}a"
  network = [
    {
      name                        = "public"
      cidr                        = var.jumpbox_cidr
      associate_public_ip_address = true
    },
    {
      name                        = "private"
      cidr                        = var.goad_cidr
      associate_public_ip_address = false
    }
  ]
  network_config = { for idx, item in local.network : item.name => item }
}

resource "aws_vpc" "goad_vpc" {
  cidr_block = var.vpc_cidr
  tags       = local.tags
}

resource "aws_internet_gateway" "goad_igw" {
  vpc_id = aws_vpc.goad_vpc.id
  tags   = merge(local.tags, { Name = "GOAD-igw" })
}

resource "aws_eip" "nat_ip" {
  domain = "vpc"
  tags   = merge(local.tags, { Name = "GOAD-nat-gw" })
}

resource "aws_nat_gateway" "goad_nat_gw" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.goad_subnet["public"].id
  tags          = merge(local.tags, { Name = "GOAD-nat-gw" })

  depends_on = [aws_internet_gateway.goad_igw]
}

resource "aws_subnet" "goad_subnet" {
  for_each                = local.network_config
  vpc_id                  = aws_vpc.goad_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = local.zone
  map_public_ip_on_launch = each.value.associate_public_ip_address

  tags = merge(local.tags, { Name = "GOAD-${each.key}-subnet" })
}

resource "aws_route_table" "goad_rt" {
  for_each = local.network_config
  vpc_id   = aws_vpc.goad_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id     = each.key == "public" ? aws_internet_gateway.goad_igw.id : null
    nat_gateway_id = each.key == "public" ? null : aws_nat_gateway.goad_nat_gw.id
  }

  tags = merge(local.tags, { Name = "GOAD-${each.key}-rt" })
}

resource "aws_route_table_association" "goad_rt_association" {
  for_each       = local.network_config
  subnet_id      = aws_subnet.goad_subnet[each.key].id
  route_table_id = aws_route_table.goad_rt[each.key].id
}

resource "aws_security_group" "goad_internal" {
  name        = "GOAD internal security group"
  description = "Allow all traffic within lab and to Internet"
  vpc_id      = aws_vpc.goad_vpc.id

  tags = merge(local.tags, { Name = "GOAD-internal" })
}

resource "aws_vpc_security_group_ingress_rule" "goad_internal" {
  security_group_id            = aws_security_group.goad_internal.id
  referenced_security_group_id = aws_security_group.goad_internal.id
  ip_protocol                  = "-1"

  tags = merge(local.tags, { Name = "GOAD-internal" })
}

resource "aws_vpc_security_group_egress_rule" "goad_to_all" {
  security_group_id = aws_security_group.goad_internal.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = merge(local.tags, { Name = "Internet access" })
}

resource "aws_security_group" "goad_jumpbox" {
  name        = "GOAD jumpbox security group"
  description = "Allow traffic from whitelist CIDR to jumpbox"
  vpc_id      = aws_vpc.goad_vpc.id

  tags = merge(local.tags, { Name = "GOAD-jumpbox-access" })
}

resource "aws_vpc_security_group_ingress_rule" "internet_to_jumpbox" {
  security_group_id = aws_security_group.goad_jumpbox.id
  cidr_ipv4         = var.whitelist_cidr
  ip_protocol       = "-1"

  tags = merge(local.tags, { Name = "Jumpbox access" })
}

resource "aws_vpc_security_group_egress_rule" "jumpbox_to_internet" {
  security_group_id = aws_security_group.goad_jumpbox.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = merge(local.tags, { Name = "Internet access" })
}
