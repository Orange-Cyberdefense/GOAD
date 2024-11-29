"ws01" = {
  name               = "WS01"
  desc               = "WS01 - windows 10 - {{ip_range}}.10"
  cores              = 2
  memory             = 4096
  clone              = "Windows10_22h2_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.10/24"
  gateway            = "{{ip_range}}.1"
}
