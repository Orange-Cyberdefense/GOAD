"srv01" = {
  name               = "SRV01"
  desc               = "SRV01 - windows server 2019 - {{ip_range}}.10"
  cores              = 4
  memory             = 12000
  clone              = "WinServer2019_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.21/24"
  gateway            = "{{ip_range}}.1"
}