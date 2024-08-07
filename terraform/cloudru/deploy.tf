terraform {
  required_providers {
    sbercloud = {
      source  = "sbercloud-terraform/sbercloud"
      version = "1.12.0"
    }
  }
}

provider "sbercloud" {
  region = var.region
}

resource "sbercloud_compute_instance" "goad_vm" {
  for_each = var.vm_config

  name               = "${var.vpc_name}-${each.value.name}"
  region             = var.region
  image_name         = each.value.os_image
  flavor_id          = var.vm_size
  admin_pass         = each.value.password
  security_group_ids = [sbercloud_networking_secgroup.secgroup_allow_any.id]

  system_disk_type = "SAS"
  system_disk_size = 60 # 60 because SCCM lab can't be setted up with default 40

  user_data = templatefile("${path.module}/user_data/cloudru-instance-init.ps1.tpl", {
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
