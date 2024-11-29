"dc01" = {
  name               = "DC01"
  desc               = "DC01 - windows server 2019 - {{ip_range}}.10"
  cores              = 2
  memory             = 3096
  clone              = "WinServer2019_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.10/24"
  gateway            = "{{ip_range}}.1"
}
"dc02" = {
  name               = "DC02"
  desc               = "DC02 - windows server 2019 - {{ip_range}}.11"
  cores              = 2
  memory             = 3096
  clone              = "WinServer2019_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.11/24"
  gateway            = "{{ip_range}}.1"
}
"dc03" = {
  name               = "DC03"
  desc               = "DC03 - windows server 2016 - {{ip_range}}.12"
  cores              = 2
  memory             = 3096
  clone              = "WinServer2016_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.12/24"
  gateway            = "{{ip_range}}.1"
}
"srv02" = {
  name               = "SRV02"
  desc               = "SRV02 - windows server 2019 - {{ip_range}}.22"
  cores              = 2
  memory             = 6240
  clone              = "WinServer2019_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.22/24"
  gateway            = "{{ip_range}}.1"
}
"srv03" = {
  name               = "SRV03"
  desc               = "SRV03 - windows server 2016 - {{ip_range}}.23"
  cores              = 2
  memory             = 5120
  clone              = "WinServer2016_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.23/24"
  gateway            = "{{ip_range}}.1"
}