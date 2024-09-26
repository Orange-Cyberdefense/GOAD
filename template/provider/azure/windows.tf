# find image list:
# az vm image list --location "west europe" --publisher "MicrosoftWindowsServer" --offer "WindowsServer" --sku "2019-Datacenter" --all -o table
variable "vm_config" {
  type = map(object({
    name               = string
    publisher          = string
    offer              = string
    windows_sku        = string
    windows_version    = string
    private_ip_address = string
    password           = string
    size               = string
  }))

  default = {
    {{windows_vms}}
  }
}

resource "azurerm_windows_virtual_machine" "goad-vm" {
  for_each = var.vm_config

  name                = "goad-vm-${each.value.name}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  size                = "${each.value.size}"
  admin_username      = var.username
  admin_password      = "${each.value.password}"
  network_interface_ids = [
    azurerm_network_interface.goad-vm-nic[each.key].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.windows_sku
    version   = each.value.windows_version # "latest"
  }
}

resource "azurerm_virtual_machine_extension" "goad-vm-ext" {
  for_each = var.vm_config

  name                 = "${each.value.name}-ansible-prep"
  virtual_machine_id   = azurerm_windows_virtual_machine.goad-vm[each.key].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
  {
    "fileUris": ["https://raw.githubusercontent.com/ansible/ansible/38e50c9f819a045ea4d40068f83e78adbfaf2e68/examples/scripts/ConfigureRemotingForAnsible.ps1"],
    "commandToExecute": "net user ansible ${each.value.password} /add /expires:never /y && net localgroup administrators ansible /add && powershell -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1"
  }
  SETTINGS
}