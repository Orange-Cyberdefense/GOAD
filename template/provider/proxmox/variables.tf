variable "pm_api_url" {
  default = "{{config.get_value('proxmox', 'pm_api_url', 'https://192.168.1.1:8006/api2/json')}}"
}

variable "pm_user" {
  default = "{{config.get_value('proxmox', 'pm_user', 'infra_as_code@pve')}}"
}

variable "pm_password" {
    type = string
    sensitive = true
}

variable "pm_node" {
  default = "{{config.get_value('proxmox', 'pm_node', 'GOAD')}}"
}

variable "pm_pool" {
  default = "{{config.get_value('proxmox', 'pm_pool', 'GOAD')}}"
}

variable "pm_full_clone" {
  default = "{{config.get_value('proxmox', 'pm_full_clone', 'false')}}"
}

# change this value with the id of your templates (win10 can be ignored if not used)
variable "vm_template_id" {
  type = map(number)

  # set the ids according to your templates
  default = {
      "WinServer2019_x64"  = {{config.get_value('proxmox_templates_id', 'winserver2019_x64', 0)}}
      "WinServer2016_x64"  = {{config.get_value('proxmox_templates_id', 'WinServer2016_x64', 0)}}
      "Windows10_22h2_x64" = {{config.get_value('proxmox_templates_id', 'windows10_22h2_x64', 0)}}
      "ubuntu_jumpbox" = {{config.get_value('proxmox_templates_id', 'ubuntu_jumpbox', 0)}}
  }
}

variable "storage" {
  # change this with the name of the storage you use
  default = "{{config.get_value('proxmox', 'pm_storage', 'local')}}"
}

variable "network_bridge" {
  default = "{{config.get_value('proxmox', 'pm_network_bridge', 'vmbr3')}}"
}

variable "network_bridge_jump" {
  default = "{{config.get_value('proxmox', 'pm_network_bridge_jump', 'vmbr0')}}"
}

variable "network_model" {
  default = "{{config.get_value('proxmox', 'pm_network_model', 'e1000')}}"
}

variable "dns_servers" {
  type = list(string)
  default = ["{{config.get_value('proxmox', 'pm_dns_server', '1.1.1.1')}}"]
}

variable "jumpbox_public_ip" {
  default = "{{config.get_value('proxmox', 'pm_jumpbox_public_ip', '')}}"
}

variable "jumpbox_public_ip_netmask" {
  default = "{{config.get_value('proxmox', 'pm_jumpbox_public_ip_netmask', '')}}"
}

variable "jumpbox_gateway" {
  default = "{{config.get_value('proxmox', 'pm_jumpbox_gateway', '')}}"
}

variable "jumpbox_username" {
  description = "Username for jumpbox SSH user"
  type    = string
  default = "goad"
}