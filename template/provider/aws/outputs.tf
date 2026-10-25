{% if provisioner_name == 'local' %}
output "vpc_id" {
  value = {% if use_existing_vpc %}var.existing_vpc_id{% else %}aws_vpc.goad_vpc.id{% endif %}
}
output "private_subnet_id" {
  value = {% if use_existing_vpc %}var.existing_subnet_id{% else %}aws_subnet.goad_private_network.id{% endif %}
}
output "security_group_id" {
  value = {% if use_existing_vpc %}var.existing_security_group_id{% else %}aws_security_group.goad_security_group.id{% endif %}
}
output "vpc_cidr" {
  value = var.goad_cidr
}
{% else %}
output "ubuntu-jumpbox-ip" {
  value = aws_eip.public_ip.public_ip
}
output "ubuntu-jumpbox-username" {
  value = var.jumpbox_username
}
{% endif %}

output "vm-config" {
  value = var.vm_config
}
output "windows-vm-username" {
  value = var.username
}
