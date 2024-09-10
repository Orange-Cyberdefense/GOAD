# find image list:
variable "linux_vm_config" {
  type = map(object({
    name               = string
    linux_sku          = string
    linux_version      = string
    private_ip_address = string
    password           = string
    size               = string
  }))

  default = {
    {{linux_vms}}
  }
}

resource "tls_private_key" "linux_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "goad-linux-vm" {
  for_each = var.linux_vm_config

  name                = "goad-vm-${each.value.name}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "${each.value.size}"
  admin_username      = var.username
  admin_password      = "${each.value.password}"
  network_interface_ids = [
    azurerm_network_interface.goad-linux-vm-nic[each.key].id,
  ]

  disable_password_authentication = false

  admin_ssh_key {
    username   = var.username
    public_key = tls_private_key.linux_ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = each.value.linux_sku # "22_04-lts-gen2"
    version   = each.value.linux_version # "latest"
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.linux_ssh.private_key_pem}' > ../ssh_keys/${each.value.name}_ssh.pem && chmod 600 ../ssh_keys/${each.value.name}_ssh.pem"
  }
}