terraform {
  backend "azurerm" {
    resource_group_name  = "databricks-demo"
    storage_account_name = "bcrterraformstatefiles1"
    container_name       = "tfstate"
    key                  = "infra/prod/terraform.tfstate"
  }
}
