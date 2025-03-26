terraform {
  backend "azurerm" {
    # These values will be filled in by CI/CD pipeline
    # If running locally, use:
    # terraform init -backend-config=backend.conf
  }
} 