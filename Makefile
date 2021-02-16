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

DOCKER_IMAGE_NAME ?= bryannice/terraform-azure:1.2.0

# -----------------------------------------------------------------------------
# Terraform Variables
# -----------------------------------------------------------------------------

ifdef SUBSCRIPTION_OWNER
resource_group_name := $(if strlen($(subst -,,$(subst _,,$(SUBSCRIPTION_OWNER)-backend)))>25,$(shell echo ${SUBSCRIPTION_OWNER} | head -c 13)-backend,$(SUBSCRIPTION_OWNER)-backend)
else
resource_group_name := $(GIT_REPOSITORY_NAME)
endif

.EXPORT_ALL_VARIABLES:
TF_VAR_location ?= West US 2
TF_VAR_resource_group_name := $(resource_group_name)
TF_VAR_storage_account_name := $(subst -,,$(subst _,,$(TF_VAR_resource_group_name)))
TF_VAR_storage_container_names := terraform-state-files

SUBSCRIPTION_ID := $(ifndef SUBSCRIPTION_ID,"","subscription_id = \"$(SUBSCRIPTION_ID)\"" endif)
TENANT_ID := $(ifndef TENANT_ID,"","tenant_id = \"$(TENANT_ID)\"" endif)
CLIENT_ID := $(ifndef CLIENT_ID,"","client_id = \"$(CLIENT_ID)\"" endif)
CLIENT_SECRET := $(ifndef CLIENT_SECRET,"","client_secret = \"$(CLIENT_SECRET)\"" endif)
RESOURCE_GROUP_NAME := "resource_group_name = \"$(TF_VAR_resource_group_name)\""
STORAGE_ACCOUNT_NAME := "storage_account_name = \"$(TF_VAR_storage_account_name)\""
SAS_TOKEN := $(ifndef TF_VAR_SAS_TOKEN,"","sas_token = \"$(TF_VAR_SAS_TOKEN)\"" endif)
ACCESS_KEY := $(ifndef TF_VAR_ACCESS_KEY,"","access_key = \"$(TF_VAR_ACCESS_KEY)\"" endif)
CONTAINER_NAME := "container_name = \"$(TF_VAR_storage_container_names)\""
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
		$(DOCKER_IMAGE) \
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
		--env AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		--env AWS_DEFAULT_OUTPUT=$(AWS_DEFAULT_OUTPUT) \
		--env AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
		--env AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		--env S3_BUCKET_NAME=$(S3_BUCKET_NAME) \
		$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) \
		make backend
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
		$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) \
		make destroy
	@echo "$(BOLD)$(GREEN)Completed deprovisioning process.$(RESET)"
