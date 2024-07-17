output "ubuntu_jumpbox_ip" {
  value = oci_core_instance.jumpbox.public_ip
}

output "windows_instance_opc_passwords" {
  value = { for k, v in oci_core_instance.windows_instance : k => v.metadata.admin_password }
  sensitive = true
}