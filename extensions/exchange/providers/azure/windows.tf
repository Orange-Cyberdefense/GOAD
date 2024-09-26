"srv01" = {
  name               = "srv01"
  publisher          = "MicrosoftWindowsServer"
  offer              = "WindowsServer"
  windows_sku        = "2019-Datacenter"
  windows_version    = "latest"
  private_ip_address = "{{ip_range}}.21"
  password           = "FP.xh5Fk9Z1c"
  size               = "Standard_B4ms" # Standard_B4ms : 4 cpu / 16 GB
}