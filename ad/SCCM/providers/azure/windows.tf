"dc01" = {
  name               = "dc01"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2019-Datacenter"
  windows_version    = "latest"
  private_ip_address = "{{ip_range}}.10"
  password           = "AZERTY*qsdfg"
  size               = "Standard_B2s"
}
"srv01" = {
  name               = "srv01"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2019-Datacenter"
  windows_version    = "latest"
  private_ip_address = "{{ip_range}}.11"
  password           = "NgtI75cKV+Pu"
  size               = "Standard_B2s"
}
"srv02" = {
  name               = "srv02"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2019-Datacenter"
  windows_version    = "latest"
  private_ip_address = "{{ip_range}}.12"
  password           = "NgtazecKV+Pu"
  size               = "Standard_B2s"
}
"ws01" = {
  name               = "ws01"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2019-Datacenter"
  windows_version    = "latest"
  private_ip_address = "{{ip_range}}.13"
  password           = "EP+xh7Rk6j90"
  size               = "Standard_B2s"
}