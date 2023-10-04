variable "location" {
  type    = string
  default = "westeurope"
}

resource "azurerm_resource_group" "resource_group" {
  name     = "GOAD-Light"
  location = var.location
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "goad-virtual-network"
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "goat-vm-subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["192.168.56.0/24"]
}

variable "size" {
  type    = string
  default = "Standard_B2s"
}

variable "username" {
  type    = string
  default = "goadmin"
}

variable "password" {
  description = "Password of the windows virtual machine admin user"
  type    = string
  default = "goadmin"
}

variable "admin_username" {
  type    = string
  default = "goad"
}
