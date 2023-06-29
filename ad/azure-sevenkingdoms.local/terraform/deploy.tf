terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.62.1"
    }
  }

  required_version = ">= 0.10.0"
}

provider "azurerm" {
  features {}
}

variable "vm_names" {
  type    = list(string)
  default = ["dc01", "dc02", "dc03", "srv02", "srv03"]
}

variable "vm_private_ip_addresses" {
  type    = list(string)
  default = ["192.168.56.10", "192.168.56.11", "192.168.56.12", "192.168.56.22", "192.168.56.23"]
}

resource "azurerm_network_interface" "goad-vm-nic" {
  count               = length(var.vm_names)
  name                = "goad-vm-${var.vm_names[count.index]}-nic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "goad-vm-${var.vm_names[count.index]}-nic-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = element(var.vm_private_ip_addresses, count.index)
  }
}

resource "azurerm_windows_virtual_machine" "goad-vm" {
  count               = length(var.vm_names)
  name                = var.vm_names[count.index]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  size                = var.size
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.goad-vm-nic[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "goad-vm-ext" {
  count                = length(var.vm_names)
  name                 = "${var.vm_names[count.index]}-ansible-prep"
  virtual_machine_id   = azurerm_windows_virtual_machine.goad-vm[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
  {
    "fileUris": ["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"],
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1"
  }
SETTINGS
}
