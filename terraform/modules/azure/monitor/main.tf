# Core Azure Monitor Resources

# Log Analytics Workspace (Central logging - also see LOG-01)
resource "azurerm_log_analytics_workspace" "monitor_workspace" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_in_days

  tags = var.tags
}

# Optional: Enable VMInsights Solution
resource "azurerm_log_analytics_solution" "vminsights" {
  count = var.enable_vm_insights ? 1 : 0

  solution_name         = "VMInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.monitor_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.monitor_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/VMInsights"
  }

  tags = var.tags
}

# Action Group (For Alerts - see ALERT-04)
resource "azurerm_monitor_action_group" "main" {
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_short_name

  # Example Email Receiver (add other types like webhook, sms etc. via variables)
  dynamic "email_receiver" {
    for_each = var.email_receivers
    content {
      name          = email_receiver.key
      email_address = email_receiver.value
    }
  }

  tags = var.tags
}

# Data Collection Rule (DCR) - For configuring Azure Monitor Agent (AMA)
# Required for VM Performance Metrics (INFRA-03) and Logs (LOG-02)
# Placeholder - Configuration depends on specific metrics/logs needed
# resource "azurerm_monitor_data_collection_rule" "vm_dcr" { ... }
# resource "azurerm_monitor_data_collection_endpoint" "vm_dce" { ... }

# Data Collection Rule for standard VM performance metrics
resource "azurerm_monitor_data_collection_rule" "vm_performance_dcr" {
  name                = "${var.base_name}-vm-perf-dcr"
  resource_group_name = var.resource_group_name
  location            = var.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.monitor_workspace.id
      name                  = "la-${azurerm_log_analytics_workspace.monitor_workspace.name}"
    }
  }

  data_sources {
    performance_counter {
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Memory\\Available MBytes",
        "\\Processor Information(_Total)\\% Processor Time",
        "\\LogicalDisk(*)\\*",
        "\\Network Interface(*)\\*"
      ]
      name = "perfCounterDataSource"
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = ["la-${azurerm_log_analytics_workspace.monitor_workspace.name}"]
  }

  description = "Data collection rule for VM performance metrics"
  tags        = var.tags
}

# Activity Log Alert for VM Resource Health (Unavailable)
resource "azurerm_monitor_activity_log_alert" "vm_health_alert" {
  name                = "${var.base_name}-vm-unavailable-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.target_resource_group_id] # Scope to the VM resource group
  description         = "Alert when a VM in the target resource group becomes unavailable based on Resource Health."

  criteria {
    category       = "ResourceHealth"
    # status         = "Active" # Optional: Can filter by alert status if needed
    # level          = "Error" # Removed: Invalid for ResourceHealth category
    # You might need to refine criteria based on exact event properties observed in Activity Log
    # resource_type = "Microsoft.Compute/virtualMachines" # Optional: Be more specific
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
} 