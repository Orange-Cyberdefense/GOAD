"dc01" = {
  name               = "dc01"
  domain             = "sevenkingdoms.local"
  windows_sku        = "2019-Datacenter"
  ami                = "ami-018ebfbd6b0a4c605"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.10"
  password           = "8dCT-DJjgScp"
}
"dc02" = {
  name               = "dc02"
  domain             = "north.sevenkingdoms.local"
  windows_sku        = "2019-Datacenter"
  ami                = "ami-018ebfbd6b0a4c605"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.11"
  password           = "NgtI75cKV+Pu"
}
"dc03" = {
  name               = "dc03"
  domain             = "essos.local"
  windows_sku        = "2016-Datacenter"
  ami                = "ami-03a5b89a2fbe7dd3d"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.12"
  password           = "Ufe-bVXSx9rk"
}
"srv02" = {
  name               = "srv02"
  domain             = "north.sevenkingdoms.local"
  windows_sku        = "2019-Datacenter"
  ami                = "ami-018ebfbd6b0a4c605"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.22"
  password           = "NgtI75cKV+Pu"
}
"srv03" = {
  name               = "srv03"
  domain             = "essos.local"
  windows_sku        = "2016-Datacenter"
  ami                = "ami-03a5b89a2fbe7dd3d"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.23"
  password           = "978i2pF43UJ-"
}