variable "vm_config" {
  type = map(object({
    name               = string
    os_image           = string
    private_ip_address = string
    password           = string
    size               = string
  }))

  default = {
    {{windows_vms}}
  }
}

resource "sbercloud_compute_instance" "goad_vm" {
  for_each = var.vm_config

  name               = "${var.name_prefix}-${each.value.name}"
  region             = var.region
  image_name         = each.value.os_image
  flavor_id          = each.value.size
  admin_pass         = each.value.password
  security_group_ids = [sbercloud_networking_secgroup.secgroup_allow_any.id]

  system_disk_type = "SAS"
  system_disk_size = 60 # 60 because SCCM lab can't be setted up with default 40

  user_data = templatefile("${path.module}/instance-init-windows.ps1.tpl", {
    username = var.username
    password = each.value.password
  })

  network {
    uuid        = sbercloud_vpc_subnet.goad_subnet.id
    fixed_ip_v4 = each.value.private_ip_address
  }
}

# sleep because of sysprep SID change
resource "time_sleep" "goad_vm_wait_windows_machine" {
  depends_on = [sbercloud_compute_instance.goad_vm]

  create_duration = "4m"
}
