resource "azurerm_virtual_network" "virtual_network" {
  name                = "{{lab_name}}-virtual-network"
  address_space       = ["{{ip_range}}.0/24"]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "{{lab_name}}-vm-subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["{{ip_range}}.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                 = "{{lab_name}}-subnet-nsg"
  location             = azurerm_resource_group.resource_group.location
  resource_group_name  = azurerm_resource_group.resource_group.name

  security_rule {
    name                          = "AllowSSHInboundOnly"
    priority                      = 100
    direction                     = "Inbound"
    access                        = "Allow"
    protocol                      = "Tcp"
    source_port_range             = "*"
    destination_port_range        = "22"
    source_address_prefix         = "*"
    destination_address_prefix    = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                       = azurerm_subnet.subnet.id
  network_security_group_id       = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "goad-vm-nic" {
  for_each = var.vm_config

  name                = "{{lab_name}}-vm-${each.value.name}-nic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "{{lab_name}}-vm-${each.value.name}-nic-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.private_ip_address
  }
}

resource "azurerm_network_interface" "goad-linux-vm-nic" {
  for_each = var.linux_vm_config

  name                = "{{lab_name}}-vm-${each.value.name}-nic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "{{lab_name}}-vm-${each.value.name}-nic-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.private_ip_address
  }
}
