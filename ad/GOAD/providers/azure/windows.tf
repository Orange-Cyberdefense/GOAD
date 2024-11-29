# Standard_B2s : 2 CPU / 4GB
# Standard_B2ms : 2CPU / 8GB
# Standard_B4ms : 4 cpu / 16 GB
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
"dc02" = {
  name               = "dc02"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2019-Datacenter"
  windows_version    = "17763.4377.230505" # deprecated : "2019.0.20181122"
  private_ip_address = "{{ip_range}}.11"
  password           = "NgtI75cKV+Pu"
  size               = "Standard_B2s"
}
"dc03" = {
  name               = "dc03"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2016-Datacenter"
  windows_version    = "14393.5921.230506" # deprecated : "2016.127.20181122"
  private_ip_address = "{{ip_range}}.12"
  password           = "Ufe-bVXSx9rk"
  size               = "Standard_B2s"
}
"srv02" = {
  name               = "srv02"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2019-Datacenter"
  windows_version    = "17763.4377.230505" # deprecated : "2019.0.20181122"
  private_ip_address = "{{ip_range}}.22"
  password           = "NgtI75cKV+Pu"
  size               = "Standard_B2s"
}
"srv03" = {
  name               = "srv03"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2016-Datacenter"
  windows_version    = "14393.5921.230506" # deprecated : "2016.127.20181122"
  private_ip_address = "{{ip_range}}.23"
  password           = "978i2pF43UJ-"
  size               = "Standard_B2s"
}