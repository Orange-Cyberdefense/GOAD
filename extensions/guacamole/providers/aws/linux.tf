"guacamole" = {
  name               = "guacamole"
  linux_sku          = "22_04-lts-gen2"
  linux_version      = "latest"
  ami                = "ami-04c332520bd9cedb4"
  private_ip_address = "{{ip_range}}.52"
  password           = "sgHvnkThdsXlsd"
  size               = "t2.medium"  # 2cpu / 4GB
}