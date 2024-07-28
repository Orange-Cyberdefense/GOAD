output "ubuntu-jumpbox-ip" {
  value = sbercloud_vpc_eip.goad_nat_public_ip.address
}

output "ubuntu-jumpbox-username" {
  value = "root"
}
