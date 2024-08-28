output "wazuh-username" {
  value = azurerm_linux_virtual_machine.wazuh.admin_username
}

output "wazuh-password" {
  value     = random_password.wazuh_password.result
  sensitive = true
}

output "wazuh-ip" {
  value = azurerm_linux_virtual_machine.wazuh.private_ip_address
}