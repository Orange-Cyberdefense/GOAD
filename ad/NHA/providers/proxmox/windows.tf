"dc01" = {
  name               = "goadv3-DC01"
  desc               = "DC01 - windows server 2019 - {{ip_range}}.10"
  cores              = 2
  memory             = 3096
  clone              = "WinServer2019_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.10/24"
  gateway            = "{{ip_range}}.1"
}
"dc02" = {
  name               = "goadv3-DC02"
  desc               = "DC02 - windows server 2019 - {{ip_range}}.11"
  cores              = 2
  memory             = 3096
  clone              = "WinServer2019_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.11/24"
  gateway            = "{{ip_range}}.1"
}
"srv01" = {
  name               = "goadv3-SRV01"
  desc               = "SRV01 - windows server 2019 - {{ip_range}}.21"
  cores              = 2
  memory             = 4096
  clone              = "WinServer2019_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.21/24"
  gateway            = "{{ip_range}}.1"
}
"srv02" = {
  name               = "goadv3-SRV02"
  desc               = "SRV02 - windows server 2019 - {{ip_range}}.22"
  cores              = 2
  memory             = 4096
  clone              = "WinServer2019_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.22/24"
  gateway            = "{{ip_range}}.1"
}
"srv03" = {
  name               = "goadv3-SRV03"
  desc               = "SRV03 - windows server 2016 - {{ip_range}}.23"
  cores              = 2
  memory             = 4096
  clone              = "WinServer2019_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.23/24"
  gateway            = "{{ip_range}}.1"
}