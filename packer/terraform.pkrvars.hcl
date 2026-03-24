# Connexion Proxmox
proxmox_url      = "https://152.228.222.18:8006/api2/json"
proxmox_username = "root@pam"
proxmox_password = "wpda26saGEamJpud"
proxmox_node     = "ovh-pve-01"

# Sécurité
insecure_skip_tls_verify = true

# Configuration VM
vm_id        = 9000
vm_name      = "debian-13-cloudinit"
storage_pool = "data"

# SSH (utilisé pendant le build seulement)
ssh_password = "packer"
