variable "pve_insecure" {
  type        = bool
  description = "Enable insecure connexion"
  default     = true
}

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

variable "node_name" {
  description = "Nom de la VM Talos"
  type        = string
  default     = ""
}

variable "cpu_number" {
  description = "Nombre de cœurs CPU"
  type        = number
  default     = 2
}

variable "memory_size" {
  description = "Taille de la RAM en Mo"
  type        = number
  default     = 4096
}

variable "disk_size" {
  description = "Taille du disque en Go"
  type        = number
  default     = 20
}


