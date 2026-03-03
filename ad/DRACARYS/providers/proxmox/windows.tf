"dc01" = {
  name               = "DC01"
  desc               = "DC01 - DRACARYS - windows server 2025 - {{ip_range}}.10"
  cores              = 2
  memory             = 4096
  clone              = "WinServer2025_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.10/24"
  gateway            = "{{ip_range}}.1"
}
"srv01" = {
  name               = "SRV01"
  desc               = "SRV01 - DRACARYS- windows server 2025 - {{ip_range}}.11"
  cores              = 2
  memory             = 4096
  clone              = "WinServer2025_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.11/24"
  gateway            = "{{ip_range}}.1"
}