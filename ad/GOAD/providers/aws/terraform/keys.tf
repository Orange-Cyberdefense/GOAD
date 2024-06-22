resource "tls_private_key" "jump_key" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "jump_key" {
  key_name   = "GOAD-jumpbox-keypair"
  public_key = tls_private_key.jump_key.public_key_openssh

  tags = local.tags
}

resource "local_sensitive_file" "key_dump" {
  file_permission = "0600"
  content         = tls_private_key.jump_key.private_key_openssh
  filename        = "../ssh_keys/ubuntu-jumpbox.pem"
}
