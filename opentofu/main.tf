module "talos_cp_01" {
  source = "./modules/vm-talos"

  pve_username = var.pve_username
  pve_password = var.pve_password
  pve_endpoint = var.pve_endpoint

  pve_node  = var.pve_node
  node_name = "talos-cp-01"

  cpu_number  = 2
  memory_size = 4096
  disk_size   = 30 

  talos_version          = var.talos_version
  talos_image_name       = var.talos_image_name
}

module "talos_worker_01" {
  source = "./modules/vm-talos"

  pve_username = var.pve_username
  pve_password = var.pve_password
  pve_endpoint = var.pve_endpoint

  pve_node  = var.pve_node
  node_name = "talos-worker-01"

  cpu_number  = 4
  memory_size = 8192 
  disk_size   = 30

  talos_version          = var.talos_version
  talos_image_name       = var.talos_image_name
}

