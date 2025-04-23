# PowerShell script to generate Terraform variables from YAML configuration
param(
    [Parameter(Mandatory=$true)]
    [string]$ConfigPath
)

# Check if yq is installed (required for YAML processing)
if (-not (Get-Command yq -ErrorAction SilentlyContinue)) {
    Write-Error "yq is required but not installed. Please install it first."
    exit 1
}

# Validate config file exists
if (-not (Test-Path $ConfigPath)) {
    Write-Error "Configuration file not found: $ConfigPath"
    exit 1
}

# Read YAML file
$config = yq eval -o json $ConfigPath | ConvertFrom-Json

# Generate Terraform variables
$tfvars = @"
# Generated from $ConfigPath
# DO NOT EDIT MANUALLY

product_name    = "${config.product.name}"
environment     = "${config.product.environment}"
team_name       = "${config.product.team}"
team_email      = "${config.product.contact}"

compute_config = {
    vm_type    = "${config.infrastructure.compute.vm_type}"
    instances  = ${config.infrastructure.compute.instances}
    disk_size_gb = ${config.infrastructure.compute.requirements.disk}
}

network_config = {
    vnet_address_space = "${config.infrastructure.networking.vnet_address_space}"
    subnets = [
$(
    $config.infrastructure.networking.subnet_config | ForEach-Object {
        "        {`n            name = `"$($_.name)`"`n            address_prefix = `"$($_.address_prefix)`"`n        }"
    } | Join-String -Separator ",`n"
)
    ]
}

monitoring_config = {
    log_retention_days = ${config.infrastructure.monitoring.log_retention_days}
    alerts = [
$(
    $config.infrastructure.monitoring.alerts | ForEach-Object {
        "        {`n            name = `"$($_.name)`"`n            threshold = $($_.threshold)`n            window = `"$($_.window)`"`n        }"
    } | Join-String -Separator ",`n"
)
    ]
}

security_config = {
    allowed_ips = [
$(
    $config.infrastructure.security.allowed_ips | ForEach-Object {
        "        `"$_`""
    } | Join-String -Separator ",`n"
)
    ]
}

tags = {
    Product     = "${config.product.name}"
    Environment = "${config.product.environment}"
    Team        = "${config.product.team}"
    ManagedBy   = "Terraform"
}
"@

# Output the generated tfvars
$tfvars 