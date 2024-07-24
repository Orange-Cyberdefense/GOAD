terraform {
  required_providers {
    sbercloud = {
      source  = "sbercloud-terraform/sbercloud"
      version = "1.12.0"
    }
  }
}

provider "sbercloud" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

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
      password           = "8dCT-DJjgScp"
    }
    "dc02" = {
      name               = "dc02"
      os_image           = "Windows Server 2019 Datacenter 64bit English"
      private_ip_address = "192.168.56.11"
      password           = "NgtI75cKV+Pu"
    }
    "dc03" = {
      name               = "dc03"
      os_image           = "Windows Server 2016 Datacenter 64bit English"
      private_ip_address = "192.168.56.12"
      password           = "Ufe-bVXSx9rk"
    }
    "srv02" = {
      name               = "srv02"
      os_image           = "Windows Server 2019 Datacenter 64bit English"
      private_ip_address = "192.168.56.22"
      password           = "NgtI75cKV+Pu"
    }
    "srv03" = {
      name               = "srv03"
      os_image           = "Windows Server 2016 Datacenter 64bit English"
      private_ip_address = "192.168.56.23"
      password           = "978i2pF43UJ-"
    }
  }
}

resource "sbercloud_compute_instance" "goad_vm" {
  for_each = var.vm_config

  name               = "goad-vm-${each.value.name}"
  region             = var.region
  image_name         = each.value.os_image
  flavor_id          = var.vm_size
  admin_pass         = each.value.password
  security_group_ids = [sbercloud_networking_secgroup.secgroup_allow_any.id]
  user_data = templatefile("${path.module}/../../../../../terraform/cloudru-instance-init.ps1.tpl", {
    username = "ansible"
    password = each.value.password
  })

  network {
    uuid        = sbercloud_vpc_subnet.goad_subnet.id
    fixed_ip_v4 = each.value.private_ip_address
  }
}

# sleep because of sysprep SID change
resource "time_sleep" "goad_vm_wait_10m" {
  depends_on = [sbercloud_compute_instance.goad_vm]

  create_duration = "10m"
}
