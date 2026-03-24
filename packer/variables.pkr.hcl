variable "proxmox_url" {
  type        = string
  description = "Proxmox API URL"
}

variable "proxmox_username" {
  type        = string
  description = "Proxmox API username"
}

variable "proxmox_password" {
  type      = string
  sensitive = true
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node name"
}

variable "proxmox_host" {
  type        = string
  description = "Proxmox host IP (for SSH post-processor)"
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
  default = "debian-13-cloudinit"
}

variable "storage_pool" {
  type    = string
  default = "data"
}

variable "iso_file" {
  type        = string
  description = "Proxmox ISO file path"
  default     = "local:iso/debian-13.3.0-amd64-netinst.iso"
}

variable "iso_checksum" {
  type        = string
  description = "ISO checksum"
  default     = "sha512:1ada40e4c938528dd8e6b9c88c19b978a0f8e2a6757b9cf634987012d37ec98503ebf3e05acbae9be4c0ec00b52e8852106de1bda93a2399d125facea45400f8"
}

variable "ssh_password" {
  type      = string
  sensitive = true
  default   = "packer"
}
