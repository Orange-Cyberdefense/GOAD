output "goad-ip-vpn" {
  value = zipmap(azurerm_linux_virtual_machine.goad-vm-vpn.*.name, chunklist(azurerm_public_ip.pipvpn.*.ip_address, 1))
}
output "goad-ip-dc01" {
  value = zipmap(azurerm_windows_virtual_machine.goad-vm-dc01.*.name, chunklist(azurerm_public_ip.pipdc01.*.ip_address, 1))
}
output "goad-ip-dc02" {
  value = zipmap(azurerm_windows_virtual_machine.goad-vm-dc02.*.name, chunklist(azurerm_public_ip.pipdc02.*.ip_address, 1))
}
output "goad-ip-dc03" {
  value = zipmap(azurerm_windows_virtual_machine.goad-vm-dc03.*.name, chunklist(azurerm_public_ip.pipdc03.*.ip_address, 1))
}
output "goad-ip-srv02" {
  value = zipmap(azurerm_windows_virtual_machine.goad-vm-srv02.*.name, chunklist(azurerm_public_ip.pipsrv02.*.ip_address, 1))
}
output "goad-ip-srv03" {
  value = zipmap(azurerm_windows_virtual_machine.goad-vm-srv03.*.name, chunklist(azurerm_public_ip.pipsrv03.*.ip_address, 1))
}
