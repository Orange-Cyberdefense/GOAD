output "ubuntu-jumpbox-ip" {
  value = azurerm_linux_virtual_machine.jumpbox.public_ip_address
}
