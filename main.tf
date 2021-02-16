terraform {
  required_version = "= 0.12.20"
}

provider "" {
  features {}
}

data "null_data_source" "common_tags" {
  inputs = {
    infrastructure = var.infrastructure
  }
}

module "modules-0-0-0" {
  source = ""
}
