resource "proxmox_virtual_environment_download_file" "ubuntu-24-04" {
  content_type          = "iso"
  datastore_id          = "local"
  file_name             = "ubuntu-24.04.2-live-server-amd64.iso"
  node_name             = var.pve_node
  url                   = var.ubuntu_image_url
  checksum              = var.ubuntu_image_checksum
  checksum_algorithm    = var.ubuntu_image_checksum_algorithm
  overwrite             = true
  overwrite_unmanaged   = true
}

resource "proxmox_virtual_environment_file" "user_config" {
  content_type  = "snippets"
  datastore_id  = "local"
  node_name     = var.pve_node

  source_raw {
    data        = file("cloud-init/user-config.yaml")
    file_name   = "user-config.yaml"
  }
}

resource "proxmox_virtual_environment_file" "vendor_config" {
  content_type  = "snippets"
  datastore_id  = "local"
  node_name     = var.pve_node

  source_raw {
    data        = file("cloud-init/vendor-config.yaml")
    file_name   = "vendor-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu-24-04" {
    depends_on          = [ 
        proxmox_virtual_environment_file.user_config,
        proxmox_virtual_environment_file.vendor_config 
    ]
    name                = "home-controller-01"
    description         = "Ubuntu 24.04  created with Terraform"
    tags                = ["terraform", "ubuntu"]
    node_name           = var.pve_node

    cpu {
        cores   = 2
    }
    memory {
        dedicated = 2048
        floating  = 2048
    }

    disk {
        datastore_id    = "local-lvm"
        file_id         = proxmox_virtual_environment_download_file.ubuntu-24-04.id
        interface       = "virtio0"
        iothread        = true
        discard         = "on"
        ssd             = true
    }
    network_device {
        bridge          = "vmbr0"
        model           = "virtio"
    }
    operating_system {
        type            = "l26"
    }
    agent {
        enabled         = true
    }
    initialization {
        # ou au lieu d'ip config utiliser network_data_file_id avec un fichier cloudinit
        ip_config {
            ipv4 {
                address     = "dhcp"
            }
        }
        # Link cloud-init yaml files
        user_data_file_id   = proxmox_virtual_environment_file.user_config.id
        vendor_data_file_id = proxmox_virtual_environment_file.vendor_config.id
    }
}

output "ubuntu-24-04_test_ip_address" {
    value = proxmox_virtual_environment_vm.ubuntu-24-04.ipv4_addresses
}
