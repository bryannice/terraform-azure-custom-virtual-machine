# Terraform Azure Custom Virtual Machine

![](assets/terraform-icon.png)

## Terraform Environment

Execute the command below create an environment to interact with the Terraform Command Line Interface (Terraform CLI).

```makefile
make cli
```

## Make Targets to Provision (aka "create") or Deprovision (aka "destroy") an Azure Custom Virtual Machine

Below are the main make targets for provisioning and deprovisioning infrastructure. There are other make targets and to see them, open the makefile. Before executing make targets within the Terraform container, these environment variables must be set. Customize these variables based upon attributes specific to an Azure service principal. Be sure security is hardened for the Azure service principal to specific permissions.

| Environment Variable                                | Required | Default Value   | Description                                                                        |
| --------------------------------------------------- | ---------| --------------- | ---------------------------------------------------------------------------------- |
| TF_VAR_allocation_method                            | N        | Dynamic         | Defines the allocation method for this IP address.                                 |
| TF_VAR_application_name                             | Y        |                 | Tag name for capturing application name                                            |
| TF_VAR_az_vm_name                                   | Y        |                 | Specifies the name of the Virtual Machine.                                         |
| TF_VAR_az_vm_password                               | Y        |                 | The password associated with the local administrator account.                      |
| TF_VAR_az_vm_size                                   | N        | Standard_D4a_v4 | Specifies the size of the Virtual Machine.                                         |
| TF_VAR_az_vm_username                               | Y        |                 | Specifies the name of the local administrator account.                             |
| TF_VAR_cost_center                                  | N        |                 | Tag name for capturing cost center.                                                |
| TF_VAR_custom_image_name                            | Y        |                 | The name of the Image.                                                             |
| TF_VAR_custom_image_resource_group_name             | Y        |                 | The Name of the Resource Group where this Image exists.                            |
| TF_VAR_department_name                              | N        |                 | Tag name for capturing department name.                                            |
| TF_VAR_delivery_team_name                           | N        |                 | Tag name for capturing delivery team name.                                         |
| TF_VAR_location                                     | N        | West US 2       | The Azure Region where the Resource Group should exist.                            |
| TF_VAR_managed_disk_type                            | N        | Standard_LRS    | Specifies the type of managed disk to create.                                      |
| TF_VAR_nic_name                                     | Y        |                 | The name of the Network Interface.                                                 |
| TF_VAR_nic_private_ip_address_allocation            | N        | Dynamic         | The allocation method used for the Private IP Address.                             |
| TF_VAR_nsg_name                                     | Y        |                 | Specifies the name of the network security group.                                  |
| TF_VAR_nsg_security_rule_access                     | N        | Allow           | Specifies whether network traffic is allowed or denied.                            |
| TF_VAR_nsg_security_rule_direction                  | N        | Inbound         | The direction specifies if rule will be evaluated on incoming or outgoing traffic. |
| TF_VAR_nsg_security_rule_destination_address_prefix | N        | *               | CIDR or destination IP range or * to match any IP.                                 |
| TF_VAR_nsg_security_rule_destination_port_range     | N        | 22              | Destination Port or Range.                                                         |
| TF_VAR_nsg_security_rule_name                       | N        | SSH             | The name of the security rule.                                                     |
| TF_VAR_nsg_security_rule_priority                   | N        | 1001            | Specifies the priority of the rule.                                                |
| TF_VAR_nsg_security_rule_protocol                   | N        | TCP             | Network protocol this rule applies to.                                             |
| TF_VAR_nsg_security_rule_source_address_prefix      | N        | *               | List of source address prefixes.                                                   |
| TF_VAR_nsg_security_rule_source_port_range          | N        | *               | List of source ports or port ranges.                                               |
| TF_VAR_pattern_name                                 | N        |                 | Tag name for capturing infrastructure pattern name.                                |
| TF_VAR_public_ip_name                               | Y        |                 | The name of the Public IP.                                                         |
| TF_VAR_resource_owner                               | N        |                 | The Name which should be used for this Resource Group.                             |
| TF_VAR_resource_group_name                          | Y        |                 | Tag name for capturing resource owner.                                             |
| TF_VAR_storage_os_disk_create_option                | N        | FromImage       | Specifies how the data disk should be created.                                     |
| TF_VAR_subnet_address_prefixes                      | N        | 10.0.1.0/24     | The address prefixes to use for the subnet.                                        |
| TF_VAR_subnet_name                                  | Y        |                 | The name of the subnet.                                                            |
| TF_VAR_vnet_address_space                           | N        | 10.0.0.0/16     | The address space that is used the virtual network.                                |
| TF_VAR_vnet_name                                    | Y        |                 | The name of the virtual network.                                                   |

To create backend using a container to execute the following:

```bash
export TF_VAR_allocation_method=
export TF_VAR_application_name=
export TF_VAR_az_vm_name=
export TF_VAR_az_vm_password=
export TF_VAR_az_vm_size=
export TF_VAR_az_vm_username=
export TF_VAR_cost_center=
export TF_VAR_custom_image_name=
export TF_VAR_custom_image_resource_group_name=
export TF_VAR_department_name=
export TF_VAR_delivery_team_name=
export TF_VAR_location="''"
export TF_VAR_managed_disk_type=
export TF_VAR_nic_name=
export TF_VAR_nic_private_ip_address_allocation=
export TF_VAR_nsg_name=
export TF_VAR_nsg_security_rule_access=
export TF_VAR_nsg_security_rule_direction=
export TF_VAR_nsg_security_rule_destination_address_prefix=
export TF_VAR_nsg_security_rule_destination_port_range=
export TF_VAR_nsg_security_rule_name=
export TF_VAR_nsg_security_rule_priority=
export TF_VAR_nsg_security_rule_protocol=
export TF_VAR_nsg_security_rule_source_address_prefix=
export TF_VAR_nsg_security_rule_source_port_range=
export TF_VAR_pattern_name="''"
export TF_VAR_public_ip_name=
export TF_VAR_resource_owner="''"
export TF_VAR_resource_group_name=
export TF_VAR_storage_os_disk_create_option=
export TF_VAR_subnet_address_prefixes=""
export TF_VAR_subnet_name=
export TF_VAR_vnet_address_space=""
export TF_VAR_vnet_name=
make \
    BACKEND_RESOURCE_GROUP_NAME= \
    BACKEND_STORAGE_ACCOUNT_NAME= \
    provision
```

To destroy backend using a container to execute the following:

```bash
export TF_VAR_allocation_method=
export TF_VAR_application_name=
export TF_VAR_az_vm_name=
export TF_VAR_az_vm_password=
export TF_VAR_az_vm_size=
export TF_VAR_az_vm_username=
export TF_VAR_cost_center=
export TF_VAR_custom_image_name=
export TF_VAR_custom_image_resource_group_name=
export TF_VAR_department_name=
export TF_VAR_delivery_team_name=
export TF_VAR_location="''"
export TF_VAR_managed_disk_type=
export TF_VAR_nic_name=
export TF_VAR_nic_private_ip_address_allocation=
export TF_VAR_nsg_name=
export TF_VAR_nsg_security_rule_access=
export TF_VAR_nsg_security_rule_direction=
export TF_VAR_nsg_security_rule_destination_address_prefix=
export TF_VAR_nsg_security_rule_destination_port_range=
export TF_VAR_nsg_security_rule_name=
export TF_VAR_nsg_security_rule_priority=
export TF_VAR_nsg_security_rule_protocol=
export TF_VAR_nsg_security_rule_source_address_prefix=
export TF_VAR_nsg_security_rule_source_port_range=
export TF_VAR_pattern_name="''"
export TF_VAR_public_ip_name=
export TF_VAR_resource_owner="''"
export TF_VAR_resource_group_name=
export TF_VAR_storage_os_disk_create_option=
export TF_VAR_subnet_address_prefixes=""
export TF_VAR_subnet_name=
export TF_VAR_vnet_address_space=""
export TF_VAR_vnet_name=
make \
    BACKEND_RESOURCE_GROUP_NAME= \
    BACKEND_STORAGE_ACCOUNT_NAME= \
    deprovision
```

## License

[GPLv3](LICENSE)

## References

* [Markdownlint](https://dlaa.me/markdownlint/)
* [Azure virtual machine sizes naming conventions](https://docs.microsoft.com/en-us/azure/virtual-machines/vm-naming-conventions)
* [General purpose virtual machine sizes](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-general)
* [azurerm_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine)
* [Data Source: azurerm_image](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/image)
* [azurerm_network_interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface)
* [azurerm_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
* [azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)
* [azurerm_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)
* [azurerm_network_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)
* [azurerm_network_interface_security_group_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association)
* [Create a Linux VM with infrastructure in Azure using Terraform](https://docs.microsoft.com/en-us/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure)
