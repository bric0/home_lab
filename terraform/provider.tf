terraform {
  required_version = "> 1.6.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.75.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.pve_endpoint
  # api_token   = var.pve_api_token
  username = var.pve_username
  password = var.pve_password
  insecure = var.pve_insecure
}
