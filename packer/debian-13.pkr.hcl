packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "debian13" {
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  password                 = var.proxmox_password
  insecure_skip_tls_verify = var.insecure_skip_tls_verify
  node                     = var.proxmox_node

  vm_id                = var.vm_id
  vm_name              = var.vm_name
  template_description = "debian_13_golden"


  boot_iso  {
    type = "scsi"
    iso_file = "local:iso/debian-13.3.0-amd64-netinst.iso"
    unmount = true
    iso_checksum = "sha512:1ada40e4c938528dd8e6b9c88c19b978a0f8e2a6757b9cf634987012d37ec98503ebf3e05acbae9be4c0ec00b52e8852106de1bda93a2399d125facea45400f8"
  }

  memory    = 2048
  cores     = 2
  sockets   = 1
  cpu_type  = "host"
  os        = "l26"
  
  network_adapters {
    bridge = "vmbr1"
    model  = "virtio"
  }

  # Disques
  disks {
    type         = "scsi"
    disk_size    = "10G"
    storage_pool = var.storage_pool
    format       = "raw"
  }

  scsi_controller = "virtio-scsi-pci"

  # Cloud-Init
  cloud_init              = true
  cloud_init_storage_pool = var.storage_pool

  # Boot
  boot_wait = "5s"
 
  boot_command = [
    "<esc><wait>",
    "auto <wait>",
    "console-setup/ask_detect=false <wait>",
    "debconf/frontend=noninteractive <wait>",
    "debian-installer=en_US.UTF-8 <wait>",
    "locale=en_US.UTF-8 <wait>",
    "netcfg/disable_autoconfig=true <wait>",
    "netcfg/disable_dhcp=true <wait>",
    "netcfg/get_ipaddress=192.168.10.5 <wait>",
    "netcfg/get_netmask=255.255.255.248 <wait>",
    "netcfg/get_gateway=192.168.10.1 <wait>",
    "netcfg/get_nameservers=1.1.1.1 <wait>",
    "netcfg/confirm_static=true <wait>",
    "netcfg/get_hostname=debian <wait>",
    "netcfg/get_domain=localdomain <wait>",
    "preseed/url=http://192.168.10.1:8001/preseed.cfg <wait>",
    "<enter>"
  ]

  http_directory = "http"
  http_port_min  = 8001
  http_port_max  = 8001
  http_bind_address = "0.0.0.0"

  # SSH pour provisioning
  ssh_username         = "root"
  ssh_password         = var.ssh_password
  ssh_host             = "127.0.0.1"
  ssh_port             = 2222
  ssh_timeout          = "20m"
  ssh_handshake_attempts = 20
}

build {
  sources = ["source.proxmox-iso.debian13"]

  # Script de configuration
  provisioner "shell" {
    scripts = ["scripts/setup.sh"]
  }

  # Script de nettoyage
  provisioner "shell" {
    script = "scripts/cleanup.sh"
  }

  post-processor "shell-local" {
    inline = [
      "ssh root@152.228.222.18 'qm set ${var.vm_id} --template 1'"
    ]
  }
}
