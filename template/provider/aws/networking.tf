# VPC

resource "aws_vpc" "goad_vpc" { 
  cidr_block = var.goad_cidr 
  tags = { 
    Name = "GOAD" 
    Lab = "GOAD" 
  } 
} 


# Subnets
resource "aws_subnet" "goad_private_network" {
  vpc_id     = aws_vpc.goad_vpc.id
  cidr_block = var.goad_private_cidr
  availability_zone = var.zone
  
  tags = {
    Name = "GOAD-private-network"
    Lab = "GOAD"
  }
}

resource "aws_subnet" "goad_public_network" {
  vpc_id     = aws_vpc.goad_vpc.id
  cidr_block = var.goad_public_cidr
  availability_zone = var.zone
  depends_on = [aws_internet_gateway.internet_gateway]

  tags = {
    Name = "GOAD-public-network"
    Lab = "GOAD"
  }
}

# Routing
resource "aws_default_route_table" "goad_default_table" {
  default_route_table_id = aws_vpc.goad_vpc.default_route_table_id
  tags = {
    Name = "GOAD Default Route table"
    Lab = "GOAD"
  }
}

resource "aws_route_table" "goad_public_table" {
  vpc_id = aws_vpc.goad_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "GOAD Route table"
    Lab = "GOAD"
  }
}

resource "aws_route_table" "goad_private_table" {
  vpc_id = aws_vpc.goad_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "GOAD Private Route table"
    Lab = "GOAD"
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
    Name = "GOAD Default Security Group"
    Lab = "GOAD"
  }
}

resource "aws_security_group" "goad_security_group" {
  name        = "GOAD Security Group"
  description = "Allow traffic necessary to use GOAD"
  vpc_id      = aws_vpc.goad_vpc.id

  tags = {
    Name = "GOAD Security Group"
    Lab = "GOAD"
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
  associate_with_private_ip = "192.168.56.100"

  tags = {
    Name = "GOAD Jumpbox public IP"
    Lab = "GOAD"
  }
}

resource "aws_eip" "nat_ip" {
  domain = "vpc"
}

# Gateways
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.goad_vpc.id

  tags = {
    Name = "GOAD Internet Gateway"
    Lab = "GOAD"
  }
}


resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.goad_public_network.id

  tags = {
    Name = "GOAD NAT Gateway"
    Lab = "GOAD"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

