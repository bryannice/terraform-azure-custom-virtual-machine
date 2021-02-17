terraform {
  required_version = "= 0.14.6"
}

provider "azurerm" {
  features {}
}

data "azurerm_image" "custom_image_info" {
  name = var.custom_image_name
  resource_group_name = var.custom_image_resource_group_name
}

data "null_data_source" "common_tags" {
  inputs = {
    application_name = var.application_name,
    cost_center = var.cost_center,
    department_name = var.department_name,
    delivery_team_name = var.delivery_team_name,
    pattern_name = var.pattern_name,
    resource_owner = var.resource_owner,
  }
}

resource "azurerm_resource_group" "az_rg" {
  location = var.location
  name = var.resource_group_name
  tags = merge(
    data.null_data_source.common_tags.outputs,
    map(
      "resource_type", "resource group"
    )
  )
}

resource "azurerm_virtual_network" "vnet" {
  address_space = split(",",var.vnet_address_space)
  location = azurerm_resource_group.az_rg.location
  name = var.vnet_name
  resource_group_name = azurerm_resource_group.az_rg.name
  tags = merge(
    data.null_data_source.common_tags.outputs,
    map(
      "resource_type", "virtual network"
    )
  )
}

resource "azurerm_subnet" "subnet" {
  name = var.subnet_name
  resource_group_name = azurerm_resource_group.az_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = split(",", var.subnet_address_prefixes)
}

resource "azurerm_public_ip" "public_ip" {
  allocation_method = var.allocation_method
  name = var.public_ip_name
  location = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  tags = merge(
    data.null_data_source.common_tags.outputs,
    map(
      "resource_type", "public ip"
    )
  )
}

resource "azurerm_network_security_group" "nsg" {
  location = azurerm_resource_group.az_rg.location
  name = var.nsg_name
  resource_group_name = azurerm_resource_group.az_rg.name
  security_rule {
    access                     = var.nsg_security_rule_access
    direction                  = var.nsg_security_rule_direction
    destination_address_prefix = var.nsg_security_rule_destination_address_prefix
    destination_port_range     = var.nsg_security_rule_destination_port_range
    name                       = var.nsg_security_rule_name
    priority                   = var.nsg_security_rule_priority
    protocol                   = var.nsg_security_rule_protocol
    source_address_prefix      = var.nsg_security_rule_source_address_prefix
    source_port_range          = "*"
  }
  tags = merge(
    data.null_data_source.common_tags.outputs,
    map(
      "resource_type", "network security group"
    )
  )
}

resource "azurerm_network_interface" "nic" {
  name = var.nic_name
  ip_configuration {
    name = var.nic_name
    private_ip_address_allocation = var.nic_private_ip_address_allocation
    subnet_id = azurerm_subnet.subnet.id
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
  location = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
}

resource "azurerm_network_interface_security_group_association" "nsga" {
  network_interface_id = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_virtual_machine" "az_vm" {
  name = var.az_vm_name
  location = azurerm_resource_group.az_rg.location
  network_interface_ids = [azurerm_network_interface.nic.id]
  os_profile {
    admin_username = var.az_vm_username
    admin_password = var.az_vm_password
    computer_name = var.az_vm_name
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  resource_group_name = azurerm_resource_group.az_rg.name
  storage_image_reference {
    id = data.azurerm_image.custom_image_info.id
  }
  storage_os_disk {
    create_option = var.storage_os_disk_create_option
    managed_disk_type = var.managed_disk_type
    name = var.az_vm_name
  }
  tags = merge(
      data.null_data_source.common_tags.outputs,
      map(
        "resource_type", "azure virtual machine"
      )
  )
  vm_size = var.az_vm_size
}