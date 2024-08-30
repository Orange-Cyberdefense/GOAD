# ELK EXTENSION

# VARIABLES
variable "elk_username" {
  type = string
  default = "elk"
}

variable "resource_group_location" {
  type    = string
  default = azurerm_resource_group.resource_group.location
}

variable "resource_group_name" {
  type    = string
  default = azurerm_resource_group.resource_group.name
}

variable "subnet_id" {
  type = string
  description = azurerm_subnet.subnet.id
}

# RECIPE
resource "tls_private_key" "ssh_elk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_network_interface" "elk_nic" {
  name                = "elk-nic"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "elk-nic-ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.56.51"
  }
}

resource "random_password" "elk_password" {
  length           = 16
  special          = true
}

resource "azurerm_linux_virtual_machine" "elk" {
  name                = "elk"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  size                = var.size
  admin_username      = var.elk_username
  admin_password      = random_password.elk_password.result

  disable_password_authentication = false

  admin_ssh_key {
    username   = var.elk_username
    public_key = tls_private_key.ssh_elk.public_key_openssh
  }

  network_interface_ids = [
    azurerm_network_interface.elk_nic.id,
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
    command = "echo '${tls_private_key.ssh_elk.private_key_pem}' > ../ssh_keys/elk.pem && chmod 600 ../ssh_keys/elk.pem"
  }
}
