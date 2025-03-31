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
  default     = "mvpops-production-rg-test"
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "swedencentral"
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = "devops@example.com"
} 