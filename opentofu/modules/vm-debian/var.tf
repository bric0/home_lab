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

variable "node_name" {
  description = "Nom de la VM"
  type        = string
  default     = ""
}

variable "template_id" {
  description = "Template ID"
  type        = number
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
  description = "Disk size"
  type        = number
}

variable "vm_ip" {
  description = "VM IP"
  type        = string
  default     = ""
}

variable "vm_gateway" {
  type        = string
  description = "Gateway par défaut"
  default     = ""
}

variable "vlan_id" {
  type        = number
  description = "VLAN ID pour l'interface principale"
  default     = null
}

variable "additional_network_ip" {
  type        = string
  description = "IP pour l'interface additionnelle"
  default     = null
}

variable "additional_gateway_ip" {
  type        = string
  description = "Gateway pour l'interface additionnelle"
  default     = null
}
variable "additional_network" {
  type = object({
    bridge = string
    model  = string
    tag    = optional(number)
  })
  description = "Interface réseau additionnelle (optionnelle)"
  default     = null
}

variable "vm_username" {
  type        = string
  description = "Nom d'utilisateur cloud-init"
  default     = "brico"
}

variable "vm_password" {
  type        = string
  description = "Cloud init Password"
}

variable "ssh_keys" {
  type        = list(string)
  description = "Liste des clés SSH publiques"
  default     = []
}
