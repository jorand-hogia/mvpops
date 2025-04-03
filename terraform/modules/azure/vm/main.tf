resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip ? azurerm_public_ip.vm_public_ip[0].id : null
  }

  tags = var.tags
}

resource "azurerm_public_ip" "vm_public_ip" {
  count               = var.public_ip ? 1 : 0
  name                = "${var.vm_name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.os_type == "linux" ? 1 : 0
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  source_image_reference {
    publisher = var.source_image.publisher
    offer     = var.source_image.offer
    sku       = var.source_image.sku
    version   = var.source_image.version
  }

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_uri
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "vm" {
  count               = var.os_type == "windows" ? 1 : 0
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  source_image_reference {
    publisher = var.source_image.publisher
    offer     = var.source_image.offer
    sku       = var.source_image.sku
    version   = var.source_image.version
  }

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_uri
  }

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "monitoring_agent" {
  count                      = var.enable_monitoring ? 1 : 0
  name                       = "AzureMonitorAgent"
  virtual_machine_id         = var.os_type == "linux" ? azurerm_linux_virtual_machine.vm[0].id : azurerm_windows_virtual_machine.vm[0].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = var.os_type == "linux" ? "AzureMonitorLinuxAgent" : "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "custom_script" {
  count                = var.custom_script == "" ? 0 : 1
  name                 = "CustomScript"
  virtual_machine_id   = var.os_type == "linux" ? azurerm_linux_virtual_machine.vm[0].id : azurerm_windows_virtual_machine.vm[0].id
  publisher            = var.os_type == "linux" ? "Microsoft.Azure.Extensions" : "Microsoft.Compute"
  type                 = var.os_type == "linux" ? "CustomScript" : "CustomScriptExtension"
  type_handler_version = var.os_type == "linux" ? "2.1" : "1.10"

  settings = <<SETTINGS
    {
      "script": "${base64encode(var.custom_script)}"
    }
  SETTINGS
} 