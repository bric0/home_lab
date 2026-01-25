resource "proxmox_vm_qemu" "talos_node" {
  name        = var.node_name
  description        = "Talos Linux created with OpenTofu"
  target_node = var.pve_node
  
  bios     = "seabios"
  start_at_node_boot   = true
  agent    = 1
  os_type  = "l26"
  
  cpu {
    cores   = var.cpu_number
    sockets = 1
    type    = "host"
  }
  
  memory = var.memory_size
  
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = var.disk_size
          iothread = true
          discard = true
        }
      }
    }
    
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/${var.talos_image_name}"
        }
      }
    }
  }
  
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
    tag = 10
  }
 
  ipconfig0 = "ip=dhcp"

  boot = "order=scsi0;ide2"
  
  scsihw = "virtio-scsi-pci"
  
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}

