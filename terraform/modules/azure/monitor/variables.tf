variable "resource_group_name" {
  description = "The name of the resource group where Azure Monitor resources will be deployed."
  type        = string
}

variable "location" {
  description = "The Azure region where Azure Monitor resources will be deployed."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the Azure Monitor resources."
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace_name" {
  description = "The name for the Log Analytics Workspace."
  type        = string
}

variable "log_analytics_sku" {
  description = "The SKU (pricing tier) for the Log Analytics Workspace (e.g., PerGB2018, Free, Standard, Premium, etc.)."
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "The retention period in days for logs in the Log Analytics Workspace."
  type        = number
  default     = 30
}

variable "enable_vm_insights" {
  description = "Set to true to enable the VMInsights solution on the Log Analytics Workspace."
  type        = bool
  default     = true
}

variable "action_group_name" {
  description = "The name for the Monitor Action Group."
  type        = string
}

variable "action_group_short_name" {
  description = "The short name for the Monitor Action Group (max 12 characters)."
  type        = string
}

variable "email_receivers" {
  description = "A map of email receivers for alerts. Key is the receiver name, value is the email address."
  type        = map(string)
  default     = {}
  # Example: { "admins" = "ops-admins@example.com" }
}

# Add variables for other receiver types (webhook, sms, etc.) as needed
# Add variables for Data Collection Rule configuration later

variable "base_name" {
  description = "Base name prefix for resources created by the module (e.g., dcr name)."
  type        = string
} 