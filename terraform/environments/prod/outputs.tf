output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.vm_rg.name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.vm_rg.location
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vm_vnet.name
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = azurerm_subnet.vm_subnet.name
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