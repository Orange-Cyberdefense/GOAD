variable "vm_config" {
  type = map(object({
    name               = string
    os_image           = string
    private_ip_address = string
    password           = string
  }))

  /*
    Default Windows images:
    Windows Server 2019 Datacenter 64bit English
    Windows Server 2016 Datacenter 64bit English
    Windows Server 2012 R2 Datacenter 64bit English
  */
  default = {
    "dc01" = {
      name               = "dc01"
      os_image           = "Windows Server 2019 Datacenter 64bit English"
      private_ip_address = "192.168.56.10"
      password           = "dc_and_domain_password"
    }
    "srv01" = {
      name               = "srv01"
      os_image           = "Windows Server 2019 Datacenter 64bit English"
      private_ip_address = "192.168.56.11"
      password           = "srv_password"
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
