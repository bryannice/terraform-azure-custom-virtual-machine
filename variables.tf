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
  default = "Premium_LRS"
  description = "Specifies the type of managed disk to create. Possible values are either Standard_LRS, StandardSSD_LRS, Premium_LRS or UltraSSD_LRS."
  type = string
}

variable "nic_name" {
  default     = ""
  description = "The name of the Network Interface."
  type        = string
}

variable "pattern_name" {
  default     = ""
  description = "Tag name for capturing infrastructure pattern name."
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

variable "storage_data_disk_disk_size_db" {
  default = "75"
  description = "Specifies the size of the data disk in gigabytes."
  type = string
}

variable "storage_data_disk_lun" {
  default     = "0"
  description = "Specifies the logical unit number of the data disk. This needs to be unique within all the Data Disks on the Virtual Machine."
  type        = string
}

variable "storage_os_disk_create_option" {
  default     = "FromImage"
  description = "Specifies how the data disk should be created. Possible values are Attach, FromImage and Empty."
  type        = string
}

variable "subnet_address_prefixes" {
  default     = ["10.0.1.0/24"]
  description = "The address prefixes to use for the subnet."
  type        = list
}

variable "subnet_name" {
  default     = ""
  description = "The name of the subnet."
  type        = string
}

variable "vnet_address_space" {
  default     = ["10.0.0.0/16"]
  description = "The address space that is used the virtual network."
  type        = list
}

variable "vnet_name" {
  default     = ""
  description = "The name of the virtual network."
  type        = string
}
