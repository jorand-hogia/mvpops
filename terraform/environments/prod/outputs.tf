output "location" {
  description = "The Azure location where resources are created"
  value       = var.location
}

output "state_resource_group_name" {
  description = "The name of the resource group for Terraform state"
  value       = var.state_resource_group_name
}

output "resource_group_name" {
  description = "The name of the resource group for infrastructure"
  value       = var.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.vms.location
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = azurerm_subnet.main.name
}

output "cicd_agent_vm_ids" {
  description = "The IDs of the CI/CD agent VMs"
  value       = module.cicd_agent_vm[*].vm_id
}

output "cicd_agent_vm_private_ips" {
  description = "The private IP addresses of the CI/CD agent VMs"
  value       = module.cicd_agent_vm[*].private_ip_address
}

output "monitoring_vm_ids" {
  description = "The IDs of the monitoring VMs"
  value       = module.monitoring_vm[*].vm_id
}

output "monitoring_vm_public_ips" {
  description = "The public IP addresses of the monitoring VMs"
  value       = module.monitoring_vm[*].public_ip_address
}

output "management_vm_ids" {
  description = "The IDs of the management VMs"
  value       = module.management_vm[*].vm_id
}

output "management_vm_public_ips" {
  description = "The public IP addresses of the management VMs"
  value       = module.management_vm[*].public_ip_address
} 