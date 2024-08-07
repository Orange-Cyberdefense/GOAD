variable "region" {
  type    = string
  default = "ru-moscow-1"
}

# must be in format GOAD_LABNAME, where LABNAME is a folder name in ad/
variable "vpc_name" {
  type    = string
  default = "GOAD_TEMPLATE"
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
