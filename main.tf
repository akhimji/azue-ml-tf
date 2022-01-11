# Azure provide configuration
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
      backend "azurerm" {
        resource_group_name  = "data-analytics-rg"
        storage_account_name = "porchlighttfstate"
        container_name       = "porchlightmachinelearning"
        key                  = "terraform.tfstate"
    }

}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}
