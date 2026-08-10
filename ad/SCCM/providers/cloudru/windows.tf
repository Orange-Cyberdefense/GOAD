# s7n.large.2 : 2 CPU / 4GB
# s7n.large.4 : 2CPU / 8GB
# s7n.xlarge.2 : 4 cpu / 8 GB
# s7n.xlarge.4 : 4 cpu / 16 GB
"dc01" = {
  name               = "dc01"
  os_image           = "Windows_Server_2019_Datacenter_64bit_06_2025_sysprep"
  private_ip_address = "{{ip_range}}.10"
  password           = "AZERTY*qsdfg"
  size               = "s7n.large.2"
}
"srv01" = {
  name               = "srv01"
  os_image           = "Windows_Server_2019_Datacenter_64bit_06_2025_sysprep"
  private_ip_address = "{{ip_range}}.11"
  password           = "NgtI75cKV+Pu"
  size               = "s7n.large.2"
}
"srv02" = {
  name               = "srv02"
  os_image           = "Windows_Server_2019_Datacenter_64bit_06_2025_sysprep"
  private_ip_address = "{{ip_range}}.12"
  password           = "NgtazecKV+Pu"
  size               = "s7n.large.2"
}
"ws01" = {
  name               = "ws01"
  os_image           = "Windows_Server_2019_Datacenter_64bit_06_2025_sysprep"
  private_ip_address = "{{ip_range}}.13"
  password           = "EP+xh7Rk6j90"
  size               = "s7n.large.2"
}
