terraform {
  backend "azurerm" {
    key = "infra-westus.tfstate"
  }
}