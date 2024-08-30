resource "tls_private_key" "ssh_attackbox" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_network_interface" "attackbox_nic" {
  name                = "attackbox-nic"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "attackbox-nic-ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.56.50"
  }
}

resource "random_password" "attackbox_password" {
  length           = 16
  special          = true
}

resource "azurerm_linux_virtual_machine" "attackbox" {
  name                = "attackbox"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  size                = var.size
  admin_username      = var.attackbox_username
  admin_password      = random_password.attackbox_password.result

  disable_password_authentication = false

  admin_ssh_key {
    username   = var.attackbox_username
    public_key = tls_private_key.ssh_attackbox.public_key_openssh
  }

  network_interface_ids = [
    azurerm_network_interface.attackbox_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb = "100"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh_attackbox.private_key_pem}' > ../ssh_keys/attackbox.pem && chmod 600 ../ssh_keys/attackbox.pem"
  }
}
