resource "azurerm_network_interface_security_group_association" "nsgnic" {
  network_interface_id      = azurerm_network_interface.kubeadm.id
  network_security_group_id = azurerm_network_security_group.allowedports.id
}

resource "azurerm_network_security_group" "allowedports" {
   name = "allowedports"
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
   count = 3
   name = "kubeadm_public_ip${count.index}"
   location = var.location
   resource_group_name = azurerm_resource_group.kubeadm.name
   allocation_method = "Dynamic"

   depends_on = [azurerm_resource_group.kubeadm]
}

resource "azurerm_virtual_network" "kubeadm-net" {
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.kubeadm.location
  resource_group_name = azurerm_resource_group.kubeadm.name
}

resource "azurerm_subnet" "kubeadm-subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.kubeadm.name
  virtual_network_name = azurerm_virtual_network.kubeadm-net.name
  address_prefixes       = ["10.0.0.0/24"]

  private_link_service_network_policies_enabled = false
}

resource "azurerm_network_interface" "kubeadm" {
   count = 3
   name = "kubeadm-interface-${count.index}"
   location = azurerm_resource_group.kubeadm.location
   resource_group_name = azurerm_resource_group.kubeadm.name
}

  ip_configuration {
     name                          = "Internal"
     subnet_id                     = azurerm_subnet.kubeadm.id
     private_ip_address_allocation = "Dynamic"
     public_ip_address_id          = azurerm_public_ip.kubeadm["${count.index}"].id
   }

   depends_on = [azurerm_resource_group.kubeadm]
}

