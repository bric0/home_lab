resource "proxmox_virtual_environment_download_file" "ubuntu_24_04" {
  content_type        = "iso"
  datastore_id        = "local"
  node_name           = var.pve_node
  url                 = var.ubuntu_image_url
  checksum            = var.ubuntu_image_checksum
  checksum_algorithm  = var.ubuntu_image_checksum_algorithm
  overwrite           = true
  overwrite_unmanaged = true
}

resource "proxmox_virtual_environment_file" "controller_01_user" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.pve_node

  source_raw {
    data      = file("cloud-init/controller-01-user.yaml")
    file_name = "controller-01-user.yaml"
  }
}

resource "proxmox_virtual_environment_file" "worker_01_user" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.pve_node

  source_raw {
    data      = file("cloud-init/worker-01-user.yaml")
    file_name = "worker-01-user.yaml"
  }
}

resource "proxmox_virtual_environment_file" "worker_02_user" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.pve_node

  source_raw {
    data      = file("cloud-init/worker-02-user.yaml")
    file_name = "worker-02-user.yaml"
  }
}

resource "proxmox_virtual_environment_file" "vendor_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.pve_node

  source_raw {
    data      = file("cloud-init/vendor-config.yaml")
    file_name = "vendor-config.yaml"
  }
}


resource "proxmox_virtual_environment_vm" "ubuntu_24_04_template" {
  depends_on = [
    proxmox_virtual_environment_file.controller_01_user,
    proxmox_virtual_environment_file.worker_01_user,
    proxmox_virtual_environment_file.worker_02_user,
    proxmox_virtual_environment_file.vendor_config,
  ]

  name        = "ubuntu-template"
  description = "Ubuntu 24.04  created with Terraform"
  tags        = ["terraform", "ubuntu"]
  node_name   = var.pve_node

  template = true

  cpu {
    cores = 4
  }
  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_24_04.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    ssd          = true
    size         = 40
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
    timeout = "5m"
  }
}

resource "proxmox_virtual_environment_vm" "home_controller_01" {
  name      = "home-controller-01"
  tags      = ["controller-01", "terraform", "ubuntu"]
  node_name = var.pve_node


  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_24_04_template.id
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    vendor_data_file_id = proxmox_virtual_environment_file.vendor_config.id
    user_data_file_id   = proxmox_virtual_environment_file.controller_01_user.id
  }
}

output "home_controller_01_test_ip_address" {
  value = proxmox_virtual_environment_vm.home_controller_01.ipv4_addresses[1][0]
}

resource "proxmox_virtual_environment_vm" "home_worker_01" {
  name      = "home-worker-01"
  tags      = ["worker-01", "terraform", "ubuntu"]
  node_name = var.pve_node

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_24_04_template.id
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    vendor_data_file_id = proxmox_virtual_environment_file.vendor_config.id
    user_data_file_id   = proxmox_virtual_environment_file.worker_01_user.id
  }
}

output "home_worker_01_test_ip_address" {
  value = proxmox_virtual_environment_vm.home_worker_01.ipv4_addresses[1][0]
}

resource "proxmox_virtual_environment_vm" "home_worker_02" {
  name      = "home-worker-02"
  tags      = ["worker-02", "terraform", "ubuntu"]
  node_name = var.pve_node

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_24_04_template.id
  }


  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    vendor_data_file_id = proxmox_virtual_environment_file.vendor_config.id
    user_data_file_id   = proxmox_virtual_environment_file.worker_02_user.id
  }
}

output "home_worker_02_test_test_ip_address" {
  value = proxmox_virtual_environment_vm.home_worker_02.ipv4_addresses[1][0]
}
