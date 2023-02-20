terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = ">=1.0.0"
    }
  }
}

provider "proxmox" {
    pm_api_url = var.pm_api_url
    pm_user = var.pm_user
    pm_password = var.pm_password
    pm_debug = true
    pm_tls_insecure = true
    pm_parallel = 3
    pm_timeout = 2400

    pm_log_enable = true
    pm_log_file = "terraform-plugin-proxmox.log"
    pm_log_levels = {
      _default = "debug"
      _capturelog = ""
    }

}
