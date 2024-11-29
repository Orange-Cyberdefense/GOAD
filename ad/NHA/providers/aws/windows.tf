# t2.medium = 2cpu / 4GB
# t2.large  = 2cpu / 8GB
# t2.xlarge = 4cpu / 16GB
"dc01" = {
  name               = "dc01"
  domain             = "ninja.hack"
  windows_sku        = "2019-Datacenter"
  ami                = "ami-0f86e4f2f0ee6d61f"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.10"
  password           = "8dCT-6546541qsdDJjgScp"
}
"dc02" = {
  name               = "dc02"
  domain             = "academy.ninja.lan"
  windows_sku        = "2019-Datacenter"
  ami                = "ami-0f86e4f2f0ee6d61f"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.20"
  password           = "Ufe-qsdaz789bVXSx9rk"
}
"srv01" = {
  name               = "srv01"
  domain             = "academy.ninja.lan"
  windows_sku        = "2019-Datacenter"
  ami                = "ami-0f86e4f2f0ee6d61f"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.21"
  password           = "EaqsdP+xh7sdfzaRk6j90"
}
"srv02" = {
  name               = "srv02"
  domain             = "academy.ninja.lan"
  windows_sku        = "2019-Datacenter"
  ami                = "ami-0f86e4f2f0ee6d61f"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.22"
  password           = "978i2pF43UqsdqsdJ-qsd"
}
"srv03" = {
  name               = "srv03"
  domain             = "academy.ninja.lan"
  windows_sku        = "2019-Datacenter"
  ami                = "ami-0f86e4f2f0ee6d61f"
  instance_type      = "t2.medium"
  private_ip_address = "{{ip_range}}.23"
  password           = "EalwxkfhqsdP+xh7sdfzaRk6j90"
}