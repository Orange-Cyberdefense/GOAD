"dc01" = {
  name               = "dc01"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2019-Datacenter"
  windows_version    = "17763.4377.230505" # deprecated : "2019.0.20181122"
  private_ip_address = "{{ip_range}}.10"
  password           = "8dCT-DJjgScp"
  size               = "Standard_B2s"
}