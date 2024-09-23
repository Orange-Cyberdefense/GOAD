"dc01" = {
  name               = "DC"
  desc               = "DC - windows server 2019 - {{ip_range}}.40"
  cores              = 2
  memory             = 4096
  clone              = "WinServer2019_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.40/24"
  gateway            = "{{ip_range}}.1"
}
"srv01" = {
  name               = "MECM"
  desc               = "SRV01 - MECM - windows server 2019 - {{ip_range}}.41"
  cores              = 2
  memory             = 4096
  clone              = "WinServer2019_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.41/24"
  gateway            = "{{ip_range}}.1"
}
"srv02" = {
  name               = "MSSQL"
  desc               = "SRV02 - MSSQL - windows server 2019 - {{ip_range}}.42"
  cores              = 2
  memory             = 4096
  clone              = "WinServer2019_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.42/24"
  gateway            = "{{ip_range}}.1"
}
"ws01" = {
  name               = "CLIENT"
  desc               = "SRV03 - CLIENT - windows server 2019 - {{ip_range}}.43"
  cores              = 2
  memory             = 4096
  clone              = "WinServer2019_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.43/24"
  gateway            = "{{ip_range}}.1"
}