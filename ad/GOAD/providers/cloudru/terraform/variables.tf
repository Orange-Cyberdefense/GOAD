variable "region" {
  type    = string
  default = "ru-moscow-1"
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

# IAM user ak on cloud.ru (https://cloud.ru/docs/obs/ug/topics/guides__create-access-keys.html)
variable "access_key" {
  type    = string
  default = "qweqwe"
}

# IAM user sk on cloud.ru (https://cloud.ru/docs/obs/ug/topics/guides__create-access-keys.html)
variable "secret_key" {
  type    = string
  default = "qweqwe"
}
