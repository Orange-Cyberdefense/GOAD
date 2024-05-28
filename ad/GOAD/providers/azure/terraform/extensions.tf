module "attackbox" {
  source = "./extensions/attackbox/"
  size   = "Standard_B2s"
  attackbox_username = "hacker"
  resource_group_location = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  count = 0
}
