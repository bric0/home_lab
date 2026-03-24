variable "proxmox_url" {
  type    = string
  default = "https://your-proxmox:8006/api2/json"
}

variable "proxmox_username" {
  type    = string
  default = "root@pam!packer"
}

variable "proxmox_password" {
  type      = string
  sensitive = true
}

variable "proxmox_node" {
  type    = string
  default = "pve"
}

variable "insecure_skip_tls_verify" {
  type    = bool
  default = true
}

variable "vm_id" {
  type    = number
  default = 9000
}

variable "vm_name" {
  type    = string
  default = "debian-12-cloudinit"
}

variable "storage_pool" {
  type    = string
  default = "data"
}

variable "ssh_password" {
  type      = string
  sensitive = true
  default   = "packer"
}
