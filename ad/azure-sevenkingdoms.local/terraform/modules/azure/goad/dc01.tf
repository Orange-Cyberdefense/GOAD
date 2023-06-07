resource "azurerm_network_security_group" "nsgdc01" {
  count               = var.icount
  name                = "nsg-${var.project}-dc01-allowall-${count.index}"
  location            = element(azurerm_resource_group.rg.*.location, count.index)
  resource_group_name = element(azurerm_resource_group.rg.*.name, count.index)


  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 3389
    source_address_prefixes    = "${var.ssh_allow_ips}"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80","443"]
    source_address_prefixes    = "${var.ssh_allow_ips}"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "PSremoting"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["5985","5986"]
    source_address_prefixes    = "${var.ssh_allow_ips}"
    destination_address_prefix = "*"
  }

  tags = {
    project = var.project
  }
}

resource "azurerm_public_ip" "pipdc01" {
  count                        = var.icount * 1
  name                         = "pip-${var.project}-dc01-${floor(count.index / 1)}-${count.index % 1}"
  location                     = element(azurerm_resource_group.rg.*.location, floor(count.index/1))
  resource_group_name          = element(azurerm_resource_group.rg.*.name, floor(count.index/1))
  allocation_method            = "Static"

  tags = {
    project = var.project
  }
}

resource "azurerm_network_interface_security_group_association" "nicnsgdc01" {
  network_interface_id      = azurerm_network_interface.nicdc01[0].id
  network_security_group_id = azurerm_network_security_group.nsgdc01[0].id
}

resource "azurerm_network_interface" "nicdc01" {
  count                     = var.icount
  name                      = "nic-${var.project}-dc01-${count.index}-0"
  location                  = element(azurerm_resource_group.rg.*.location, count.index)
  resource_group_name       = element(azurerm_resource_group.rg.*.name, count.index)
#  network_security_group_id = element(azurerm_network_security_group.nsgdc01.*.id, count.index)

    ip_configuration {
    name                          = "niccfg-${var.project}-dc01-${count.index}-0"
    subnet_id                     = element(azurerm_subnet.subnet.*.id, count.index)
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.0.5"
    public_ip_address_id          = element(azurerm_public_ip.pipdc01.*.id, (count.index*1)+0)
        primary                       = true
      }
  
  tags = {
    project = var.project
  }
}


resource "azurerm_windows_virtual_machine" "goad-vm-dc01" {
  count               = var.icount
  name                = "${var.project}-dc01-${count.index}"
  location            = element(azurerm_resource_group.rg.*.location, count.index)
  resource_group_name = element(azurerm_resource_group.rg.*.name, count.index)
  size                = var.size
  admin_username      = var.username
  admin_password      = var.pw
  network_interface_ids = [element(azurerm_network_interface.nicdc01.*.id, count.index)]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "goad-vm-dc01-ext" {
  name                 = "dc01-ansible-prep"
  virtual_machine_id   = azurerm_windows_virtual_machine.goad-vm-dc01[0].id
  # publisher            = "Microsoft.Azure.Extensions"
  # type                 = "CustomScript"
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
