output "vpn_endpoint_id" {
  value = aws_ec2_client_vpn_endpoint.vpn.id
}

output "ovpn_config" {
  description = "OpenVPN client configuration file content"
  value = <<-EOT
client
dev tun
proto udp
remote ${replace(aws_ec2_client_vpn_endpoint.vpn.dns_name, "*.", "")} 443
remote-random-hostname
resolv-retry infinite
nobind
remote-cert-tls server
cipher AES-256-GCM
verb 3

<ca>
${tls_self_signed_cert.ca.cert_pem}
</ca>
<cert>
${tls_locally_signed_cert.client.cert_pem}
</cert>
<key>
${tls_private_key.client.private_key_pem}
</key>

reneg-sec 0
EOT
  sensitive = true
}
