# Snippet pour la configuration Talos (optionnel si tu utilises NoCloud)
# resource "proxmox_virtual_environment_file" "talos_config" {
#   content_type = "snippets"
#   datastore_id = "local"
#   node_name    = var.pve_node
# 
#   source_raw {
#     data      = file("${path.module}/talos-config.yaml")
#     file_name = "talos-${var.node_name}-config.yaml"
#   }
# }

# VM Talos
resource "proxmox_virtual_environment_vm" "talos_node" {
  #   depends_on = [
  #    proxmox_virtual_environment_file.talos_config,
  #   ]

  name        = var.node_name
  description = "Talos Linux created with OpenTofu"
  tags        = ["OpenTofu", "Talos"]
  node_name   = var.pve_node

  cpu {
    cores = var.cpu_number
    type  = "host"
  }

  memory {
    dedicated = var.memory_size
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = "local:iso/${var.talos_image_name}"
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    ssd          = true
    size         = var.disk_size
    file_format  = "raw"
  }

  count = 3

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
    # vlan_id = 10 
    mac_address = "BC:24:11:01:00:${format("%02X", count.index + 1)}"
  }
  
  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
    timeout = "5m"
  }

  
  # Pour monter la config via cloud-init (alternative à NoCloud)
  # initialization {
  #   datastore_id      = "local"
  #   user_data_file_id = proxmox_virtual_environment_file.talos_config.id
  # }
}

