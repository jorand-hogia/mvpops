variable "location" {
  description = "The Azure region for the Production environment."
  type        = string
  # No default - should be provided via tfvars or environment variables
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "state_resource_group_name" {
  description = "Name of the resource group for Terraform state"
  type        = string
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
  default     = 0
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
  description = "SSH public key for VM access"
  type        = string
}

variable "cost_center" {
  description = "The cost center tag value for resource tracking."
  type        = string
  default     = "JPCostCenterProd"
}

variable "ops_team_email" {
  description = "Email address for the ops team to receive alerts"
  type        = string
}

variable "vm_configs" {
  description = "List of VM configurations"
  type = list(object({
    name = string
    size = string
    role = string
  }))
  default = [
    {
      name = "vm-cicd-agent-prod"
      size = "Standard_D4s_v3"
      role = "CI/CD Agent"
    },
    {
      name = "vm-monitoring-prod"
      size = "Standard_E4s_v3"
      role = "Monitoring"
    },
    {
      name = "vm-management-prod"
      size = "Standard_B2ms"
      role = "Management"
    }
  ]
}

variable "vm_resource_ids" {
  description = "List of VM resource IDs to monitor"
  type        = list(string)
  default     = []
} 