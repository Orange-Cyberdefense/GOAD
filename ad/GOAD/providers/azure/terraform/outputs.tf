output "ubuntu-jumpbox-ip" {
  value = azurerm_linux_virtual_machine.jumpbox.public_ip_address
}

output "ubuntu-jumpbox-username" {
  value = azurerm_linux_virtual_machine.jumpbox.admin_username
}

output "kali-attackbox-username" {
  value = azurerm_linux_virtual_machine.kali_attackbox.admin_username
}

output "kali-attackbox-password" {
  value     = random_password.kali_password.result
  sensitive = true
}

output "kali-attackbox-ip" {
  value = azurerm_linux_virtual_machine.kali_attackbox.private_ip_address
}

output "vm-config" {
  value = var.vm_config
}

output "windows-vm-username" {
  value = var.username
}