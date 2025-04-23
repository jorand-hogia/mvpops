variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
}

variable "log_analytics_workspace_sku" {
  description = "SKU of the Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

variable "metric_retention_in_days" {
  description = "Number of days to retain metrics"
  type        = number
  default     = 30
}

variable "ops_team_email" {
  description = "Email address for the ops team to receive alerts"
  type        = string
}

variable "vm_resource_ids" {
  description = "List of VM resource IDs to monitor"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
} 