
resource "azurerm_network_interface" "goad-vm-nic" {
  name                = "goad-vm-${var.name}-nic"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "goad-vm-${var.name}-nic-ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip_address
  }
}

resource "azurerm_windows_virtual_machine" "goad-vm" {
  name                = "goad-vm-${var.name}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  size                = var.size
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.goad-vm-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.windows_sku
    version   = var.windows_version # "latest"
  }
}

resource "azurerm_virtual_machine_extension" "goad-vm-ext" {
  name                 = "${var.name}-ansible-prep"
  virtual_machine_id   = azurerm_windows_virtual_machine.goad-vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
  {
    "fileUris": ["https://raw.githubusercontent.com/ansible/ansible/38e50c9f819a045ea4d40068f83e78adbfaf2e68/examples/scripts/ConfigureRemotingForAnsible.ps1"],
    "commandToExecute": "net user ansible ${var.password} /add /expires:never /y && net localgroup administrators ansible /add && powershell -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1"
  }
  SETTINGS
}