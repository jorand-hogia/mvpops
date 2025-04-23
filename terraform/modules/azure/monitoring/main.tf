terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                = var.log_analytics_workspace_sku
  retention_in_days  = var.log_retention_in_days

  tags = merge(var.tags, {
    Environment = var.environment
    Service     = "Monitoring"
  })
}

resource "azurerm_monitor_action_group" "critical" {
  name                = "${var.environment}-critical-alert-group"
  resource_group_name = var.resource_group_name
  short_name         = "p1-critical"

  email_receiver {
    name                    = "ops-team"
    email_address          = var.ops_team_email
    use_common_alert_schema = true
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Service     = "Monitoring"
    Priority    = "P1"
  })
}

resource "azurerm_monitor_action_group" "warning" {
  name                = "${var.environment}-warning-alert-group"
  resource_group_name = var.resource_group_name
  short_name         = "p2-warning"

  email_receiver {
    name                    = "ops-team"
    email_address          = var.ops_team_email
    use_common_alert_schema = true
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Service     = "Monitoring"
    Priority    = "P2"
  })
}

# VM CPU Alert
resource "azurerm_monitor_metric_alert" "vm_cpu" {
  name                = "${var.environment}-vm-high-cpu-alert"
  resource_group_name = var.resource_group_name
  scopes             = var.vm_resource_ids
  description        = "Alert when CPU usage is greater than 80% for 5 minutes"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  window_size        = "PT5M"
  frequency         = "PT1M"
  severity          = 2
  action {
    action_group_id = azurerm_monitor_action_group.warning.id
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Service     = "Monitoring"
    AlertType   = "Performance"
  })
}

# VM Memory Alert
resource "azurerm_monitor_metric_alert" "vm_memory" {
  name                = "${var.environment}-vm-high-memory-alert"
  resource_group_name = var.resource_group_name
  scopes             = var.vm_resource_ids
  description        = "Alert when available memory is less than 20% for 5 minutes"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 20
  }

  window_size        = "PT5M"
  frequency         = "PT1M"
  severity          = 2
  action {
    action_group_id = azurerm_monitor_action_group.warning.id
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Service     = "Monitoring"
    AlertType   = "Performance"
  })
}

# VM Availability Alert
resource "azurerm_monitor_metric_alert" "vm_availability" {
  name                = "${var.environment}-vm-availability-alert"
  resource_group_name = var.resource_group_name
  scopes             = var.vm_resource_ids
  description        = "Alert when VM becomes unavailable"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "VmAvailabilityMetric"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100
  }

  window_size        = "PT5M"
  frequency         = "PT1M"
  severity          = 1
  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Service     = "Monitoring"
    AlertType   = "Availability"
  })
}

# Diagnostic Settings for VMs
resource "azurerm_monitor_diagnostic_setting" "vm" {
  count                      = length(var.vm_resource_ids)
  name                       = "vm-diagnostics-${count.index}"
  target_resource_id        = var.vm_resource_ids[count.index]
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.metric_retention_in_days
    }
  }
}

# Azure Monitor Data Collection Rule
resource "azurerm_monitor_data_collection_rule" "vm" {
  name                = "${var.environment}-vm-data-collection"
  resource_group_name = var.resource_group_name
  location            = var.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.main.id
      name                 = "vm-performance-logs"
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["vm-performance-logs"]
  }

  data_sources {
    performance_counter {
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers           = [
        "\\Processor(_Total)\\% Processor Time",
        "\\Memory\\Available Bytes",
        "\\LogicalDisk(_Total)\\Free Megabytes",
        "\\Network Interface(_Total)\\Bytes Total/sec"
      ]
      name                         = "perfCounterDataSource"
    }
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Service     = "Monitoring"
  })
} 