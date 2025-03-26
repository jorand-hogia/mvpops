# MVP DevOps Platform - Main Infrastructure

# Create a resource group for the platform
resource "azurerm_resource_group" "platform" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# Create a storage account for platform artifacts
resource "azurerm_storage_account" "artifacts" {
  name                     = "${var.prefix}artifacts${var.environment}"
  resource_group_name      = azurerm_resource_group.platform.name
  location                 = azurerm_resource_group.platform.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  
  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }
  
  tags = local.common_tags
}

# Create Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "${var.prefix}acr${var.environment}"
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  sku                 = "Premium"
  admin_enabled       = false
  
  tags = local.common_tags
}

# Create Key Vault for secrets management
resource "azurerm_key_vault" "platform" {
  name                        = "${var.prefix}-kv-${var.environment}"
  location                    = azurerm_resource_group.platform.location
  resource_group_name         = azurerm_resource_group.platform.name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  
  tags = local.common_tags
}

# Create Log Analytics workspace for monitoring
resource "azurerm_log_analytics_workspace" "platform" {
  name                = "${var.prefix}-law-${var.environment}"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  tags = local.common_tags
}

# Create Azure Monitor Action Group for alerts
resource "azurerm_monitor_action_group" "platform" {
  name                = "${var.prefix}-ag-${var.environment}"
  resource_group_name = azurerm_resource_group.platform.name
  short_name          = "mvpopsalert"
  
  email_receiver {
    name                    = "DevOps Team"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }
  
  tags = local.common_tags
} 