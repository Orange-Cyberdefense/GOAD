"guacamole" = {
  name               = "guacamole"
  desc               = "guacamole GOAD"
  cores              = 2
  memory             = 4096
  clone              = "Ubuntu_2204_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.52/24"
  gateway            = "{{ip_range}}.1"
}
