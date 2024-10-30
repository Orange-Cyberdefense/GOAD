"dc01" = {
  name               = "dc01"
  domain             = "sevenkingdoms.local"
  windows_sku        = "2019-Datacenter"
  ami                = "ami-018ebfbd6b0a4c605"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.10"
  password           = "8dCT-DJjgScp"
}