resource "proxmox_virtual_environment_vm" "talos_node" {
  name        = var.node_name
  description = "Talos Linux created with OpenTofu"
  node_name   = var.pve_node
  
  bios    = "seabios"
  on_boot = true
  
  agent {
    enabled = true
  }
  
  operating_system {
    type = "l26"
  }
  
  cpu {
    cores   = var.cpu_number
    sockets = 1
    type    = "host"
  }
  
  memory {
    dedicated = var.memory_size
  }
  
  disk {
    datastore_id = "local-lvm"
    size         = var.disk_size
    interface    = "scsi0"
    iothread     = false
    discard      = "on"
  }
  
  cdrom {
    file_id   = "local:iso/${var.talos_image_name}"
    interface = "ide2"
  }
  
  network_device {
    bridge  = "vmbr0"
    model   = "virtio"
    vlan_id = 10
  }
  
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  boot_order = ["scsi0", "ide2"]
  
  scsi_hardware = "virtio-scsi-pci"
  
  lifecycle {
    ignore_changes = [
      network_device,
    ]
  }
}


