"srv01" = {
  name               = "srv01"
  domain             = "sevenkingdoms.local"
  windows_sku        = "2019-Datacenter"
  ami                = "ami-0f86e4f2f0ee6d61f"
  instance_type      = "t2.xlarge"   # t2.xlarge = 4cpu / 16GB
  private_ip_address = "{{ip_range}}.21"
  password           = "FP.xh5Fk9Z1c"
}
