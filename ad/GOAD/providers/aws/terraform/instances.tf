resource "aws_network_interface" "goad_eni" {
  for_each        = var.ec2_config
  subnet_id       = aws_subnet.goad_subnet["private"].id
  private_ips     = [each.value.private_ip_address]
  security_groups = [aws_security_group.goad_internal.id]

  tags = local.tags
}

resource "aws_instance" "goad_ec2" {
  for_each      = var.ec2_config
  ami           = data.aws_ami.instances[each.value.os].id
  instance_type = "t3.medium"

  network_interface {
    network_interface_id = aws_network_interface.goad_eni[each.key].id
    device_index         = 0
  }

  user_data = templatefile("${path.module}/user_data/instance-init.ps1.tpl", {
    username = var.username
    password = each.value.password
    domain   = each.value.domain
  })

  tags = merge(local.tags, { Name = "GOAD-${each.key}" })
}

resource "aws_instance" "goad_jumpbox" {
  ami                         = data.aws_ami.instances["ubuntu"].id
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.jump_key.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.goad_subnet["public"].id
  vpc_security_group_ids      = [aws_security_group.goad_internal.id, aws_security_group.goad_jumpbox.id]

  user_data = templatefile("${path.module}/user_data/instance-init.sh.tpl", {
    username = var.jumpbox_username
  })

  tags = merge(local.tags, { Name = "GOAD-jumpbox" })
}

resource "null_resource" "wait_for_instances" {
  depends_on = [aws_instance.goad_ec2, aws_instance.goad_jumpbox]

  triggers = {
    instance_ids = join(",", values(aws_instance.goad_ec2)[*].id, [aws_instance.goad_jumpbox.id])
  }

  provisioner "local-exec" {
    command = <<-EOF
      while true; do
        instance_count=$(aws ec2 describe-instance-status --filter Name=instance-status.status,Values=initializing --query 'InstanceStatuses[].InstanceId' --output text | wc -w)

        if [ "$instance_count" -eq 0 ]; then
          break
        else
          sleep 10
        fi
      done
    EOF
  }
}
