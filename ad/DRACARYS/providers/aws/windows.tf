# Standard_B2s : 2 CPU / 4GB
# Standard_B2ms : 2CPU / 8GB
# Standard_B4ms : 4 cpu / 16 GB
"dc01" = {
  name               = "dc01"
  domain             = "dracarys.lab"
  windows_sku        = "2025-Datacenter"
  ami                = "ami-0979a3709cb073ec3"
  instance_type      = "t3.medium"
  private_ip_address = "{{ip_range}}.10"
  password           = "8dCsfT-DJjgS3xdcp"
}
"srv01" = {
  name               = "srv01"
  domain             = "dracarys.lab"
  windows_sku        = "2025-Datacenter"
  ami                = "ami-0979a3709cb073ec3"
  instance_type      = "t3.medium"
  private_ip_address = "{{ip_range}}.11"
  password           = "NgtkgtIAs75cKV+Pu"
}