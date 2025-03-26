variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual machine"
  type        = string
}

variable "location" {
  description = "The Azure location where the resources should be created"
  type        = string
}

variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "os_type" {
  description = "The OS type of the virtual machine (linux or windows)"
  type        = string
  default     = "linux"
  validation {
    condition     = contains(["linux", "windows"], var.os_type)
    error_message = "The os_type must be either 'linux' or 'windows'."
  }
}

variable "os_disk_type" {
  description = "The type of the OS disk"
  type        = string
  default     = "Standard_LRS"
}

variable "admin_username" {
  description = "The admin username for the virtual machine"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "The admin password for Windows virtual machines"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ssh_public_key" {
  description = "The SSH public key for Linux virtual machines"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "The ID of the subnet where the virtual machine should be deployed"
  type        = string
}

variable "public_ip" {
  description = "Whether to create a public IP for the virtual machine"
  type        = bool
  default     = false
}

variable "source_image" {
  description = "The source image reference for the virtual machine"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

variable "boot_diagnostics_storage_uri" {
  description = "The URI of the storage account for boot diagnostics"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to apply to the resources"
  type        = map(string)
  default     = {}
}

variable "enable_monitoring" {
  description = "Whether to enable Azure monitoring agent on the virtual machine"
  type        = bool
  default     = true
}

variable "custom_script" {
  description = "Custom script to run on the virtual machine"
  type        = string
  default     = ""
} 