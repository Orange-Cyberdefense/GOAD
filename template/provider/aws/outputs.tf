output "ubuntu-jumpbox-ip" {
  value = aws_eip.public_ip.public_ip
}

output "ubuntu-jumpbox-username" {
  value = var.jumpbox_username
}

output "vm-config" {
  value = var.vm_config
}

output "windows-vm-username" {
  value = var.username
}