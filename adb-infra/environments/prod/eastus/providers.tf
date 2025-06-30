terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.52.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "azurerm" {
  subscription_id = "3be8fc2b-3d84-4501-a6c9-2973f712c20b"
  features {}
}

provider "databricks" {
  host = azurerm_databricks_workspace.example.workspace_url
}
