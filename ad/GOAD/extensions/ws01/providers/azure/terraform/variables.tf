variable "resource_group_location" {
  type    = string
  default = ""
}

variable "resource_group_name" {
  type    = string
  default = ""
}

variable "subnet_id" {
  type = string
  description = "subnet id"
}

variable "name" {
  type = string
  default = "ws01"
}

variable "windows_sku" {
  type = string
  default = "Windows-10-N-x64"
}

variable "windows_version" {
  type = string
  default = "latest"
}

variable "private_ip_address" {
  type = string
  default = "192.168.56.30"
}

variable "username" {
  type = string
  default = "goadmin"
}

variable "password" {
  type = string
  default = "EP+xh7Rk6j90"
}

variable "size" {
  type = string
  default = "Standard_B2s"
}