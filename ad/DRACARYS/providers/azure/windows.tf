# Standard_B2s : 2 CPU / 4GB
# Standard_B2ms : 2CPU / 8GB
# Standard_B4ms : 4 cpu / 16 GB
"dc01" = {
  name               = "dc01"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2025-Datacenter"
  windows_version    = "latest"
  private_ip_address = "{{ip_range}}.10"
  password           = "8dCsfT-DJjgS3xdcp"
  size               = "Standard_B2s"
}
"srv01" = {
  name               = "srv01"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2025-Datacenter"
  windows_version    = "latest"
  private_ip_address = "{{ip_range}}.11"
  password           = "NgtkgtIAs75cKV+Pu"
  size               = "Standard_B2s"
}