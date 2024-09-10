variable "location" {
  type    = string
  default = "westeurope"
}

# default size : 2cpu / 4GB
variable "size" {
  type    = string
  default = "Standard_B2s"
}

variable "username" {
  type    = string
  default = "goadmin"
}

variable "password" {
  description = "Password of the windows virtual machine admin user"
  type    = string
  default = "goadmin"
}

variable "jumpbox_username" {
  type    = string
  default = "goad"
}
