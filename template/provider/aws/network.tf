# VPC
resource "aws_vpc" "goad_vpc" {
  cidr_block = var.goad_cidr 
  tags = { 
    Name = "{{lab_name}}-VPC"
    Lab = "{{lab_identifier}}"
  } 
} 


# Subnets
resource "aws_subnet" "goad_private_network" {
  vpc_id     = aws_vpc.goad_vpc.id
  cidr_block = var.goad_private_cidr
  availability_zone = var.zone
  
  tags = {
    Name = "{{lab_name}}-private-network"
    Lab = "{{lab_identifier}}"
  }
}

resource "aws_subnet" "goad_public_network" {
  vpc_id     = aws_vpc.goad_vpc.id
  cidr_block = var.goad_public_cidr
  availability_zone = var.zone
  depends_on = [aws_internet_gateway.internet_gateway]

  tags = {
    Name = "{{lab_name}}-public-network"
    Lab = "{{lab_identifier}}"
  }
}

# Routing
resource "aws_default_route_table" "goad_default_table" {
  default_route_table_id = aws_vpc.goad_vpc.default_route_table_id
  tags = {
    Name = "{{lab_name}} Default Route table"
    Lab = "{{lab_identifier}}"
  }
}

resource "aws_route_table" "goad_public_table" {
  vpc_id = aws_vpc.goad_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "{{lab_name}} Route table"
    Lab = "{{lab_identifier}}"
  }
}

resource "aws_route_table" "goad_private_table" {
  vpc_id = aws_vpc.goad_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "{{lab_name}} Private Route table"
    Lab = "{{lab_identifier}}"
  }
}

resource "aws_route_table_association" "goad_private_table_association" {
  subnet_id      = aws_subnet.goad_private_network.id
  route_table_id = aws_route_table.goad_private_table.id
}

resource "aws_route_table_association" "goad_public_table_association" {
  subnet_id      = aws_subnet.goad_public_network.id
  route_table_id = aws_route_table.goad_public_table.id
}

# Security group
resource "aws_default_security_group" "goad_default_security_group" {
  vpc_id      = aws_vpc.goad_vpc.id

  tags = {
    Name = "{{lab_name}} Default Security Group"
    Lab = "{{lab_identifier}}"
  }
}

resource "aws_security_group" "goad_security_group" {
  name        = "{{lab_name}} Security Group"
  description = "Allow traffic necessary to use GOAD"
  vpc_id      = aws_vpc.goad_vpc.id

  tags = {
    Name = "{{lab_name}} Security Group"
    Lab = "{{lab_identifier}}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_whitelist_ingress" {
  for_each = var.whitelist_cidr
  security_group_id = aws_security_group.goad_security_group.id
  cidr_ipv4         = each.key
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_goad_ingress" {
  security_group_id = aws_security_group.goad_security_group.id
  cidr_ipv4         = var.goad_cidr
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_goad_egress" {
  security_group_id = aws_security_group.goad_security_group.id
  cidr_ipv4         = var.goad_cidr
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_tcp_internet_http_egress" {
  security_group_id = aws_security_group.goad_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = "80"
  to_port           = "80"
}

resource "aws_vpc_security_group_egress_rule" "allow_tcp_internet_https_egress" {
  security_group_id = aws_security_group.goad_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = "443"
  to_port           = "443"
}

resource "aws_vpc_security_group_egress_rule" "allow_udp_internet_dns_egress" {
  security_group_id = aws_security_group.goad_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "udp"
  from_port         = "53"
  to_port           = "53"
}

resource "aws_vpc_security_group_egress_rule" "allow_icmp_egress" {
  security_group_id = aws_security_group.goad_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "icmp"
  from_port           = "-1"
  to_port           = "-1"
}

# Public IPs
resource "aws_eip" "public_ip" {
  domain = "vpc"

  instance                  = aws_instance.goad-vm-jumpbox.id
  associate_with_private_ip = "{{ip_range}}.100"

  tags = {
    Name = "{{lab_name}} Jumpbox public IP"
    Lab = "{{lab_identifier}}"
  }
}

resource "aws_eip" "nat_ip" {
  domain = "vpc"
}

# Gateways
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.goad_vpc.id

  tags = {
    Name = "{{lab_name}} Internet Gateway"
    Lab = "{{lab_identifier}}"
  }
}


resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.goad_public_network.id

  tags = {
    Name = "{{lab_name}} NAT Gateway"
    Lab = "{{lab_identifier}}"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

