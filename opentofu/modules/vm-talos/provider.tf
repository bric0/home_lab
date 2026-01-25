terraform {
  required_version = "> 1.6.0"
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.pve_endpoint
  pm_user = var.pve_username
  pm_password = var.pve_password
  pm_tls_insecure = var.pve_insecure
}
