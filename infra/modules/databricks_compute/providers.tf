# Specify required providers
terraform {
    required_providers {
    databricks = {
    source = "databricks/databricks"
    }
  }
}

# Configure the Databricks provider
provider "databricks" {
  host = "https://adb-XXXXXX.azuredatabricks.net"
  token = "<PAT>"
}
