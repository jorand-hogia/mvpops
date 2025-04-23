#!/usr/bin/env pwsh
# process-backend-config.ps1
# Script to process backend.conf with environment variables

# Default values
$env:TF_STATE_CONTAINER = if ($env:TF_STATE_CONTAINER) { $env:TF_STATE_CONTAINER } else { "tfstate" }
$env:TF_STATE_KEY = if ($env:TF_STATE_KEY) { $env:TF_STATE_KEY } else { "terraform.tfstate" }

# Check required environment variables
if (!$env:TF_STATE_RESOURCE_GROUP) {
    Write-Error "TF_STATE_RESOURCE_GROUP environment variable is required"
    exit 1
}

if (!$env:TF_STATE_STORAGE_ACCOUNT) {
    Write-Error "TF_STATE_STORAGE_ACCOUNT environment variable is required"
    exit 1
}

# Create the backend configuration content
$backendConfig = @"
# Backend configuration using environment variables
resource_group_name  = "$($env:TF_STATE_RESOURCE_GROUP)"
storage_account_name = "$($env:TF_STATE_STORAGE_ACCOUNT)"
container_name       = "$($env:TF_STATE_CONTAINER)"
key                  = "$($env:TF_STATE_KEY)"
"@

# Write to backend.conf.local
$backendConfig | Set-Content -Path "$PSScriptRoot/../backend.conf.local"

Write-Host "Backend configuration processed successfully. Created backend.conf.local with your settings." 