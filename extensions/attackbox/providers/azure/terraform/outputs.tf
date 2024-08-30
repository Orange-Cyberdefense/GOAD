output "attackbox-username" {
  value = azurerm_linux_virtual_machine.attackbox.admin_username
}

output "attackbox-password" {
  value     = random_password.attackbox_password.result
  sensitive = true
}

output "attackbox-ip" {
  value = azurerm_linux_virtual_machine.attackbox.private_ip_address
}