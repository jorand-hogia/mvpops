output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "log_analytics_workspace_key" {
  description = "Primary shared key for the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}

output "log_analytics_workspace_guid" {
  description = "The workspace (customer) ID for the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.workspace_id
}

output "critical_action_group_id" {
  description = "ID of the critical alert action group"
  value       = azurerm_monitor_action_group.critical.id
}

output "warning_action_group_id" {
  description = "ID of the warning alert action group"
  value       = azurerm_monitor_action_group.warning.id
}

output "data_collection_rule_id" {
  description = "ID of the data collection rule"
  value       = azurerm_monitor_data_collection_rule.vm.id
} 