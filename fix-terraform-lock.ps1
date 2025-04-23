#!/usr/bin/env pwsh
# fix-terraform-lock.ps1
# Quick script to fix Terraform state lock issues

# Import common parameters
param(
    [switch]$Force = $false,
    [int]$LockTimeout = 300
)

# Check if we're in the right directory structure
if (!(Test-Path "terraform/scripts/force-unlock-state.ps1")) {
    if (Test-Path "./force-unlock-state.ps1") {
        # We're already in the scripts directory
        $scriptPath = "."
    } else {
        Write-Error "Could not find force-unlock-state.ps1 script. Please run this from the repository root or scripts directory."
        exit 1
    }
} else {
    $scriptPath = "terraform/scripts"
}

# Run the force-unlock script
Write-Host "Running state lock cleanup script..." -ForegroundColor Yellow
& "$scriptPath/force-unlock-state.ps1" -Force:$Force

# Set up temporary environment variables for lock timeout if needed
if ($env:TF_LOCK_TIMEOUT -eq $null) {
    $env:TF_LOCK_TIMEOUT = "${LockTimeout}s"
}

# Provide instructions for continuing with Terraform
Write-Host ""
Write-Host "State lock should now be removed." -ForegroundColor Green
Write-Host ""
Write-Host "To run Terraform with extended lock timeout:" -ForegroundColor Cyan
Write-Host "terraform plan -lock-timeout=${LockTimeout}s -out=tfplan" -ForegroundColor White
Write-Host "terraform apply -lock-timeout=${LockTimeout}s tfplan" -ForegroundColor White
Write-Host ""
Write-Host "Or use the wrapper script (if available):" -ForegroundColor Cyan
Write-Host "./terraform/scripts/tf-wrapper.ps1 -Action plan -LockTimeout $LockTimeout" -ForegroundColor White
Write-Host "" 