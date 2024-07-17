variable "vpc_cidr" {
  description = "CIDR for lab"
  type        = string
  default     = "192.168.0.0/16"
}

variable "goad_cidr" {
  description = "CIDR for GOAD"
  type        = string
  default     = "192.168.56.0/24"
}

variable "jumpbox_cidr" {
  description = "CIDR of the public subnet exposing the jumpbox"
  type        = string
  default     = "192.168.60.0/24"
}

variable "ec2_config" {
  type = map(object({
    domain             = string
    os                 = string
    private_ip_address = string
    password           = string
  }))

  default = {
    "dc01" = {
      domain             = "sevenkingdoms.local"
      os                 = "windows-2019"
      private_ip_address = "192.168.56.10"
      password           = "8dCT-DJjgScp"
    }
    "dc02" = {
      domain             = "north.sevenkingdoms.local"
      os                 = "windows-2019"
      private_ip_address = "192.168.56.11"
      password           = "NgtI75cKV+Pu"
    }
    "dc03" = {
      domain             = "essos.local"
      os                 = "windows-2016"
      private_ip_address = "192.168.56.12"
      password           = "Ufe-bVXSx9rk"
    }
    "srv02" = {
      domain             = "north.sevenkingdoms.local"
      os                 = "windows-2019"
      private_ip_address = "192.168.56.22"
      password           = "NgtI75cKV+Pu"
    }
    "srv03" = {
      domain             = "essos.local"
      os                 = "windows-2016"
      private_ip_address = "192.168.56.23"
      password           = "978i2pF43UJ-"
    }
  }
}


variable "whitelist_cidr" {
  description = "Whitelisted IP that can access the Ubuntu jumpbox"
  type        = string
  default     = "127.0.0.1/32"
}

variable "jumpbox_disk_size" {
  description = "Jumpbox root disk size, defaults to 30 Go"
  type        = number
  default     = 30
}

variable "username" {
  description = "Username for local administrator of Windows VMs"
  type        = string
  default     = "goadmin"

}

variable "jumpbox_username" {
  description = "Username for jumpbox SSH user"
  type        = string
  default     = "goad"
}
