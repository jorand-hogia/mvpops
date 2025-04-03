output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.monitor_workspace.id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.monitor_workspace.name
}

output "action_group_id" {
  description = "The ID of the Monitor Action Group."
  value       = azurerm_monitor_action_group.main.id
}

# Add outputs for DCRs/DCEs later if needed 