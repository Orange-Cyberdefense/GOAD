variable "region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "eip_bandwidth_size" {
  type = number
}

variable "nat_gateway_spec" {
  type = number
}

variable "vm_config" {
  type = map(object({
    name               = string
    os_image           = string
    private_ip_address = string
    password           = string
  }))
}
