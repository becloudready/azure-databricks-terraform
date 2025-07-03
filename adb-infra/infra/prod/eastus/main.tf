variable "region" {
  type = string
}

variable "resource_group_name" {
  type = string
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

data "azurerm_client_config" "current" {}

data "external" "me" {
  program = ["az", "account", "show", "--query", "user"]
}

locals {
  prefix = "databricksdemo${random_string.naming.result}"
  tags = {
    Environment = "prod"
    Owner       = lookup(data.external.me.result, "name", "unknown")
  }
}


# 👉 Use the network module
module "network" {
  source              = "../../../modules/network"
  resource_group_name = var.resource_group_name
  location            = var.region
  prefix              = local.prefix
  tags                = local.tags
}

# 👉 Use the databricks_workspace module
module "adb_workspace" {
  source                          = "../../../modules/databricks_workspace"
  workspace_name                  = "${local.prefix}-workspace"
  resource_group_name             = var.resource_group_name
  region                          = var.region
  managed_resource_group_name     = "${local.prefix}-managed-rg"
  vnet_id                         = module.network.vnet_id
  public_subnet_name              = module.network.public_subnet_name
  private_subnet_name             = module.network.private_subnet_name
  public_nsg_assoc_id             = module.network.public_nsg_assoc_id
  private_nsg_assoc_id            = module.network.private_nsg_assoc_id
  tags                            = local.tags
}

module "nightly_serverless_job" {
  source = "../../../modules/databricks_jobs"
  notebook_file_path = "${path.module}/../../notebooks/nightly_forecast_job.py"
}


output "databricks_host" {
  value = "https://${module.adb_workspace.workspace_url}/"
}
