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

# Define resource group for VMs
resource "azurerm_resource_group" "vm_rg" {
  name     = "JP-test"
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
  source              = "../../modules/azure/vm"
  count               = var.cicd_agent_vm_count
  vm_name             = "cicd-agent-${count.index + 1}"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  vm_size             = "Standard_B2ms"
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
  source              = "../../modules/azure/vm"
  count               = var.monitoring_vm_count
  vm_name             = "monitoring-${count.index + 1}"
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
      role = "monitoring"
    }
  )
}

# Create Management VM
module "management_vm" {
  source              = "../../modules/azure/vm"
  count               = var.management_vm_count
  vm_name             = "mgmt-${count.index + 1}"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  vm_size             = "Standard_B1ms"
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

# Configure Azure Security Center (Defender for Cloud)
module "security_center" {
  source = "../../modules/azure/security"

  defender_plans_to_enable = {
    "VirtualMachines" = { tier = "Standard" }
    "StorageAccounts" = { tier = "Standard" }
    "KeyVaults"       = { tier = "Standard" }
    # Add other plans as needed based on project requirements
  }
}

# Configure Azure Monitor (Log Analytics, Action Group, etc.)
module "monitor" {
  source = "../../modules/azure/monitor"

  resource_group_name = azurerm_resource_group.vm_rg.name # Deploy in the same RG as VMs
  location            = azurerm_resource_group.vm_rg.location
  tags                = var.tags
  base_name           = "mvpops-${var.environment}" # Base name for DCR, etc.
  target_resource_group_id = azurerm_resource_group.vm_rg.id # Pass the VM RG ID for health alert scope

  log_analytics_workspace_name = "mvpops-${var.environment}-law"
  action_group_name            = "mvpops-${var.environment}-ag"
  action_group_short_name      = "mvpops-prod" # Shortened name (max 12 chars)

  # Example email receiver - customize or provide via variables
  email_receivers = {
    "PlatformTeam" = "jorgen.andersson@hogia.se" # Replace with actual email
  }

  # Keep VM Insights enabled (default in module)
  # enable_vm_insights = true 
}

# Associate VMs with the Data Collection Rule
resource "azurerm_monitor_data_collection_rule_association" "cicd_agent_dcr_assoc" {
  count                = var.cicd_agent_vm_count
  name                 = "${module.cicd_agent_vm[count.index].vm_name}-perf-dcr-assoc"
  target_resource_id   = module.cicd_agent_vm[count.index].vm_id
  data_collection_rule_id = module.monitor.data_collection_rule_id
  description          = "Associate CI/CD Agent VM with Performance DCR"
}

resource "azurerm_monitor_data_collection_rule_association" "monitoring_vm_dcr_assoc" {
  count                = var.monitoring_vm_count
  name                 = "${module.monitoring_vm[count.index].vm_name}-perf-dcr-assoc"
  target_resource_id   = module.monitoring_vm[count.index].vm_id
  data_collection_rule_id = module.monitor.data_collection_rule_id
  description          = "Associate Monitoring VM with Performance DCR"
}

resource "azurerm_monitor_data_collection_rule_association" "management_vm_dcr_assoc" {
  count                = var.management_vm_count
  name                 = "${module.management_vm[count.index].vm_name}-perf-dcr-assoc"
  target_resource_id   = module.management_vm[count.index].vm_id
  data_collection_rule_id = module.monitor.data_collection_rule_id
  description          = "Associate Management VM with Performance DCR"
}

# Assign 'Monitoring Metrics Publisher' role to VM Managed Identities
resource "azurerm_role_assignment" "cicd_vm_monitoring_publisher" {
  count                = var.cicd_agent_vm_count
  scope                = module.cicd_agent_vm[count.index].vm_id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = module.cicd_agent_vm[count.index].identity_principal_id # Get principal ID from VM module output
}

resource "azurerm_role_assignment" "monitoring_vm_monitoring_publisher" {
  count                = var.monitoring_vm_count
  scope                = module.monitoring_vm[count.index].vm_id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = module.monitoring_vm[count.index].identity_principal_id
}

resource "azurerm_role_assignment" "management_vm_monitoring_publisher" {
  count                = var.management_vm_count
  scope                = module.management_vm[count.index].vm_id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = module.management_vm[count.index].identity_principal_id
} 