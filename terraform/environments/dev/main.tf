terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

# Example resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "swedencentral"
  
  tags = {
    team = "mvpops"
  }
} 