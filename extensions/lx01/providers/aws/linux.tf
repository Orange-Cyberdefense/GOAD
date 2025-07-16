"lx01" = {
  name               = "lx01"
  linux_sku          = "22_04-lts-gen2"
  linux_version      = "latest"
  ami                = "ami-00c71bd4d220aa22a"
  private_ip_address = "{{ip_range}}.32"
  password           = "HGLXP@ssw_rd$"
  size               = "t2.micro"  # 1cpu / 1GB
}