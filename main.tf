resource "azurerm_resource_group" "kubeadm" {
   name = "kubeadm-fabio"
   location = var.location
}

resource "azurerm_network_interface_security_group_association" "nsgnic" {
  network_interface_id      = azurerm_network_interface.kubeadm.id
  network_security_group_id = azurerm_network_security_group.allowedports.id
}

resource "azurerm_network_security_group" "allowedports" {
   name = "allowedports${var.environment}"
   resource_group_name = azurerm_resource_group.kubeadm.name
   location = azurerm_resource_group.kubeadm.location
  
   security_rule {
       name = "http"
       priority = 100
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "80"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }

   security_rule {
       name = "https"
       priority = 200
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "443"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }

    security_rule {
       name = "custom"
       priority = 400
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "8080"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }
   
   security_rule {
       name = "ssh"
       priority = 300
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "22"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }
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

resource "azurerm_network_interface" "kubeadm" {
   name = "kubeadm-interface"
   location = azurerm_resource_group.kubeadm.location
   resource_group_name = azurerm_resource_group.kubeadm.name

   ip_configuration {
       name = "internal"
       private_ip_address_allocation = "Dynamic"
       subnet_id = azurerm_subnet.kubeadm-subnet.id
       public_ip_address_id = azurerm_public_ip.kubeadm_public_ip.id
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
       azurerm_network_interface.kubeadm.["${count.index}"].id,
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
     public_key = tls_private_key.SSH.public_key_openssh
    }

    os_disk {
      name = "OSdisk"
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    depends_on = [azurerm_resource_group.kubeadm]
}
