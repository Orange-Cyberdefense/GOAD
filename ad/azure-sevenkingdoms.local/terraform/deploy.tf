terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.44.1"
    }
  }
  required_version = ">= 0.10.0"
}

data "http" "local-pubip-html" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  local_pubip = chomp(data.http.local-pubip-html.response_body)
}

locals {
  ssh_source_ips  = ["69.69.69.69", local.local_pubip]
}

module "goad" {
  source                  = "./modules/azure/goad"
  project                 = "goad"
  size                    = "Standard_B2s"
  username                = "rtadmin"
  pw                      = "$uper$ecuR3p@sw0rd!"
  location                = "westeurope"
  disk_size               = "32"
  count_pip               = 1
  subid                   = "<id>"
  ssh_allow_ips           = local.ssh_source_ips
  deploy_ip               = local.local_pubip
}
output "module-goad" {
  value =  module.goad
}



