"lx01" = {
  name               = "lx01"
  linux_sku          = "22_04-lts-gen2"
  linux_version      = "latest"
  ami                = "ami-04c332520bd9cedb4"
  private_ip_address = "{{ip_range}}.32"
  password           = "HGLXP@ssw_rd$"
  instance_type      = "t2.micro"  # 1cpu / 1GB
}