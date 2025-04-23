#!/usr/bin/env pwsh
# force-unlock-state.ps1
# Script to handle and clean up terraform state locks

param(
    [string]$StorageAccount = $env:STATE_SA,
    [string]$ResourceGroup = $env:STATE_RG,
    [string]$Container = $env:STATE_CONTAINER,
    [string]$StateKey = $env:STATE_KEY,
    [string]$SubscriptionId = $env:ARM_SUBSCRIPTION_ID,
    [switch]$Force = $false
)

# Make sure we have the Azure CLI available
if (!(Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI not found. Please install it first."
    exit 1
}

# Check login status
$isLoggedIn = az account show 2>$null
if (!$isLoggedIn) {
    Write-Host "Not logged in to Azure. Please log in first."
    az login
}

# Validate required parameters
if (!$StorageAccount -or !$ResourceGroup -or !$Container -or !$StateKey) {
    Write-Host "Usage: ./force-unlock-state.ps1 -StorageAccount <name> -ResourceGroup <name> -Container <name> -StateKey <name> [-Force]"
    Write-Host "Or set these environment variables: STATE_SA, STATE_RG, STATE_CONTAINER, STATE_KEY"
    exit 1
}

# Format storage account name (remove non-alphanumeric characters and convert to lowercase)
$StorageAccount = $StorageAccount.ToLower() -replace '[^a-z0-9]', '' 
if ($StorageAccount.Length -gt 24) {
    $StorageAccount = $StorageAccount.Substring(0, 24)
}

Write-Host "Using storage account: $StorageAccount"
Write-Host "Using resource group: $ResourceGroup"
Write-Host "Using container: $Container" 
Write-Host "Using state key: $StateKey"

# Set subscription context if specified
if ($SubscriptionId) {
    Write-Host "Setting subscription context to: $SubscriptionId"
    az account set --subscription $SubscriptionId
}

# Get storage account key
Write-Host "Getting storage account key..."
$storageKey = az storage account keys list --account-name $StorageAccount --resource-group $ResourceGroup --query "[0].value" -o tsv
if (!$storageKey) {
    Write-Error "Failed to get storage account key. Check if the storage account exists and you have access to it."
    exit 1
}

# Check if lock file exists
Write-Host "Checking for lock file..."
$lockExists = az storage blob exists --container-name $Container --name "$StateKey.lock" --account-name $StorageAccount --auth-mode key --account-key $storageKey --query "exists" -o tsv

if ($lockExists -eq "true") {
    # Get lock metadata
    Write-Host "Lock file exists! Getting metadata..."
    $lockMetadata = az storage blob show --container-name $Container --name "$StateKey.lock" --account-name $StorageAccount --auth-mode key --account-key $storageKey --query "properties.metadata" | ConvertFrom-Json
    
    if ($lockMetadata) {
        Write-Host "Lock is owned by: $($lockMetadata.owner)"
        Write-Host "Lock was created at: $($lockMetadata.timestamp)"
    } else {
        Write-Host "Lock exists but no metadata is available."
    }
    
    # Prompt to delete unless -Force is specified
    if (!$Force) {
        $confirm = Read-Host "Do you want to delete this lock? (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-Host "Operation cancelled."
            exit 0
        }
    }
    
    # Delete the lock
    Write-Host "Deleting lock file..."
    az storage blob delete --container-name $Container --name "$StateKey.lock" --account-name $StorageAccount --auth-mode key --account-key $storageKey
    Write-Host "Lock file deleted successfully!"
    
    # Try to force-unlock via terraform CLI as well
    Write-Host "You may also need to force-unlock via Terraform CLI:"
    Write-Host "terraform force-unlock <ID>"
} else {
    Write-Host "No lock file found in the Azure Storage container."
    
    # Check for local terraform lock instead
    if (Test-Path ".terraform.tfstate.lock.info") {
        Write-Host "Found local lock file: .terraform.tfstate.lock.info"
        Get-Content ".terraform.tfstate.lock.info" | Write-Host
        
        if (!$Force) {
            $confirm = Read-Host "Do you want to delete this local lock file? (y/N)"
            if ($confirm -ne "y" -and $confirm -ne "Y") {
                Write-Host "Operation cancelled."
                exit 0
            }
        }
        
        Remove-Item ".terraform.tfstate.lock.info" -Force
        Write-Host "Local lock file deleted."
    } else {
        Write-Host "No local lock file found either."
    }
}

Write-Host "Lock check complete. You should now be able to run terraform operations." 