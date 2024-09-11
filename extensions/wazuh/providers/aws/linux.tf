"wazuh" = {
  name               = "wazuh"
  linux_sku          = "22_04-lts-gen2"
  linux_version      = "latest"
  ami                = "ami-00c71bd4d220aa22a"
  private_ip_address = "{{ip_range}}.51"
  password           = "sgdvnkjhdshlsd"
  size               = "t2.large"  # 2cpu / 8GB
}