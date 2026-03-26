locals {
  vpc_id    = {% if use_existing_vpc %}"{{config.get_value('aws', 'aws_vpc_id', '')}}"{% else %}data.terraform_remote_state.core.outputs.vpc_id{% endif %}

  subnet_id = {% if use_existing_vpc %}"{{config.get_value('aws', 'aws_subnet_id', '')}}"{% else %}data.terraform_remote_state.core.outputs.private_subnet_id{% endif %}

  sg_id     = {% if use_existing_vpc %}"{{config.get_value('aws', 'aws_security_group_id', '')}}"{% else %}data.terraform_remote_state.core.outputs.security_group_id{% endif %}
}

resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description            = "{{lab_name}} GOAD VPN"
  server_certificate_arn = aws_acm_certificate.server.arn
  client_cidr_block      = var.client_cidr_block
  split_tunnel           = true
  transport_protocol     = "udp"

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.ca.arn
  }

  connection_log_options { enabled = false }

  tags = { Name = "{{lab_name}}-vpn", Lab = "{{lab_identifier}}" }
}

resource "aws_ec2_client_vpn_network_association" "vpn_assoc" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id              = local.subnet_id
  security_groups        = [local.sg_id]
}

resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr    = var.vpc_cidr
  authorize_all_groups   = true
}
