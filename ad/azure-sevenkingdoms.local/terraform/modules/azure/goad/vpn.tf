resource "tls_private_key" "ssh" {
  count     = var.icount
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_network_security_group" "nsgvpn" {
  count               = var.icount
  name                = "nsg-${var.project}-goadvpn-allowall-${count.index}"
  location            = element(azurerm_resource_group.rg.*.location, count.index)
  resource_group_name = element(azurerm_resource_group.rg.*.name, count.index)

  security_rule {
    name                       = "All-In"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    project = var.project
  }
}

resource "azurerm_public_ip" "pipvpn" {
  count                        = var.icount * 1
  name                         = "pip-${var.project}-goadvpn-${floor(count.index / 1)}-${count.index % 1}"
  location                     = element(azurerm_resource_group.rg.*.location, floor(count.index/1))
  resource_group_name          = element(azurerm_resource_group.rg.*.name, floor(count.index/1))
  allocation_method            = "Static"

  tags = {
    project = var.project
  }
}

resource "azurerm_network_interface_security_group_association" "nicnsgvpn" {
  network_interface_id      = azurerm_network_interface.nicvpn[0].id
  network_security_group_id = azurerm_network_security_group.nsgvpn[0].id
}

resource "azurerm_network_interface" "nicvpn" {
  count                     = var.icount
  name                      = "nic-${var.project}-goadvpn-${count.index}-0"
  location                  = element(azurerm_resource_group.rg.*.location, count.index)
  resource_group_name       = element(azurerm_resource_group.rg.*.name, count.index)
  enable_ip_forwarding      = true
#  network_security_group_id = element(azurerm_network_security_group.nsgvpn.*.id, count.index)

    ip_configuration {
    name                          = "niccfg-${var.project}-goadvpn-${count.index}-0"
    subnet_id                     = element(azurerm_subnet.subnet.*.id, count.index)
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.0.4"
    public_ip_address_id          = element(azurerm_public_ip.pipvpn.*.id, (count.index*1)+0)
        primary                   = true
      }
  
  tags = {
    project = var.project
  }
}

resource "azurerm_linux_virtual_machine" "goad-vm-vpn" {
  count                 = var.icount
  name                  = "${var.project}-goadvpn-${count.index}"
  location              = element(azurerm_resource_group.rg.*.location, count.index)
  resource_group_name   = element(azurerm_resource_group.rg.*.name, count.index)
  network_interface_ids = [element(azurerm_network_interface.nicvpn.*.id, count.index)]
  size                  = var.size

  # Official Debian images for Azure: https://wiki.debian.org/Cloud/MicrosoftAzure
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal-daily"
    sku       = "20_04-daily-lts"
    version   = "latest"
  }

  os_disk {
    name                   = "osdisk-${var.project}-goadvpn-${count.index}-0"
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_encryption_set_id = azurerm_disk_encryption_set.disk-encryption-set.id
  }

  admin_username                  = var.username
  computer_name                   = "${var.project}-goadvpn-${count.index}"
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.username
    public_key = element(tls_private_key.ssh.*.public_key_openssh, count.index)
  }


  provisioner "local-exec" {
    command = "echo \"${element(tls_private_key.ssh.*.private_key_pem, count.index)}\" > ../ssh_keys/${var.project}-goadvpn-${count.index} && echo \"${element(tls_private_key.ssh.*.public_key_openssh, count.index)}\" > ../ssh_keys/${var.project}-goadvpn-${count.index}.pub && chmod 400 ../ssh_keys/${var.project}-goadvpn-${count.index}*"

  }

  tags = {
    project = var.project
  }
}

data "azurerm_client_config" "current" {}

data "azurerm_platform_image" "osimage" {
  location  = azurerm_resource_group.rg.0.location
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-focal-daily"
  sku       = "20_04-daily-lts"
  }

resource "azurerm_key_vault" "keyvault" {
  name                        = "kv-${var.project}${random_id.rand.hex}"
  location                    = azurerm_resource_group.rg.0.location
  resource_group_name         = azurerm_resource_group.rg.0.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true
# soft_delete_enabled         = true
  purge_protection_enabled    = true
  sku_name                    = "standard"

  tags = {
    project = var.project
  }
}

resource "azurerm_key_vault_key" "keyvault-key" {
  name         = "key-${var.project}-goadvpn"
  key_vault_id = azurerm_key_vault.keyvault.id
  key_type     = "RSA"
  key_size     = 2048

  depends_on = [
    azurerm_key_vault_access_policy.keyvault-policy-user
  ]

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_disk_encryption_set" "disk-encryption-set" {
  name                = "des-${var.project}-goadvpn"
  location            = azurerm_resource_group.rg.0.location
  resource_group_name = azurerm_resource_group.rg.0.name
  key_vault_key_id    = azurerm_key_vault_key.keyvault-key.id

  identity {
    type = "SystemAssigned"
  }

  tags = {
    project = var.project
  }
}

resource "azurerm_key_vault_access_policy" "keyvault-policy-disk" {
  key_vault_id = azurerm_key_vault.keyvault.id

  tenant_id = azurerm_disk_encryption_set.disk-encryption-set.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.disk-encryption-set.identity.0.principal_id

  key_permissions = [
    "Get",
    "Decrypt",
    "Encrypt",
    "Sign",
    "UnwrapKey",
    "Verify",
    "WrapKey",
  ]
}

resource "azurerm_key_vault_access_policy" "keyvault-policy-user" {
  key_vault_id = azurerm_key_vault.keyvault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey",
    "Create",
    "Delete",
    "List"
  ]
}


resource "azurerm_managed_disk" "goadvpn-data" {
  count                = var.icount
  name                 = "disk-${var.project}-goadvpn-${count.index}-data-0"
  location             = element(azurerm_resource_group.rg.*.location, count.index)
  resource_group_name  = element(azurerm_resource_group.rg.*.name, count.index)
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.disk_size

    disk_encryption_set_id = azurerm_disk_encryption_set.disk-encryption-set.id
  
  tags = {
    project = var.project
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "goadvpn" {
  count              = var.icount
  managed_disk_id    = element(azurerm_managed_disk.goadvpn-data.*.id, count.index)
  virtual_machine_id = element(azurerm_linux_virtual_machine.goad-vm-vpn.*.id, count.index)
  lun                = "10"
  caching            = "ReadWrite"
}


resource "azurerm_route_table" "goadroutetable" {
  count                         = var.icount
  name                          = "${var.project}-routetable-${count.index}"
  location                      = azurerm_resource_group.rg.0.location
  resource_group_name           = azurerm_resource_group.rg.0.name
  disable_bgp_route_propagation = false

  # Address_prefix has to be the same as configured for the ovpn address in ansible
  route {
    name                   = "labtovpn"
    address_prefix         = "192.2.0.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.nicvpn[0].ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "goadrouttablesubnet" {
  count          = var.icount
  subnet_id      = element(azurerm_subnet.subnet.*.id, count.index)
  route_table_id = element(azurerm_route_table.goadroutetable.*.id, count.index)
}
