variable "region" {
  type    = string
  default = "ru-moscow-1"
}

variable "vpc_name" {
  type    = string
  default = "GOAD_LIGHT"
}

variable "vm_size" {
  type    = string
  default = "s7n.large.2"
}

variable "eip_bandwidth_size" {
  type    = number
  default = 10
}

variable "nat_gateway_spec" {
  type    = number
  default = 1
}
