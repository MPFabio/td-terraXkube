resource "azurerm_resource_group" "kubeadm" {
   name = "kubeadm-fabio"
   location = var.location
}


resource "tls_private_key" "kubeadm" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "azurerm_linux_virtual_machine" "kubeadm" {
   count = 2
   size = var.instance_size
   name = "worker${count.index}"
   resource_group_name = azurerm_resource_group.kubeadm.name
   location = azurerm_resource_group.kubeadm.location
   network_interface_ids = [
    azurerm_network_interface.kubeadm["${count.index}"].id
   ]

   source_image_reference {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
   }

   computer_name = "Worker${count.index}"
   admin_username = "fabio"
   disable_password_authentication = true

   admin_ssh_key {
        username = "fabio"
        public_key = tls_private_key.kubeadm.public_key_openssh 
    }

   os_disk {
       name = "kubeadmdisk${count.index}"
       caching = "ReadWrite"
       #create_option = "FromImage"
       storage_account_type = "Standard_LRS"
   }
}

   resource "azurerm_linux_virtual_machine" "Manager" {
     name                  = "Manager"
     location              = azurerm_resource_group.Kubernetes.location
     resource_group_name   = azurerm_resource_group.Kubernetes.name
     size                  = "Standard_D2ds_v4"
     network_interface_ids = [
     azurerm_network_interface.kubeadm["${2}"].id
     ]

   source_image_reference {
     publisher = "Canonical"
     offer     = "0001-com-ubuntu-server-jammy"
     sku       = "22_04-lts-gen2"
     version   = "latest"
    }

   computer_name                   = "Manager"
   admin_username                  = "fabio"
   disable_password_authentication = true

   admin_ssh_key {
     username   = "fabio"
     public_key = tls_private_key.kubeadm.public_key_openssh
    }

    os_disk {
      name = "OSdisk"
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    depends_on = [azurerm_resource_group.kubeadm]
}
