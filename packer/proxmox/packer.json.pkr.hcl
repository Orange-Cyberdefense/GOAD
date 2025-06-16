
packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.2, < 1.2.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "windows" {
  boot_iso {
    type                   = "sata"
    index                  = "1"
    iso_checksum           = "${var.iso_checksum}"
    iso_storage_pool       = "${var.proxmox_iso_storage}"
    iso_url                = "${var.iso_file}"
    unmount                = true
  }
  additional_iso_files {
    type                   = "sata"
    index                  = "3"
    iso_checksum           = "${var.autounattend_checksum}"
    iso_storage_pool       = "${var.proxmox_iso_storage}"
    iso_url                = "${var.autounattend_iso}"
    unmount                = true
  }
  additional_iso_files {
    type                   = "sata"
    index                  = "4"
    iso_checksum           = "${var.virtio_checksum}"
    iso_storage_pool       = "${var.proxmox_iso_storage}"
    iso_url                = "${var.virtio_iso}"
    unmount                = true
  }
  additional_iso_files {
    type                   = "sata"
    index                  = "5"
    iso_checksum           = "${var.scripts_checksum}"
    iso_storage_pool       = "${var.proxmox_iso_storage}"
    iso_url                = "${var.scripts_iso}"
    unmount                = true
  }
  communicator             = "winrm"
  cores                    = "${var.vm_cpu_cores}"
  cpu_type                 = "${var.vm_cpu_type}"
  disks {
    disk_size              = "${var.vm_disk_size}"
    format                 = "${var.vm_disk_format}"
    storage_pool           = "${var.proxmox_vm_storage}"
    type                   = "sata"
  }
  insecure_skip_tls_verify = "${var.proxmox_skip_tls_verify}"
  machine                  = "${var.vm_machine}"
  memory                   = "${var.vm_memory}"
  network_adapters {
    bridge                 = "${var.proxmox_bridge}"
    model                  = "virtio"
  }
  efi_config {
    efi_storage_pool       = "${var.proxmox_vm_storage}"
    pre_enrolled_keys      = true
    efi_format             = "raw"
    efi_type               = "4m"
  }
  tpm_config {
    tpm_storage_pool       = "${var.proxmox_vm_storage}"
    tpm_version            = "v2.0"
  }
  boot_wait = "5s"
  boot_command = [
    "<enter>"
  ]

  node                     = "${var.proxmox_node}"
  os                       = "${var.os}"
  password                 = "${var.proxmox_password}"
  pool                     = "${var.proxmox_pool}"
  proxmox_url              = "${var.proxmox_url}"
  sockets                  = "${var.vm_sockets}"
  template_description     = "${var.template_description}"
  template_name            = "${var.vm_name}"
  username                 = "${var.proxmox_username}"
  vm_name                  = "${var.vm_name}"
  bios                     = "${var.bios}"
  winrm_insecure           = true
  winrm_no_proxy           = true
  winrm_password           = "${var.winrm_password}"
  winrm_timeout            = "120m"
  winrm_use_ssl            = true
  winrm_username           = "${var.winrm_username}"
  task_timeout             = "40m"
}

build {
  sources = ["source.proxmox-iso.windows"]

  provisioner "powershell" {
    elevated_password      = "${var.winrm_password}"
    elevated_user          = "${var.winrm_username}"
    pause_before           = "30s"
    scripts                = ["${path.root}/scripts/sysprep/cloudbase-init.ps1"]
  }

  provisioner "powershell" {
    elevated_password      = "${var.winrm_password}"
    elevated_user          = "${var.winrm_username}"
    pause_before           = "30s"
    scripts                = ["${path.root}/scripts/sysprep/cloudbase-init-p2.ps1"]
    valid_exit_codes       = [0, 259]
  }
}
