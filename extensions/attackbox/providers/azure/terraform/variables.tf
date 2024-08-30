variable "resource_group_location" {
  type    = string
  default = ""
}

variable "resource_group_name" {
  type    = string
  default = ""
}

variable "subnet_id" {
  type = string
  description = "subnet id"
}

variable "size" {
  type    = string
  default = "Standard_B2s"
}

variable "attackbox_username" {
  type = string
  default = "hacker"
}
