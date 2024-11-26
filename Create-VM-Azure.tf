# Define the provider
provider "azurerm" {
  features {}
}

# Resource group
resource "azurerm_resource_group" "rg" {
  name     = "rg-windows-server"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-windows-server"
  address_space       = ["172.18.10.0/24"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-windows-server"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.18.10.0/24"]
}

# Public IP Address
resource "azurerm_public_ip" "pip" {
  name                = "pip-windows-server"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "nic-windows-server"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig-windows-server"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Virtual Machine
resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "vm-windows-server"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B2s"
  admin_username        = "adminuser"
  admin_password        = "P@ssw0rd1234!"
  network_interface_ids = [azurerm_network_interface.nic.id]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    environment = "test"
  }
}