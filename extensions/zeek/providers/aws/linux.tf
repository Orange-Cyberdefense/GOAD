"zeek" = {
  name               = "zeek"
  linux_sku          = "22_04-lts-gen2"
  linux_version      = "latest"
  ami                = "ami-00c71bd4d220aa22a"
  private_ip_address = "{{ip_range}}.53"
  password           = "Ze3k@GOAD2024!"
  size               = "t2.small"  # 2cpu / 2GB
}
