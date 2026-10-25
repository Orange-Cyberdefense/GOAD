variable "region" {
  default = "{{config.get_value('aws', 'aws_region', 'eu-west-3')}}"
}
variable "core_state_path" {
  default = "{{core_state_path}}"
}
variable "client_cidr_block" {
  description = "CIDR for VPN client IPs. Must not overlap with VPC CIDR."
  default     = "10.0.0.0/16"
}
variable "vpc_cidr" {
  default = "{{ip_range}}.0/24"
}
