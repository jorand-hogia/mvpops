terraform {
  backend "azurerm" {
    # These values are passed via command line or environment variables
    # resource_group_name  = "mvpops-production-rg"
    # storage_account_name = "mvpopsstorageaccount"
    # container_name       = "tfstate"
    # key                  = "terraform.tfstate"
  }
} 