resource "azurerm_resource_group" "kubeadm" {
   name = "kubeadm-fabio"
   location = var.location
}


resource "azurerm_public_ip" "kubeadm_public_ip" {
   name = "kubeadm_public_ip${var.environment}"
   location = var.location
   resource_group_name = azurerm_resource_group.kubeadm.name
   allocation_method = "Dynamic"

   tags = {
       environment = var.environment
       costcenter = "it"
   }

   depends_on = [azurerm_resource_group.kubeadm]
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
   custom_data = base64encode(file("../kubeadm/init-script.sh"))
   network_interface_ids = [
       azurerm_network_interface.kubeadm.["${count.index}"].id
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

   depends_on = [azurerm_resource_group.kubeadm]
}

   resource "azurerm_linux_virtual_machine" "Manager" {
     name                  = "Manager"
     location              = azurerm_resource_group.Kubernetes.location
     resource_group_name   = azurerm_resource_group.Kubernetes.name
     size                  = "Standard_D2ds_v4"
     network_interface_ids = [
     azurerm_network_interface.test["${2}"].id
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
