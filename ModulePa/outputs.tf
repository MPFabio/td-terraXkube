output "Ressource_group_name" {
  value = module.ModulePa.azurerm_resource_group
}

output "The_subnet_ID" {
 value = module.ModulePa.The_subnet_ID
}

output "The_vnet_ID" {
 value = module.ModulePa.The_vnet_ID
}

output "The_kubeadm_Private_ip" {
   value = module.ModulePa.The_kubeadm_Private_ip
}

output "The_kubeadm_Public_ip" {
   value = module.ModulePa.The_kubeadm_Public_ip
}

output "tls_private_key" {
  value = module.ModulePa.tls_private_key
  sensitive = true
}

output "tls_public_key" {
  value     = module.ModulePa.tls_public_key
  sensitive = true
}
