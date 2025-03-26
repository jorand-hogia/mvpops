variable "prefix" {
  description = "The prefix to use for all resources"
  type        = string
  default     = "mvpops"
}

variable "environment" {
  description = "The environment (prod, dev, etc.)"
  type        = string
  default     = "production"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "mvpops-production-rg"
}

variable "location" {
  description = "The Azure region to deploy to"
  type        = string
  default     = "eastus2"
}

variable "tenant_id" {
  description = "The Azure AD tenant ID"
  type        = string
}

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = "devops@example.com"
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = "MVPDevOps"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
  }
} 