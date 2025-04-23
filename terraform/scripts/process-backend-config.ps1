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

# Read backend.conf template
$backendConfig = Get-Content -Path "$PSScriptRoot/../backend.conf" -Raw

# Replace placeholders with environment variables
$backendConfig = $backendConfig -replace "__TFSTATE_RG__", $env:TF_STATE_RESOURCE_GROUP
$backendConfig = $backendConfig -replace "__TFSTATE_SA__", $env:TF_STATE_STORAGE_ACCOUNT
$backendConfig = $backendConfig -replace "__TFSTATE_CONTAINER__", $env:TF_STATE_CONTAINER
$backendConfig = $backendConfig -replace "__TFSTATE_KEY__", $env:TF_STATE_KEY

# Write to backend.conf.local
$backendConfig | Set-Content -Path "$PSScriptRoot/../backend.conf.local"

Write-Host "Backend configuration processed successfully. Created backend.conf.local with your settings." 