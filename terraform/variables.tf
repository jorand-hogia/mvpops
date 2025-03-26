variable "prefix" {
  description = "Prefix to use for resource names"
  type        = string
  default     = "mvpops"
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
  default     = "prod"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "mvpops-production-rg"
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "eastus2"
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = "devops@example.com"
} 