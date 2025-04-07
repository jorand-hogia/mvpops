# Terraform configuration for the Grafana VM (Monitoring Stack)

module "grafana_vm" {
  source = "../../modules/azure/vm" # Corrected path

  vm_name             = "vm-grafana-prod-01"  # Use vm_name parameter
  vm_size             = "Standard_B2ms"    # Changed from Standard_E4s_v3 to stay within quota
  resource_group_name = var.resource_group_name # Assuming an environment variable exists for RG name
  location            = var.location           # Assuming an environment variable exists for location
  subnet_id           = azurerm_subnet.vm_subnet.id # Reference subnet defined in main.tf
  os_type             = "linux"                # Explicitly set OS type

  admin_username = "grafanaadmin" # Placeholder - Should use a variable or Key Vault
  # ssh_public_key = "..." # Placeholder - Needs secure handling (e.g., Key Vault variable)
  ssh_public_key = var.vm_ssh_public_key # Use the original variable name

  # Use custom_script and convert cloud-init to shell script
  custom_script = <<-EOF
    #!/bin/bash
    # Update packages
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https software-properties-common wget

    # Add Grafana GPG key
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

    # Add Grafana repository
    sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

    # Install Grafana
    sudo apt-get update -y
    sudo apt-get install -y grafana

    # Enable and start Grafana service
    sudo systemctl daemon-reload
    sudo systemctl enable grafana-server
    sudo systemctl start grafana-server

    # Basic firewall rule (adjust as needed for production security)
    sudo ufw allow 3000/tcp
    # Ensure ufw is enabled - might require non-interactive setup depending on base image
    echo "y" | sudo ufw enable || true

    EOF

  tags = {
    Environment = "Production"
    Project     = "OpsPlatform"
    Purpose     = "Monitoring Stack - Grafana"
    ManagedBy   = "Terraform"
    CostCenter  = var.cost_center # Assuming a variable exists
  }
}

# Outputs specific to Grafana VM (e.g., public IP if configured)
output "grafana_vm_private_ip" {
  description = "Private IP address of the Grafana VM"
  value       = module.grafana_vm.private_ip_address # Assuming this name is correct
} 