resource "oci_core_instance" "windows_instance" {
  for_each = {
   kingslanding = {
      name               = "kingslanding"
      private_ip_address = "192.168.56.10"
      admin_username     = "ansible"
      admin_password     = "8dCT-DJjgScp"
      image_ocid         = var.windows2019_image_ocid
    }
    winterfell = {
      name               = "winterfell"
      private_ip_address = "192.168.56.11"
      admin_username     = "ansible"
      admin_password     = "NgtI75cKV+Pu"
      image_ocid         = var.windows2019_image_ocid
    }
    castelblack = {
      name               = "castelblack"
      private_ip_address = "192.168.56.22"
      admin_username     = "ansible"
      admin_password     = "NgtI75cKV+Pu"
      image_ocid         = var.windows2019_image_ocid
    }
    meereen = {
      name               = "meereen"
      private_ip_address = "192.168.56.12"
      admin_username     = "ansible"
      admin_password     = "Ufe-bVXSx9rk"
      image_ocid         = var.windows2016_image_ocid
    }
    braavos = {
      name               = "braavos"
      private_ip_address = "192.168.56.23"
      admin_username     = "ansible"
      admin_password     = "978i2pF43UJ-"
      image_ocid         = var.windows2016_image_ocid
    }
  }

  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = each.value.name
  shape               = "VM.Standard.E5.Flex"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 32
  }

  source_details {
    source_id   = each.value.image_ocid
    source_type = "image"
  }

  create_vnic_details {
    assign_ipv6ip             = false
    assign_private_dns_record = true
    assign_public_ip          = false
    subnet_id                 = oci_core_subnet.private_subnet.id
    hostname_label            = each.value.name
    private_ip                = each.value.private_ip_address
  }

  metadata = {
    user_data      = base64encode(file("${path.module}/windows_cloud_init.ps1"))
    admin_password = each.value.admin_password
  }


}