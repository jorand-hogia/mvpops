#!/usr/bin/env pwsh
# tf-wrapper.ps1
# A wrapper script for Terraform operations that handles state locking issues

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("init", "plan", "apply", "destroy", "validate", "state")]
    [string]$Action,
    
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$AdditionalArgs,
    
    [int]$LockTimeout = 300,  # Default 5 minutes
    
    [switch]$ClearLocks,
    
    [string]$VarFile,
    
    [string]$StateDirectory = $PWD
)

# Check if we should clear locks first
if ($ClearLocks) {
    Write-Host "Clearing state locks before proceeding..." -ForegroundColor Yellow
    
    $forceClearScript = Join-Path $PSScriptRoot "force-unlock-state.ps1"
    
    if (Test-Path $forceClearScript) {
        & $forceClearScript -Force
    } else {
        Write-Warning "force-unlock-state.ps1 script not found at $forceClearScript"
    }
}

# Build the command
$terraformCommand = "terraform $Action"

# Add lock timeout to all operations except init
if ($Action -ne "init") {
    $terraformCommand += " -lock-timeout=${LockTimeout}s"
}

# Special handling for each action
switch ($Action) {
    "init" {
        # Check for backend configuration
        $backendConfigFile = "../../backend.conf.local"
        if (Test-Path $backendConfigFile) {
            $terraformCommand += " -backend-config=`"$backendConfigFile`""
        } else {
            $backendConfigFile = "../../backend.conf"
            if (Test-Path $backendConfigFile) {
                $terraformCommand += " -backend-config=`"$backendConfigFile`""
            }
        }
        $terraformCommand += " -reconfigure"
    }
    
    "plan" {
        if (!$VarFile -and (Test-Path "../../config/infrastructure.tfvars")) {
            $VarFile = "../../config/infrastructure.tfvars"
        }
        
        if ($VarFile) {
            $terraformCommand += " -var-file=`"$VarFile`""
        }
        
        $terraformCommand += " -out=tfplan"
    }
    
    "apply" {
        if (Test-Path "tfplan") {
            $terraformCommand += " tfplan"
        } elseif (!$VarFile -and (Test-Path "../../config/infrastructure.tfvars")) {
            $VarFile = "../../config/infrastructure.tfvars"
            $terraformCommand += " -var-file=`"$VarFile`" -auto-approve"
        } elseif ($VarFile) {
            $terraformCommand += " -var-file=`"$VarFile`" -auto-approve"
        }
    }
    
    "destroy" {
        if (!$VarFile -and (Test-Path "../../config/infrastructure.tfvars")) {
            $VarFile = "../../config/infrastructure.tfvars"
        }
        
        if ($VarFile) {
            $terraformCommand += " -var-file=`"$VarFile`""
        }
    }
}

# Add any additional arguments
if ($AdditionalArgs) {
    $terraformCommand += " $($AdditionalArgs -join ' ')"
}

# Execute the command
Write-Host "Executing: $terraformCommand" -ForegroundColor Green
Invoke-Expression $terraformCommand

# Check exit code
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
    # Special handling for common errors
    if ($exitCode -eq 1) {
        # Check specifically for lock errors
        if ($Action -eq "plan" -or $Action -eq "apply") {
            Write-Host "Terraform operation failed. Checking for state lock issues..." -ForegroundColor Yellow
            
            # Look for lock indications in the error output
            if (Get-Content $PSScriptRoot\tf_error.log -ErrorAction SilentlyContinue | Select-String -Pattern "lock" -Quiet) {
                Write-Host "State lock issue detected. You can try again with the -ClearLocks option." -ForegroundColor Red
                Write-Host "Example: ./tf-wrapper.ps1 -Action $Action -ClearLocks" -ForegroundColor Cyan
            }
        }
    }
    
    Write-Host "Terraform operation failed with exit code $exitCode" -ForegroundColor Red
    exit $exitCode
}

Write-Host "Terraform operation completed successfully" -ForegroundColor Green
exit 0 