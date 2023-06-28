output "The_kubeadm_Private_ip" {
   value = azurerm_linux_virtual_machine.kubeadm.private_ip_address
}

output "The_kubeadm_Public_ip" {
   value = azurerm_linux_virtual_machine.kubeadm.public_ip_address
}

output "tls_private_key" {
  value = tls_private_key.kubeadm.private_key_pem
  sensitive = true
}

output "tls_public_key" {
  value     = tls_private_key.kubeadm.public_key_pem
  sensitive = true
}
