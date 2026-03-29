module "homelab_firewall" {
  source = "./modules/vm-debian"

  pve_username = var.pve_username
  pve_password = var.pve_password
  pve_endpoint = var.pve_endpoint

  pve_node    = var.pve_node
  node_name   = "homelab-firewall-01"

  template_id = 9000
  cpu_number  = 2
  memory_size = 4096
  disk_size   = 10

  vm_ip       = "10.10.0.1/24"
  vm_password = var.vm_password

  ssh_keys    = [file("~/.ssh/ovh-homelab.pub")]

  additional_network = {
    bridge = "vmbr1"
    model  = "virtio"
  }
  additional_network_ip = "192.168.10.2/29"
  additional_gateway_ip = "192.168.10.1"
} 

module "homelab_dmz_01" {
  source = "./modules/vm-debian"

  pve_username = var.pve_username
  pve_password = var.pve_password
  pve_endpoint = var.pve_endpoint

  pve_node    = var.pve_node
  node_name   = "homelab-dmz-01"

  template_id = 9000
  cpu_number  = 2
  memory_size = 4096
  disk_size   = 15

  vm_ip       = "10.10.0.10/24"
  vm_gateway  = "10.10.0.1"
  vlan_id     = 10
  vm_password = var.vm_password
  vm_tags     = ["10-DMZ"]

  ssh_keys    = [file("~/.ssh/ovh-homelab.pub")]
}

module "homelab_admin_01" {
  source = "./modules/vm-debian"

  pve_username = var.pve_username
  pve_password = var.pve_password
  pve_endpoint = var.pve_endpoint

  pve_node    = var.pve_node
  node_name   = "homelab-admin-01"

  template_id = 9000
  cpu_number  = 2
  memory_size = 4096
  disk_size   = 10

  vm_ip       = "10.20.0.10/24"
  vm_gateway  = "10.20.0.1"
  vlan_id     = 20
  vm_password = var.vm_password
  vm_tags     = ["20-ADMIN"]

  ssh_keys    = [file("~/.ssh/ovh-homelab.pub")]
}

module "homelab_vpn_01" {
  source = "./modules/vm-debian"

  pve_username = var.pve_username
  pve_password = var.pve_password
  pve_endpoint = var.pve_endpoint

  pve_node    = var.pve_node
  node_name   = "homelab-vpn-01"

  template_id = 9000
  cpu_number  = 2
  memory_size = 4096
  disk_size   = 10

  vm_ip       = "10.30.0.10/24"
  vm_gateway  = "10.30.0.1"
  vlan_id     = 30
  vm_password = var.vm_password
  vm_tags     = ["30-INFRA"]

  ssh_keys    = [file("~/.ssh/ovh-homelab.pub")]
}

module "homelab_infra_01" {
  source = "./modules/vm-debian"

  pve_username = var.pve_username
  pve_password = var.pve_password
  pve_endpoint = var.pve_endpoint

  pve_node    = var.pve_node
  node_name   = "homelab-infra-01"

  template_id = 9000
  cpu_number  = 2
  memory_size = 4096
  disk_size   = 50

  vm_ip       = "10.30.0.20/24"
  vm_gateway  = "10.30.0.1"
  vlan_id     = 30
  vm_password = var.vm_password
  vm_tags     = ["30-INFRA"]

  ssh_keys    = [file("~/.ssh/ovh-homelab.pub")]
}

module "homelab_prod_01" {
  source = "./modules/vm-debian"

  pve_username = var.pve_username
  pve_password = var.pve_password
  pve_endpoint = var.pve_endpoint

  pve_node    = var.pve_node
  node_name   = "homelab-prod-01"

  template_id = 9000
  cpu_number  = 2
  memory_size = 4096
  disk_size   = 100

  vm_ip       = "10.40.0.10/16"
  vm_gateway  = "10.40.0.1"
  vlan_id     = 40
  vm_password = var.vm_password
  vm_tags     = ["40-PROD"]

  ssh_keys    = [file("~/.ssh/ovh-homelab.pub")]
}

module "homelab_prod_02" {
  source = "./modules/vm-debian"

  pve_username = var.pve_username
  pve_password = var.pve_password
  pve_endpoint = var.pve_endpoint

  pve_node    = var.pve_node
  node_name   = "homelab-prod-02"

  template_id = 9000
  cpu_number  = 2
  memory_size = 4096
  disk_size   = 10

  vm_ip       = "10.40.0.20/16"
  vm_gateway  = "10.40.0.1"
  vlan_id     = 40
  vm_password = var.vm_password
  vm_tags     = ["40-PROD"]

  ssh_keys    = [file("~/.ssh/ovh-homelab.pub")]
}

# module "talos_cp_01" {
#   source = "./modules/vm-talos"
# 
#   pve_username = var.pve_username
#   pve_password = var.pve_password
#   pve_endpoint = var.pve_endpoint
# 
#   pve_node  = var.pve_node
#   node_name = "talos-cp-01"
# 
#   cpu_number  = 2
#   memory_size = 4096
#   disk_size   = 30 
#   vlan_id     = 40
#   vm_tags     = ["40.prod"]
# 
#   talos_version          = var.talos_version
#   talos_image_name       = var.talos_image_name
# }
# 
# module "talos_worker_01" {
#   source = "./modules/vm-talos"
# 
#   pve_username = var.pve_username
#   pve_password = var.pve_password
#   pve_endpoint = var.pve_endpoint
# 
#   pve_node  = var.pve_node
#   node_name = "talos-worker-01"
# 
#   cpu_number  = 4
#   memory_size = 8192 
#   disk_size   = 30
#   vlan_id     = 40
#   vm_tags     = ["40.prod"]
# 
#   talos_version          = var.talos_version
#   talos_image_name       = var.talos_image_name
# }
  
