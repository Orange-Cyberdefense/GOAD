# t2.medium = 2cpu / 4GB
# t2.large  = 2cpu / 8GB
# t2.xlarge = 4cpu / 16GB
"dc01" = {
  name               = "dc01"
  domain             = "sccm.lab"
  windows_sku        = "2019-Datacenter"
  ami                = "ami-0f86e4f2f0ee6d61f"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.10"
  password           = "AZERTY*qsdfg"
}
"srv01" = {
  name               = "srv01"
  domain             = "sccm.lab"
  windows_sku        = "2019-Datacenter"
  ami                = "ami-0f86e4f2f0ee6d61f"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.11"
  password           = "NgtI75cKV+Pu"
}
"srv02" = {
  name               = "srv02"
  domain             = "sccm.lab"
  windows_sku        = "2019-Datacenter"
  ami                = "ami-0f86e4f2f0ee6d61f"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.12"
  password           = "NgtazecKV+Pu"
}
"ws01" = {
  name               = "ws01"
  domain             = "sccm.lab"
  windows_sku        = "2019-Datacenter"
  ami                = "ami-0f86e4f2f0ee6d61f"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.13"
  password           = "EP+xh7Rk6j90"
}