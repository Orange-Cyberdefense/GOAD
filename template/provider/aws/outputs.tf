output "ubuntu-jumpbox-ip" {
  value = aws_eip.public_ip.public_ip
}
