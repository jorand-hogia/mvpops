output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.platform.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.platform.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.artifacts.name
}

output "acr_name" {
  description = "The name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "The login server URL for the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.platform.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.platform.vault_uri
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.platform.id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.platform.name
} 