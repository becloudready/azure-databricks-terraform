terraform {
  backend "azurerm" {
    key = "infra-eastus.tfstate"
  }
}