terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstatedevopsmvp"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Define resource group for VMs
resource "azurerm_resource_group" "vm_rg" {
  name     = "mvpops-production-rg-test"
  location = var.location
  tags     = var.tags
}

# Create a virtual network for VMs
resource "azurerm_virtual_network" "vm_vnet" {
  name                = "devops-mvp-prod-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
  tags                = var.tags
}

# Create a subnet for VMs
resource "azurerm_subnet" "vm_subnet" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.vm_rg.name
  virtual_network_name = azurerm_virtual_network.vm_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a storage account for boot diagnostics
resource "azurerm_storage_account" "boot_diagnostics" {
  name                     = "bootdiagdevopsprod"
  resource_group_name      = azurerm_resource_group.vm_rg.name
  location                 = azurerm_resource_group.vm_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# Create CI/CD Agent VM
module "cicd_agent_vm" {
  source              = "../../modules/azure-vm"
  count               = var.cicd_agent_vm_count
  vm_name             = "cicd-agent-${count.index + 1}"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  vm_size             = "Standard_D4s_v3"
  os_type             = "linux"
  subnet_id           = azurerm_subnet.vm_subnet.id
  public_ip           = false
  admin_username      = var.vm_admin_username
  ssh_public_key      = var.vm_ssh_public_key
  
  source_image = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  
  boot_diagnostics_storage_uri = azurerm_storage_account.boot_diagnostics.primary_blob_endpoint
  enable_monitoring            = true
  
  tags = merge(
    var.tags,
    {
      role = "cicd-agent"
    }
  )
}

# Create Monitoring VM
module "monitoring_vm" {
  source              = "../../modules/azure-vm"
  count               = var.monitoring_vm_count
  vm_name             = "monitoring-${count.index + 1}"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  vm_size             = "Standard_E4s_v3"
  os_type             = "linux"
  subnet_id           = azurerm_subnet.vm_subnet.id
  public_ip           = true
  admin_username      = var.vm_admin_username
  ssh_public_key      = var.vm_ssh_public_key
  
  source_image = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  
  boot_diagnostics_storage_uri = azurerm_storage_account.boot_diagnostics.primary_blob_endpoint
  enable_monitoring            = true
  
  tags = merge(
    var.tags,
    {
      role = "monitoring"
    }
  )
}

# Create Management VM
module "management_vm" {
  source              = "../../modules/azure-vm"
  count               = var.management_vm_count
  vm_name             = "mgmt-${count.index + 1}"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  vm_size             = "Standard_B2ms"
  os_type             = "linux"
  subnet_id           = azurerm_subnet.vm_subnet.id
  public_ip           = true
  admin_username      = var.vm_admin_username
  ssh_public_key      = var.vm_ssh_public_key
  
  source_image = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  
  boot_diagnostics_storage_uri = azurerm_storage_account.boot_diagnostics.primary_blob_endpoint
  enable_monitoring            = true
  
  tags = merge(
    var.tags,
    {
      role = "management"
    }
  )
} 