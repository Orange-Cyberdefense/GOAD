variable "config_ws01_ext" {
  type = map(object({
    name               = string
    desc               = string
    cores              = number
    memory             = number
    clone              = string
    dns                = string
    ip                 = string
    gateway            = string
  }))

  default = {
    "ws01" = {
       name               = "GOAD-WS01"
       desc               = "WS01 - windows 10 - 192.168.10.31"
       cores              = 2
       memory             = 4096
       clone              = "Windows10_22h2_x64"
       dns                = "192.168.10.1"
       ip                 = "192.168.10.31/24"
       gateway            = "192.168.10.1"
    }
  }
}

locals {
  vm_config = merge(config_ws01_ext, var.vm_config)
}
