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

variable "iso_url" {
  type        = string
  description = "URL to download Debian ISO"
  default     = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.4.0-amd64-netinst.iso"
}

variable "iso_checksum" {
  type        = string
  description = "ISO SHA512 checksum"
  default     = "sha512:3e02de4ed744799350bd4039b137053835238ff9f9f29eee812309cd7eebdb5127b0f2b54d167b76d324530aa16939b41ae2d2f2d1995a2801e19938acdc927f"
}

variable "ssh_password" {
  type      = string
  sensitive = true
  default   = "packer"
}
