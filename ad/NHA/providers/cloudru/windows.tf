# s7n.large.2 : 2 CPU / 4GB
# s7n.large.4 : 2CPU / 8GB
# s7n.xlarge.2 : 4 cpu / 8 GB
# s7n.xlarge.4 : 4 cpu / 16 GB
"dc01" = {
  name               = "dc01"
  os_image           = "Windows_Server_2019_Datacenter_64bit_06_2025_sysprep"
  private_ip_address = "{{ip_range}}.10"
  password           = "8dCT-6546541qsdDJjgScp"
  size               = "s7n.large.2"
}
"dc02" = {
  name               = "dc02"
  os_image           = "Windows_Server_2019_Datacenter_64bit_06_2025_sysprep"
  private_ip_address = "{{ip_range}}.20"
  password           = "Ufe-qsdaz789bVXSx9rk"
  size               = "s7n.large.2"
}
"srv01" = {
  name               = "srv01"
  os_image           = "Windows_Server_2019_Datacenter_64bit_06_2025_sysprep"
  private_ip_address = "{{ip_range}}.21"
  password           = "EaqsdP+xh7sdfzaRk6j90"
  size               = "s7n.large.2"
}
"srv02" = {
  name               = "srv02"
  os_image           = "Windows_Server_2019_Datacenter_64bit_06_2025_sysprep"
  private_ip_address = "{{ip_range}}.22"
  password           = "978i2pF43UqsdqsdJ-qsd"
  size               = "s7n.large.2"
}
"srv03" = {
  name               = "srv03"
  os_image           = "Windows_Server_2019_Datacenter_64bit_06_2025_sysprep"
  private_ip_address = "{{ip_range}}.23"
  password           = "EalwxkfhqsdP+xh7sdfzaRj90"
  size               = "s7n.large.2"
}
