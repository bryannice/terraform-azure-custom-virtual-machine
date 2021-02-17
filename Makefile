# -----------------------------------------------------------------------------
# Terraform
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Internal Variables
# -----------------------------------------------------------------------------

BOLD :=$(shell tput bold)
RED :=$(shell tput setaf 1)
GREEN :=$(shell tput setaf 2)
YELLOW :=$(shell tput setaf 3)
RESET :=$(shell tput sgr0)

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------

ifdef_any_of = $(filter-out undefined,$(foreach v,$(1),$(origin $(v))))

# -----------------------------------------------------------------------------
# Checking If Required Environment Variables Were Set
# -----------------------------------------------------------------------------

TARGETS_TO_CHECK := "fetch-statefile tf-init tf-plan tf-destroy tf-apply tf-backend"
AZURE_CREDENTIAL_CONTEXT := $(shell [[ ! -d ".azure" ]] && echo 0 || echo 1)

ifeq ($(findstring $(MAKECMDGOALS),$(TARGETS_TO_CHECK)),$(MAKECMDGOALS))
$(info "$(YELLOW)$(GREEN)Checking required Azure credential context is set.$(RESET)")
ifeq ($(AZURE_CREDENTIAL_CONTEXT),0)
ifeq ($(call ifdef_any_of,TF_VAR_SUBSCRIPTION_ID,TF_VAR_TENANT_ID,TF_VAR_CLIENT_ID,TF_VAR_CLIENT_SECRET),)
$(info $(BOLD)$(RED)These required environment variables are not defined.$(RESET))
$(info $(BOLD)$(RED)TF_VAR_SUBSCRIPTION_ID$(RESET))
$(info $(BOLD)$(RED)TF_VAR_TENANT_ID$(RESET))
$(info $(BOLD)$(RED)TF_VAR_CLIENT_ID$(RESET))
$(info $(BOLD)$(RED)TF_VAR_CLIENT_SECRET$(RESET))
$(info $(BOLD)$(YELLOW)It is required to follow the az login instructions when these environment variables are not set.$(RESET))
$(shell $(shell az login) > /dev/null 2>&1 )
$(info "$(BOLD)$(GREEN)Completed az login process.$(RESET)")
endif
endif
$(info "$(BOLD)$(GREEN)Azure credential context verified.$(RESET)")
endif

# -----------------------------------------------------------------------------
# Git Variables
# -----------------------------------------------------------------------------

GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
GIT_REPOSITORY_NAME := $(shell git config --get remote.origin.url | rev | cut -d"." -f2 | cut -d"/" -f1 | rev )
GIT_ACCOUNT_NAME := $(shell git config --get remote.origin.url | rev | cut -d"." -f2 | cut -d"/" -f2 | cut -d":" -f1 | rev)
GIT_SHA := $(shell git log --pretty=format:'%H' -n 1)
GIT_TAG ?= $(shell git describe --always --tags | awk -F "-" '{print $$1}')
GIT_TAG_END ?= HEAD
GIT_VERSION := $(shell git describe --always --tags --long --dirty | sed -e 's/\-0//' -e 's/\-g.......//')
GIT_VERSION_LONG := $(shell git describe --always --tags --long --dirty)

# -----------------------------------------------------------------------------
# Docker Variables
# -----------------------------------------------------------------------------

DOCKER_IMAGE_NAME ?= bryannice/alpine-terraform-azure:1.3.0

# -----------------------------------------------------------------------------
# Terraform Variables
# -----------------------------------------------------------------------------
backend_resource_group_name ?= $(BACKEND_RESOURCE_GROUP_NAME)
backend_storage_account_name ?= $(subst -,,$(subst _,,$(BACKEND_STORAGE_ACCOUNT_NAME)))
backend_storage_container_name ?= terraform-state-files

SUBSCRIPTION_ID := $(ifndef SUBSCRIPTION_ID,"","subscription_id = \"$(SUBSCRIPTION_ID)\"" endif)
TENANT_ID := $(ifndef TENANT_ID,"","tenant_id = \"$(TENANT_ID)\"" endif)
CLIENT_ID := $(ifndef CLIENT_ID,"","client_id = \"$(CLIENT_ID)\"" endif)
CLIENT_SECRET := $(ifndef CLIENT_SECRET,"","client_secret = \"$(CLIENT_SECRET)\"" endif)
RESOURCE_GROUP_NAME := "resource_group_name = \"$(backend_resource_group_name)\""
STORAGE_ACCOUNT_NAME := "storage_account_name = \"$(backend_storage_account_name)\""
SAS_TOKEN := $(ifndef TF_VAR_SAS_TOKEN,"","sas_token = \"$(TF_VAR_SAS_TOKEN)\"" endif)
ACCESS_KEY := $(ifndef TF_VAR_ACCESS_KEY,"","access_key = \"$(TF_VAR_ACCESS_KEY)\"" endif)
CONTAINER_NAME := "container_name = \"$(backend_storage_container_name)\""
KEY := "key = \"$(GIT_REPOSITORY_NAME)/$(TF_VAR_resource_group_name).tfstate\""

# -----------------------------------------------------------------------------
# Terraform Targets
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
.PHONY: clean
clean:
	@echo "$(BOLD)$(YELLOW)Cleaning up working directory.$(RESET)"
	@rm -rf beconf.tfvarse
	@rm -rf beconf.tfvars
	@rm -rf .terraform
	@rm -rf .terraform.d
	@rm -rf *.tfstate
	@rm -rf crash.log
	@rm -rf backend.tf
	@rm -rf *.tfstate.backup
	@rm -rf .azure
	@rm -rf .terraform.lock.hcl
	@rm -rf .bash_history
	@echo "$(BOLD)$(GREEN)Completed cleaning up working directory.$(RESET)"

.PHONY: cli
cli:
	@docker run \
		-it \
		--rm \
		-v $(PWD):/root/terraform \
		$(DOCKER_IMAGE_NAME) \
		bash

.PHONY: fmt
fmt:
	@echo "$(BOLD)$(YELLOW)Formatting terraform files.$(RESET)"
	@terraform fmt
	@echo "$(BOLD)$(GREEN)Completed formatting files.$(RESET)"

.PHONY: set-azure-backend
set-azure-backend:
	@echo "$(BOLD)$(YELLOW)Creating backend.tf with azurerm configuration.$(RESET)"
	@export BACKEND_TYPE=azurerm; \
    export SUBSCRIPTION_ID=$(SUBSCRIPTION_ID); \
    export TENANT_ID=$(SUBSCRIPTION_ID); \
    export CLIENT_ID=$(CLIENT_ID); \
    export CLIENT_SECRET=$(CLIENT_SECRET); \
    export RESOURCE_GROUP_NAME=$(RESOURCE_GROUP_NAME); \
    export STORAGE_ACCOUNT_NAME=$(STORAGE_ACCOUNT_NAME); \
    export SAS_TOKEN=$(SAS_TOKEN); \
    export ACCESS_KEY=$(ACCESS_KEY); \
    export CONTAINER_NAME=$(CONTAINER_NAME); \
    export KEY=$(KEY); \
	envsubst < templates/template.backend.tf > backend.tf
	@echo "$(BOLD)$(GREEN)Completed generating backend.tf.$(RESET)"

.PHONY: init
init:
	@echo "$(BOLD)$(YELLOW)Initializing terraform project.$(RESET)"
	@terraform init \
		-input=false \
		-upgrade
	@echo "$(BOLD)$(GREEN)Completed initialization.$(RESET)"

.PHONY: plan
plan:
	@echo "$(BOLD)$(YELLOW)Create terraform plan.$(RESET)"
	@sleep 10
	@terraform plan \
		-input=false \
		-refresh=true
	@echo "$(BOLD)$(GREEN)Completed plan generation.$(RESET)"

.PHONY: destroy
destroy: set-azure-backend init plan
	@echo "$(BOLD)$(YELLOW)Destroying infrastructure in Azure.$(RESET)"
	@sleep 10
	@terraform destroy \
		-auto-approve \
		-input=false \
		-refresh=true
	@echo "$(BOLD)$(GREEN)Completed infrastructure destroy.$(RESET)"

.PHONY: apply
apply: set-azure-backend init plan
	@echo "$(BOLD)$(YELLOW)Creating landing zone infrastructure in Azure.$(RESET)"
	@sleep 10
	@terraform apply \
		-input=false \
    	-auto-approve
	@echo "$(BOLD)$(GREEN)Completed creating landing zone infrastructure.$(RESET)"

.PHONY: provision
provision:
	@echo "$(BOLD)$(YELLOW)Instantiate terraform container.$(RESET)"
	@docker run \
		-it \
		--rm \
		-v $(PWD):/home/terraform \
		--env SUBSCRIPTION_ID=$(SUBSCRIPTION_ID) \
		--env TENANT_ID=$(SUBSCRIPTION_ID) \
		--env CLIENT_ID=$(CLIENT_ID) \
		--env CLIENT_SECRET=$(CLIENT_SECRET) \
		--env RESOURCE_GROUP_NAME=$(RESOURCE_GROUP_NAME) \
		--env STORAGE_ACCOUNT_NAME=$(STORAGE_ACCOUNT_NAME) \
		--env SAS_TOKEN=$(SAS_TOKEN) \
		--env ACCESS_KEY=$(ACCESS_KEY) \
		--env CONTAINER_NAME=$(CONTAINER_NAME) \
		--env KEY=$(KEY) \
		--env BACKEND_RESOURCE_GROUP_NAME=$(BACKEND_RESOURCE_GROUP_NAME) \
		--env BACKEND_STORAGE_ACCOUNT_NAME=$(BACKEND_STORAGE_ACCOUNT_NAME) \
		--env TF_VAR_allocation_method=$(TF_VAR_allocation_method) \
		--env TF_VAR_application_name=$(TF_VAR_application_name) \
		--env TF_VAR_az_vm_name=$(TF_VAR_az_vm_name) \
		--env TF_VAR_az_vm_password=$(TF_VAR_az_vm_password) \
		--env TF_VAR_az_vm_size=$(TF_VAR_az_vm_size) \
		--env TF_VAR_az_vm_username=$(TF_VAR_az_vm_username) \
		--env TF_VAR_cost_center=$(TF_VAR_cost_center) \
		--env TF_VAR_custom_image_name=$(TF_VAR_custom_image_name) \
		--env TF_VAR_custom_image_resource_group_name=$(TF_VAR_custom_image_resource_group_name) \
		--env TF_VAR_department_name=$(TF_VAR_department_name) \
		--env TF_VAR_delivery_team_name=$(TF_VAR_delivery_team_name) \
		--env TF_VAR_location=$(TF_VAR_location) \
		--env TF_VAR_managed_disk_type=$(TF_VAR_managed_disk_type) \
		--env TF_VAR_nic_name=$(TF_VAR_nic_name) \
		--env TF_VAR_nic_private_ip_address_allocation=$(TF_VAR_nic_private_ip_address_allocation) \
		--env TF_VAR_nsg_name=$(TF_VAR_nsg_name) \
		--env TF_VAR_nsg_security_rule_access=$(TF_VAR_nsg_security_rule_access) \
		--env TF_VAR_nsg_security_rule_direction=$(TF_VAR_nsg_security_rule_direction) \
		--env TF_VAR_nsg_security_rule_destination_address_prefix=$(TF_VAR_nsg_security_rule_destination_address_prefix) \
		--env TF_VAR_nsg_security_rule_destination_port_range=$(TF_VAR_nsg_security_rule_destination_port_range) \
		--env TF_VAR_nsg_security_rule_name=$(TF_VAR_nsg_security_rule_name) \
		--env TF_VAR_nsg_security_rule_priority=$(TF_VAR_nsg_security_rule_priority) \
		--env TF_VAR_nsg_security_rule_protocol=$(TF_VAR_nsg_security_rule_protocol) \
		--env TF_VAR_nsg_security_rule_source_address_prefix=$(TF_VAR_nsg_security_rule_source_address_prefix) \
		--env TF_VAR_nsg_security_rule_source_port_range=$(TF_VAR_nsg_security_rule_source_port_range) \
		--env TF_VAR_pattern_name=$(TF_VAR_pattern_name) \
		--env TF_VAR_public_ip_name=$(TF_VAR_public_ip_name) \
		--env TF_VAR_resource_owner=$(TF_VAR_resource_owner) \
		--env TF_VAR_resource_group_name=$(TF_VAR_resource_group_name) \
		--env TF_VAR_storage_os_disk_create_option=$(TF_VAR_storage_os_disk_create_option) \
		--env TF_VAR_subnet_address_prefixes=$(TF_VAR_subnet_address_prefixes) \
		--env TF_VAR_subnet_name=$(TF_VAR_subnet_name) \
		--env TF_VAR_vnet_address_space=$(TF_VAR_vnet_address_space) \
		--env TF_VAR_vnet_name=$(TF_VAR_vnet_name) \
		$(DOCKER_IMAGE_NAME) \
		make apply
	@echo "$(BOLD)$(GREEN)Completed provisioning process.$(RESET)"

.PHONY: deprovision
deprovision:
	@echo "$(BOLD)$(YELLOW)Instantiate terraform container.$(RESET)"
	@docker run \
		-it \
		--rm \
		-v $(PWD):/home/terraform \
		--env SUBSCRIPTION_ID=$(SUBSCRIPTION_ID) \
		--env TENANT_ID=$(SUBSCRIPTION_ID) \
		--env CLIENT_ID=$(CLIENT_ID) \
		--env CLIENT_SECRET=$(CLIENT_SECRET) \
		--env RESOURCE_GROUP_NAME=$(RESOURCE_GROUP_NAME) \
		--env STORAGE_ACCOUNT_NAME=$(STORAGE_ACCOUNT_NAME) \
		--env SAS_TOKEN=$(SAS_TOKEN) \
		--env ACCESS_KEY=$(ACCESS_KEY) \
		--env CONTAINER_NAME=$(CONTAINER_NAME) \
		--env KEY=$(KEY) \
		--env BACKEND_RESOURCE_GROUP_NAME=$(BACKEND_RESOURCE_GROUP_NAME) \
		--env BACKEND_STORAGE_ACCOUNT_NAME=$(BACKEND_STORAGE_ACCOUNT_NAME) \
		--env TF_VAR_allocation_method=$(TF_VAR_allocation_method) \
		--env TF_VAR_application_name=$(TF_VAR_application_name) \
		--env TF_VAR_az_vm_name=$(TF_VAR_az_vm_name) \
		--env TF_VAR_az_vm_password=$(TF_VAR_az_vm_password) \
		--env TF_VAR_az_vm_size=$(TF_VAR_az_vm_size) \
		--env TF_VAR_az_vm_username=$(TF_VAR_az_vm_username) \
		--env TF_VAR_cost_center=$(TF_VAR_cost_center) \
		--env TF_VAR_custom_image_name=$(TF_VAR_custom_image_name) \
		--env TF_VAR_custom_image_resource_group_name=$(TF_VAR_custom_image_resource_group_name) \
		--env TF_VAR_department_name=$(TF_VAR_department_name) \
		--env TF_VAR_delivery_team_name=$(TF_VAR_delivery_team_name) \
		--env TF_VAR_location=$(TF_VAR_location) \
		--env TF_VAR_managed_disk_type=$(TF_VAR_managed_disk_type) \
		--env TF_VAR_nic_name=$(TF_VAR_nic_name) \
		--env TF_VAR_nic_private_ip_address_allocation=$(TF_VAR_nic_private_ip_address_allocation) \
		--env TF_VAR_nsg_name=$(TF_VAR_nsg_name) \
		--env TF_VAR_nsg_security_rule_access=$(TF_VAR_nsg_security_rule_access) \
		--env TF_VAR_nsg_security_rule_direction=$(TF_VAR_nsg_security_rule_direction) \
		--env TF_VAR_nsg_security_rule_destination_address_prefix=$(TF_VAR_nsg_security_rule_destination_address_prefix) \
		--env TF_VAR_nsg_security_rule_destination_port_range=$(TF_VAR_nsg_security_rule_destination_port_range) \
		--env TF_VAR_nsg_security_rule_name=$(TF_VAR_nsg_security_rule_name) \
		--env TF_VAR_nsg_security_rule_priority=$(TF_VAR_nsg_security_rule_priority) \
		--env TF_VAR_nsg_security_rule_protocol=$(TF_VAR_nsg_security_rule_protocol) \
		--env TF_VAR_nsg_security_rule_source_address_prefix=$(TF_VAR_nsg_security_rule_source_address_prefix) \
		--env TF_VAR_nsg_security_rule_source_port_range=$(TF_VAR_nsg_security_rule_source_port_range) \
		--env TF_VAR_pattern_name=$(TF_VAR_pattern_name) \
		--env TF_VAR_public_ip_name=$(TF_VAR_public_ip_name) \
		--env TF_VAR_resource_owner=$(TF_VAR_resource_owner) \
		--env TF_VAR_resource_group_name=$(TF_VAR_resource_group_name) \
		--env TF_VAR_storage_os_disk_create_option=$(TF_VAR_storage_os_disk_create_option) \
		--env TF_VAR_subnet_address_prefixes=$(TF_VAR_subnet_address_prefixes) \
		--env TF_VAR_subnet_name=$(TF_VAR_subnet_name) \
		--env TF_VAR_vnet_address_space=$(TF_VAR_vnet_address_space) \
		--env TF_VAR_vnet_name=$(TF_VAR_vnet_name) \
		$(DOCKER_IMAGE_NAME) \
		make destroy
	@echo "$(BOLD)$(GREEN)Completed deprovisioning process.$(RESET)"
