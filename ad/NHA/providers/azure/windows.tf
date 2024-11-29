"dc01" = {
  name               = "dc01"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2019-Datacenter"
  windows_version    = "latest"
  private_ip_address = "{{ip_range}}.10"
  password           = "8dCT-6546541qsdDJjgScp"
  size               = "Standard_B2s"
}
"dc02" = {
  name               = "dc02"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2019-Datacenter"
  windows_version    = "latest"
  private_ip_address = "{{ip_range}}.20"
  password           = "Ufe-qsdaz789bVXSx9rk"
  size               = "Standard_B2s"
}
"srv01" = {
  name               = "srv01"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2019-Datacenter"
  windows_version    = "latest"
  private_ip_address = "{{ip_range}}.21"
  password           = "EaqsdP+xh7sdfzaRk6j90"
  size               = "Standard_B2s"
}
"srv02" = {
  name               = "srv02"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2019-Datacenter"
  windows_version    = "latest"
  private_ip_address = "{{ip_range}}.22"
  password           = "978i2pF43UqsdqsdJ-qsd"
  size               = "Standard_B2s"
}
"srv03" = {
  name               = "srv03"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2019-Datacenter"
  windows_version    = "latest"
  private_ip_address = "{{ip_range}}.23"
  password           = "EalwxkfhqsdP+xh7sdfzaRk6j90"
  size               = "Standard_B2s"
}