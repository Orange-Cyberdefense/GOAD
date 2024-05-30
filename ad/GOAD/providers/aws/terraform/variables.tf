# Region
variable "region" {
  description = "Where you want to deploy GOAD"
  type      = string
  default   = "eu-west-3"
}

# Zone
variable "zone" {
  description = "Where you want to deploy GOAD"
  type      = string
  default   = "eu-west-1c"
}

# CIDRs
variable "goad_cidr" {
  description = "Default CIDR for GOAD"
  type    = string
  default = "192.168.56.0/24"
}

variable "goad_public_cidr" {
  description = "Private CIDR for GOAD"
  type    = string
  default = "192.168.56.64/26"
}

variable "goad_private_cidr" {
  description = "Private CIDR for GOAD"
  type    = string
  default = "192.168.56.0/26"
}

# Define a CIDR for access to the jumphost!
variable "whitelist_cidr" {
  description = "Whitelisted table IP that can access the Ubuntu jumpbox"
  type    = set(string)
  default = ["127.0.0.1/32"]
}

# Credentials
variable "username" {
  description = "Username for local administrator of Windows VMs - Password is defined in the deploy.tf file for each VM"
  type    = string
  default = "goadmin"
}

variable "jumpbox_username" {
  description = "Username for jumpbox SSH user"
  type    = string
  default = "goad"
}

variable "jumpbox_disk_size" {
  description = "Jumpbox root disk size, defaults to 30 Go"
  type    = number
  default = 30
}

# Keys are automagically generated and written in the ssh_keys folder. You can provide your own if you like.
resource "aws_key_pair" "goad-windows-keypair" {
  key_name   = "GOAD-windows-keypair"
  public_key = tls_private_key.windows.public_key_openssh
}

resource "aws_key_pair" "goad-jumpbox-keypair" {
  key_name   = "GOAD-jumpbox-keypair"
  public_key = tls_private_key.ssh.public_key_openssh
}
