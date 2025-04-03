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