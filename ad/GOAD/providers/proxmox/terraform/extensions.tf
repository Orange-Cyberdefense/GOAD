module "ws01" {
  source = "./extensions/ws01"
  pm_node        = var.pm_node
  pm_pool        = var.pm_pool
  network_bridge = var.network_bridge
  network_model  = var.network_model
  network_vlan   = var.network_vlan
  storage        = var.storage
  pm_full_clone  = var.pm_full_clone
  count = 1
}