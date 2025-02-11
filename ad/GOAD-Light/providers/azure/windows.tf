"dc01" = {
  name               = "dc01"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2019-Datacenter"
  windows_version    = "latest" # deprecated : "2019.0.20181122"
  private_ip_address = "{{ip_range}}.10"
  password           = "8dCT-DJjgScp"
  size               = "Standard_B2s"
}
"dc02" = {
  name               = "dc02"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2019-Datacenter"
  windows_version    = "latest" # deprecated : "2019.0.20181122"
  private_ip_address = "{{ip_range}}.11"
  password           = "NgtI75cKV+Pu"
  size               = "Standard_B2s"
}
"srv02" = {
  name               = "srv02"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2019-Datacenter"
  windows_version    = "latest" # deprecated : "2019.0.20181122"
  private_ip_address = "{{ip_range}}.22"
  password           = "NgtI75cKV+Pu"
  size               = "Standard_B2s"
}
