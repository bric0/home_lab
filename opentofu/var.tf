variable "pve_endpoint" {
  type        = string
  description = "API endpoint URL"
}

variable "pve_password" {
  type        = string
  description = "Password"
}

variable "pve_username" {
  type        = string
  description = "Username"
}

variable "pve_node" {
  type        = string
  description = "Node where install elements"
  default     = ""
}

variable "talos_version" {
  description = "Version de Talos Linux"
  type        = string
  default     = ""
}

variable "talos_image_name" {
  description = "Nom du fichier image Talos"
  type        = string
  default     = ""
}
