variable "location" {
  description = "The Azure location where all resources will be created"
  type        = string
  default     = "swedencentral"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "resource_group_name" {
  description = "Name of the resource group for infrastructure"
  type        = string
  default     = "mvpops-production-rg"
}

variable "state_resource_group_name" {
  description = "Name of the resource group for Terraform state"
  type        = string
  default     = "tf-state-rg-mvpops"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "DevOps-MVP"
    ManagedBy   = "Terraform"
    Team        = "Platform"
  }
}

variable "cicd_agent_vm_count" {
  description = "Number of CI/CD agent VMs to create"
  type        = number
  default     = 2
}

variable "monitoring_vm_count" {
  description = "Number of monitoring VMs to create"
  type        = number
  default     = 1
}

variable "management_vm_count" {
  description = "Number of management VMs to create"
  type        = number
  default     = 1
}

variable "vm_admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "devopsadmin"
}

variable "vm_ssh_public_key" {
  description = "SSH public key for VM admin access"
  type        = string
  sensitive   = true
} 