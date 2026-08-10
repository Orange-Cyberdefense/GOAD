output "ubuntu-jumpbox-ip" {
  value = sbercloud_vpc_eip.goad_nat_public_ip.address
}

output "ubuntu-jumpbox-username" {
  value = var.jumpbox_username
}

output "vm-config" {
  value = var.vm_config
}

output "linux-vm-config" {
  value = var.linux_vm_config
}

output "vm-admin-username" {
  value = var.username
}
