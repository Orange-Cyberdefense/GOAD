# CA key + self-signed cert
resource "tls_private_key" "ca" { algorithm = "RSA", rsa_bits = 2048 }
resource "tls_self_signed_cert" "ca" {
  private_key_pem       = tls_private_key.ca.private_key_pem
  is_ca_certificate     = true
  validity_period_hours = 87600
  subject { common_name = "{{lab_name}}-vpn-ca", organization = "GOAD" }
  allowed_uses = ["cert_signing", "crl_signing"]
}

# Server cert signed by CA
resource "tls_private_key" "server" { algorithm = "RSA", rsa_bits = 2048 }
resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem
  subject { common_name = "{{lab_name}}-vpn-server" }
}
resource "tls_locally_signed_cert" "server" {
  cert_request_pem      = tls_cert_request.server.cert_request_pem
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 87600
  allowed_uses          = ["digital_signature", "key_encipherment", "server_auth"]
}

# Client cert signed by CA
resource "tls_private_key" "client" { algorithm = "RSA", rsa_bits = 2048 }
resource "tls_cert_request" "client" {
  private_key_pem = tls_private_key.client.private_key_pem
  subject { common_name = "{{lab_name}}-vpn-client" }
}
resource "tls_locally_signed_cert" "client" {
  cert_request_pem      = tls_cert_request.client.cert_request_pem
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 87600
  allowed_uses          = ["digital_signature", "key_encipherment", "client_auth"]
}

# Upload to ACM
resource "aws_acm_certificate" "server" {
  private_key       = tls_private_key.server.private_key_pem
  certificate_body  = tls_locally_signed_cert.server.cert_pem
  certificate_chain = tls_self_signed_cert.ca.cert_pem
  tags = { Name = "{{lab_name}}-vpn-server", Lab = "{{lab_identifier}}" }
}
resource "aws_acm_certificate" "ca" {
  private_key       = tls_private_key.ca.private_key_pem
  certificate_body  = tls_self_signed_cert.ca.cert_pem
  tags = { Name = "{{lab_name}}-vpn-ca", Lab = "{{lab_identifier}}" }
}
