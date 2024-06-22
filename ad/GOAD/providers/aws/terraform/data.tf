locals {
  ami = {
    "windows-2019" : "Windows_Server-2019-English-Full-Base*",
    "windows-2016" : "Windows_Server-2016-English-Full-Base*",
    "ubuntu" : "*ubuntu-noble-24.04-amd64-server*"
  }
  tags = {
    Name = "GOAD"
    Lab  = "GOAD"
  }
}

data "aws_region" "current" {}

data "aws_ami" "instances" {
  for_each    = local.ami
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [each.value]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
