"dc01" = {
  name               = "dc01"
  windows_sku        = "2019-Datacenter"
  windows_version    = "17763.4377.230505" # deprecated : "2019.0.20181122"
  private_ip_address = "{{ip_range}}.10"
  password           = "8dCT-DJjgScp"
}
"dc02" = {
  name               = "dc02"
  windows_sku        = "2019-Datacenter"
  windows_version    = "17763.4377.230505" # deprecated : "2019.0.20181122"
  private_ip_address = "{{ip_range}}.11"
  password           = "NgtI75cKV+Pu"
}
"srv02" = {
  name               = "srv02"
  windows_sku        = "2019-Datacenter"
  windows_version    = "17763.4377.230505" # deprecated : "2019.0.20181122"
  private_ip_address = "{{ip_range}}.22"
  password           = "NgtI75cKV+Pu"
}