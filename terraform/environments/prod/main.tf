terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  # Original backend configuration
  backend "azurerm" {}
  # Temporarily using local backend for testing
  # backend "local" {}
}

provider "azurerm" {
  features {}
}

locals {
  environment = "prod"
  location    = "swedencentral"
  tags = {
    Environment = local.environment
    ManagedBy   = "Terraform"
    Project     = "DevOps MVP"
  }
}

# Resource Group for Monitoring
resource "azurerm_resource_group" "monitoring" {
  name     = "rg-monitoring-${local.environment}"
  location = local.location
  tags     = local.tags
}

# Monitoring Module
module "monitoring" {
  source = "../../modules/azure/monitoring"

  environment                  = local.environment
  location                    = local.location
  resource_group_name         = azurerm_resource_group.monitoring.name
  log_analytics_workspace_name = "log-mvp-${local.environment}"
  ops_team_email             = var.ops_team_email
  vm_resource_ids            = var.vm_resource_ids
  tags                       = local.tags
}

# Resource Group for VMs
resource "azurerm_resource_group" "vms" {
  name     = "rg-vms-${local.environment}"
  location = local.location
  tags     = local.tags
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "nsg-vms-${local.environment}"
  location            = local.location
  resource_group_name = azurerm_resource_group.vms.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "22"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }

  tags = local.tags
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = azurerm_resource_group.vms.name
  tags               = local.tags
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = "snet-vms-${local.environment}"
  resource_group_name  = azurerm_resource_group.vms.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Public IPs for VMs
resource "azurerm_public_ip" "vm" {
  count               = length(var.vm_configs)
  name                = "pip-${var.vm_configs[count.index].name}-${local.environment}"
  location            = local.location
  resource_group_name = azurerm_resource_group.vms.name
  allocation_method   = "Static"
  sku                = "Standard"
  tags               = local.tags
}

# Network Interfaces for VMs
resource "azurerm_network_interface" "vm" {
  count               = length(var.vm_configs)
  name                = "nic-${var.vm_configs[count.index].name}-${local.environment}"
  location            = local.location
  resource_group_name = azurerm_resource_group.vms.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id         = azurerm_public_ip.vm[count.index].id
  }

  tags = local.tags
}

# Virtual Machines
resource "azurerm_linux_virtual_machine" "vm" {
  count               = length(var.vm_configs)
  name                = var.vm_configs[count.index].name
  resource_group_name = azurerm_resource_group.vms.name
  location            = local.location
  size                = var.vm_configs[count.index].size
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.vm[count.index].id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.vm_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = merge(local.tags, {
    Role = var.vm_configs[count.index].role
  })
}

# VM Extension for Log Analytics Agent
resource "azurerm_virtual_machine_extension" "log_analytics" {
  count                = length(var.vm_configs)
  name                 = "LogAnalytics"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm[count.index].id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "OmsAgentForLinux"
  type_handler_version = "1.13"

  settings = jsonencode({
    workspaceId = module.monitoring.log_analytics_workspace_id
  })

  protected_settings = jsonencode({
    workspaceKey = module.monitoring.log_analytics_workspace_key
  })

  tags = local.tags
}

# Create dedicated Network Watcher in the App RG
resource "azurerm_network_watcher" "app_rg_watcher" {
  name                = "${azurerm_resource_group.vms.name}-networkwatcher"
  location            = azurerm_resource_group.vms.location
  resource_group_name = azurerm_resource_group.vms.name

  tags = var.tags
}

# Enable NSG Flow Logs
resource "azurerm_network_watcher_flow_log" "vm_subnet_nsg_flowlog" {
  # Use the Network Watcher created within the App RG
  network_watcher_name = azurerm_network_watcher.app_rg_watcher.name
  resource_group_name  = azurerm_resource_group.vms.name
  
  name                       = "${azurerm_network_security_group.main.name}-flowlog"
  network_security_group_id  = azurerm_network_security_group.main.id
  storage_account_id         = azurerm_storage_account.nsg_flow_logs.id
  enabled                    = true
  retention_policy {
    enabled = true
    days    = 7
  }

  # Configure Flow Log version and Traffic Analytics (optional)
  version = 2
  traffic_analytics {
    enabled               = true
    workspace_id          = module.monitoring.log_analytics_workspace_guid # Send to our LA Workspace (Use GUID)
    workspace_region      = azurerm_resource_group.vms.location
    workspace_resource_id = module.monitoring.log_analytics_workspace_id # Keep full ID here
    interval_in_minutes   = 10 # Frequency for processing logs
  }
  
  tags = var.tags
}

# Create a storage account for boot diagnostics
resource "azurerm_storage_account" "boot_diagnostics" {
  name                     = "bootdiagdevopsprod"
  resource_group_name      = azurerm_resource_group.vms.name
  location                 = azurerm_resource_group.vms.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# Create Storage Account for NSG Flow Logs
resource "azurerm_storage_account" "nsg_flow_logs" {
  name                     = "stnsgflowlogs${var.environment}" # Needs global uniqueness
  resource_group_name      = azurerm_resource_group.vms.name # Store in same RG for simplicity
  location                 = azurerm_resource_group.vms.location
  account_tier             = "Standard"
  account_replication_type = "LRS" # LRS is usually sufficient
  account_kind             = "StorageV2"

  tags = var.tags
}

# Create CI/CD Agent VM
module "cicd_agent_vm" {
  source              = "../../modules/azure/vm"
  count               = var.cicd_agent_vm_count
  vm_name             = "cicd-agent-${count.index + 1}"
  resource_group_name = azurerm_resource_group.vms.name
  location            = azurerm_resource_group.vms.location
  vm_size             = "Standard_B2ms"
  os_type             = "linux"
  subnet_id           = azurerm_subnet.main.id
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
  resource_group_name = azurerm_resource_group.vms.name
  location            = azurerm_resource_group.vms.location
  vm_size             = "Standard_B2ms"
  os_type             = "linux"
  subnet_id           = azurerm_subnet.main.id
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
  resource_group_name = azurerm_resource_group.vms.name
  location            = azurerm_resource_group.vms.location
  vm_size             = "Standard_B1ms"
  os_type             = "linux"
  subnet_id           = azurerm_subnet.main.id
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

  resource_group_name = azurerm_resource_group.vms.name # Deploy in the same RG as VMs
  location            = azurerm_resource_group.vms.location
  tags                = var.tags
  base_name           = "mvpops-${var.environment}" # Base name for DCR, etc.
  target_resource_group_id = azurerm_resource_group.vms.id # Pass the VM RG ID for health alert scope

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
# Removed due to pipeline identity lacking Microsoft.Authorization/roleAssignments/write permissions
# resource "azurerm_role_assignment" "cicd_vm_monitoring_publisher" {
#   count                = var.cicd_agent_vm_count
#   scope                = module.cicd_agent_vm[count.index].vm_id
#   role_definition_name = "Monitoring Metrics Publisher"
#   principal_id         = module.cicd_agent_vm[count.index].identity_principal_id # Get principal ID from VM module output
# }
# 
# resource "azurerm_role_assignment" "monitoring_vm_monitoring_publisher" {
#   count                = var.monitoring_vm_count
#   scope                = module.monitoring_vm[count.index].vm_id
#   role_definition_name = "Monitoring Metrics Publisher"
#   principal_id         = module.monitoring_vm[count.index].identity_principal_id
# }
# 
# resource "azurerm_role_assignment" "management_vm_monitoring_publisher" {
#   count                = var.management_vm_count
#   scope                = module.management_vm[count.index].vm_id
#   role_definition_name = "Monitoring Metrics Publisher"
#   principal_id         = module.management_vm[count.index].identity_principal_id
# }

# Configure Network Connection Monitor
# Temporarily commented out due to inconsistent validation errors in provider v3.117.1
# resource "azurerm_network_connection_monitor" "main" {
#   name                 = "mvpops-${var.environment}-connection-monitor"
#   network_watcher_id   = data.azurerm_network_watcher.main.id
#   location             = azurerm_resource_group.vms.location # Must match Network Watcher location
#   # Removed output block - Linkage to LA is implicit or via Network Watcher
#   
#   endpoint {
#     name               = "cicdAgent1"
#     resource_id        = module.cicd_agent_vm[0].vm_id # Use resource_id (again...)
#   }
# 
#   endpoint {
#     name               = "managementVm1"
#     resource_id        = module.management_vm[0].vm_id # Use resource_id (again...)
#   }
#   
#   endpoint {
#     name    = "googleHttp"
#     address = "google.com"
#   }
# 
#   test_configuration {
#     name                = "sshInternalTest"
#     protocol            = "Tcp"
#     test_frequency_in_seconds = 60 # Check every minute
#     tcp_configuration {
#       port = 22
#     }
#   }
#   
#   test_configuration {
#     name                      = "httpExternalTest"
#     protocol                  = "Http"
#     test_frequency_in_seconds = 300 # Check every 5 minutes
#     http_configuration {
#       port               = 80
#       method             = "GET"
#       path               = "/"
#       prefer_https       = false # Test plain HTTP
#       request_header {
#         name  = "User-Agent"
#         value = "TerraformConnectionMonitor"
#       }
#       valid_status_code_ranges = ["200-299", "300-399"] # Accept redirects
#     }
#   }
# 
#   test_group {
#     name                     = "internalSshConnectivity"
#     test_configuration_names = ["sshInternalTest"]
#     source_endpoints         = ["cicdAgent1"] # Use plural (This was correct)
#     destination_endpoints    = ["managementVm1"] # Use plural (This was correct)
#   }
#   
#   test_group {
#     name                       = "externalHttpConnectivity"
#     test_configuration_names   = ["httpExternalTest"]
#     source_endpoints           = ["managementVm1"] # Use plural (This was correct)
#     destination_endpoints      = ["googleHttp"] # Use plural (This was correct)
#   }
#   
#   tags = var.tags
# } 