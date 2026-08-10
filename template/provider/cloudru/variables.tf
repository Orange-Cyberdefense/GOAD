variable "region" {
  description = "Where you want to deploy GOAD"
  type        = string
  default     = "{{config.get_value('cloudru', 'cloudru_region', 'ru-moscow-1')}}"
}

variable "eip_bandwidth_size" {
  description = "EIP bandwidth from 1 to 300 MBit/s"
  type        = number
  default     = 150
}

variable "nat_gateway_spec" {
  description = "NAT spec https://registry.terraform.io/providers/sbercloud-terraform/sbercloud/latest/docs/resources/nat_gateway#spec-1"
  type        = number
  default     = 1
}

variable "name_prefix" {
  description = "Name prefix for deployed instances"
  type        = string
  default     = "GOAD-{{lab_name}}"
}

# Credentials
variable "username" {
  description = "Username for local administrator of Windows VMs - Password is defined in the deploy.tf file for each VM"
  type        = string
  default     = "administrator"
}

variable "linux_username" {
  description = "Username for local administrator of Linux VMs"
  type        = string
  default     = "ansible"
}

variable "jumpbox_username" {
  description = "Username for jumpbox SSH user"
  type        = string
  default     = "goad"
}

# Jump Box
variable "jumpbox_size" {
  description = "Jumpox specs"
  type        = string
  default     = "s7n.large.2"
}

variable "jumpbox_disk_size" {
  description = "Jumpbox root disk size, defaults to 60 Go"
  type        = number
  default     = 60
}
