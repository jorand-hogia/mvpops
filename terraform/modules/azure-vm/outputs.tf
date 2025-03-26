output "vm_id" {
  description = "The ID of the virtual machine"
  value       = var.os_type == "linux" ? try(azurerm_linux_virtual_machine.vm[0].id, "") : try(azurerm_windows_virtual_machine.vm[0].id, "")
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = var.vm_name
}

output "private_ip_address" {
  description = "The private IP address of the virtual machine"
  value       = try(azurerm_network_interface.vm_nic.private_ip_address, "")
}

output "public_ip_address" {
  description = "The public IP address of the virtual machine"
  value       = var.public_ip ? try(azurerm_public_ip.vm_public_ip[0].ip_address, "") : ""
}

output "network_interface_id" {
  description = "The ID of the network interface"
  value       = azurerm_network_interface.vm_nic.id
} 