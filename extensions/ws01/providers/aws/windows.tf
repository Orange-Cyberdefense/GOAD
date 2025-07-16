# AWS only provide windows server AMI :/
"ws01" = {
  name               = "ws01"
  domain             = "sevenkingdoms.local"
  windows_sku        = "2019-Datacenter"
  ami                = "ami-03440f0d88fea1060"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.31"
  password           = "EP+xh7Rk6j90"
}