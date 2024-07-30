variable "vm_config" {
  type = map(object({
    name               = string
    os_image           = string
    private_ip_address = string
    password           = string
  }))

  default = {
    "dc01" = {
      name               = "dc01"
      os_image           = "Windows Server 2019 Datacenter 64bit English"
      private_ip_address = "192.168.56.10"
      password           = "8dCT-6546541qsdDJjgScp"
    }
    "dc02" = {
      name               = "dc02"
      os_image           = "Windows Server 2019 Datacenter 64bit English"
      private_ip_address = "192.168.56.20"
      password           = "Ufe-qsdaz789bVXSx9rk"
    }
    "srv01" = {
      name               = "srv01"
      os_image           = "Windows Server 2019 Datacenter 64bit English"
      private_ip_address = "192.168.56.21"
      password           = "EaqsdP+xh7sdfzaRk6j90"
    }
    "srv02" = {
      name               = "srv02"
      os_image           = "Windows Server 2019 Datacenter 64bit English"
      private_ip_address = "192.168.56.22"
      password           = "978i2pF43UqsdqsdJ-qsd"
    }
    "srv03" = {
      name               = "srv03"
      os_image           = "Windows Server 2019 Datacenter 64bit English"
      private_ip_address = "192.168.56.23"
      password           = "EalwkdP+xh7sdfaRk6j90"
    }
  }
}

module "cloudru_deploy" {
  source = "./../../../../../terraform/cloudru"

  region             = var.region
  vpc_name           = var.vpc_name
  vm_size            = var.vm_size
  eip_bandwidth_size = var.eip_bandwidth_size
  nat_gateway_spec   = var.nat_gateway_spec
  vm_config          = var.vm_config
}
