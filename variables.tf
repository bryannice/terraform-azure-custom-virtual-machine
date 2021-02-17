variable "allocation_method" {
  default = "Dynamic"
  description = "Defines the allocation method for this IP address. Possible values are Static or Dynamic"
  type = string
}

variable "application_name" {
  default     = ""
  description = "Tag name for capturing application name."
  type        = string
}

variable "az_vm_name" {
  default     = ""
  description = "Specifies the name of the Virtual Machine."
  type        = string
}

variable "az_vm_password" {
  default     = ""
  description = "The password associated with the local administrator account."
  sensitive = true
  type        = string
}

variable "az_vm_size" {
  default     = "Standard_D4a_v4"
  description = "Specifies the size of the Virtual Machine."
  type        = string
}

variable "az_vm_username" {
  default     = ""
  description = "Specifies the name of the local administrator account."
  sensitive = true
  type        = string
}

variable "cost_center" {
  default     = ""
  description = "Tag name for capturing cost center."
  type        = string
}

variable "custom_image_name" {
  default     = ""
  description = "The name of the Image."
  type        = string
}

variable "custom_image_resource_group_name" {
  default     = ""
  description = "The Name of the Resource Group where this Image exists."
  type        = string
}

variable "department_name" {
  default     = ""
  description = "Tag name for capturing department name."
  type        = string
}

variable "delivery_team_name" {
  default     = ""
  description = "Tag name for capturing delivery team name."
  type        = string
}

variable "location" {
  default     = "West US 2"
  description = "The Azure Region where the Resource Group should exist."
  type        = string
}

variable "managed_disk_type" {
  default = "Standard_LRS"
  description = "Specifies the type of managed disk to create. Possible values are either Standard_LRS, StandardSSD_LRS, Premium_LRS or UltraSSD_LRS."
  type = string
}

variable "nic_name" {
  default     = ""
  description = "The name of the Network Interface."
  type        = string
}

variable "nic_private_ip_address_allocation" {
  default     = "Dynamic"
  description = "The allocation method used for the Private IP Address. Possible values are Dynamic and Static."
  type        = string
}

variable "nsg_name" {
  default     = ""
  description = "Specifies the name of the network security group."
  type        = string
}

variable "nsg_security_rule_access" {
  default     = "Allow"
  description = "Specifies whether network traffic is allowed or denied. Possible values are Allow and Deny."
  type        = string
}

variable "nsg_security_rule_direction" {
  default     = "Inbound"
  description = "The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are Inbound and Outbound."
  type        = string
}

variable "nsg_security_rule_destination_address_prefix" {
  default     = "*"
  description = "CIDR or destination IP range or * to match any IP. Tags such as ‘VirtualNetwork’, ‘AzureLoadBalancer’ and ‘Internet’ can also be used. This is required if destination_address_prefixes is not specified."
  type        = string
}

variable "nsg_security_rule_destination_port_range" {
  default     = "22"
  description = "Destination Port or Range. Integer or range between 0 and 65535 or * to match any. This is required if destination_port_ranges is not specified."
  type        = string
}

variable "nsg_security_rule_name" {
  default     = "SSH"
  description = "The name of the security rule."
  type        = string
}

variable "nsg_security_rule_priority" {
  default     = "1001"
  description = "Specifies the priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule."
  type        = string
}

variable "nsg_security_rule_protocol" {
  default     = "Tcp"
  description = "Network protocol this rule applies to. Can be Tcp, Udp, Icmp, or * to match all."
  type        = string
}

variable "nsg_security_rule_source_address_prefix" {
  default     = "*"
  description = "List of source address prefixes. Tags may not be used. This is required if source_address_prefix is not specified."
  type        = string
}

variable "nsg_security_rule_source_port_range" {
  default     = "*"
  description = "List of source ports or port ranges. This is required if source_port_range is not specified."
  type        = string
}

variable "pattern_name" {
  default     = ""
  description = "Tag name for capturing infrastructure pattern name."
  type        = string
}

variable "public_ip_name" {
  default     = ""
  description = "The name of the Public IP."
  type        = string
}

variable "resource_group_name" {
  default     = ""
  description = "The Name which should be used for this Resource Group."
  type        = string
}

variable "resource_owner" {
  default     = ""
  description = "Tag name for capturing resource owner."
  type        = string
}

variable "storage_os_disk_create_option" {
  default     = "FromImage"
  description = "Specifies how the data disk should be created. Possible values are Attach, FromImage and Empty."
  type        = string
}

variable "subnet_address_prefixes" {
  default     = "10.0.1.0/24"
  description = "The address prefixes to use for the subnet."
  type        = string
}

variable "subnet_name" {
  default     = ""
  description = "The name of the subnet."
  type        = string
}

variable "vnet_address_space" {
  default     = "10.0.0.0/16"
  description = "The address space that is used the virtual network."
  type        = string
}

variable "vnet_name" {
  default     = ""
  description = "The name of the virtual network."
  type        = string
}
