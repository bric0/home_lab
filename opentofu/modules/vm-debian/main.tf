resource "proxmox_virtual_environment_vm" "debian_clone" {
  name        = var.node_name
  description = "Debian created with OpenTofu"
  node_name   = var.pve_node

  timeout_create      = 600
  timeout_clone       = 600
  timeout_start_vm    = 600
  timeout_shutdown_vm = 300

  # Clone depuis template
  clone {
    vm_id = var.template_id
    full  = true
  }

  scsi_hardware = "virtio-scsi-single"

  # Agent
  agent {
    enabled = true
  }

  # CPU
  cpu {
    cores   = var.cpu_number
    sockets = 1
    type    = "host"
  }

  # Memory
  memory {
    dedicated = var.memory_size 
  }

  # Interface réseau principale
  network_device {
    bridge  = "vmbr2"
    model   = "virtio"
    vlan_id = var.vlan_id
  }

  # Interface réseau additionnelle (optionnelle)
  dynamic "network_device" {
    for_each = var.additional_network != null ? [var.additional_network] : []
    content {
      bridge  = network_device.value.bridge
      model   = network_device.value.model
      vlan_id = network_device.value.tag
    }
  }

  # Disque
  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = var.disk_size
    discard      = "on"
    iothread     = true
    ssd          = true
    cache        = "writethrough"
  }

  initialization {
    interface = "ide0"

    datastore_id = "local-lvm"

    user_account {
      username = var.vm_username
      keys     = var.ssh_keys
      password = var.vm_password
    }

    ip_config {
      ipv4 {
        address = var.vm_ip    
        gateway = var.vm_gateway  
      }
    }

    dynamic "ip_config" {
      for_each = var.additional_network_ip != null ? [1] : []
      content {
        ipv4 {
          address = var.additional_network_ip
          gateway = var.additional_gateway_ip
        }
      }
    }

    dns {
      servers = ["1.1.1.1", "8.8.8.8"]
    }
  }

  tags = var.vm_tags
}
