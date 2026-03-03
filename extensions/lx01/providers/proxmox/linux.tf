"lx01" = {
  name               = "lx01"
  desc               = "lx01 GOAD"
  cores              = 1
  memory             = 1024
  clone              = "Ubuntu_2204_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.32/24"
  gateway            = "{{ip_range}}.1"
}
