# Test script for validating terraform workflow changes

# Set environment variables (replace with your values)
$env:ARM_CLIENT_ID = "your-client-id"
$env:ARM_CLIENT_SECRET = "your-client-secret"
$env:ARM_SUBSCRIPTION_ID = "your-subscription-id"
$env:ARM_TENANT_ID = "your-tenant-id"
$env:STATE_SA = "your-storage-account"
$env:STATE_CONTAINER = "your-container"
$env:STATE_KEY = "terraform.tfstate"
$env:STATE_RG = "your-resource-group"

# Navigate to the terraform directory
Set-Location -Path "terraform/environments/prod"

# Format storage account name
$STORAGE_ACCOUNT_NAME = $env:STATE_SA.ToLower() -replace '[^a-z0-9]', '' | Select-Object -First 24

# Initialize terraform with migrate-state
Write-Host "Initializing Terraform with migrate-state..."
terraform init -migrate-state `
    -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" `
    -backend-config="container_name=$env:STATE_CONTAINER" `
    -backend-config="key=$env:STATE_KEY" `
    -backend-config="resource_group_name=$env:STATE_RG" `
    -backend-config="subscription_id=$env:ARM_SUBSCRIPTION_ID" `
    -backend-config="tenant_id=$env:ARM_TENANT_ID" `
    -backend-config="client_id=$env:ARM_CLIENT_ID" `
    -backend-config="client_secret=$env:ARM_CLIENT_SECRET"

# If migrate-state fails, try reconfigure
if ($LASTEXITCODE -ne 0) {
    Write-Host "Migrate-state failed, trying reconfigure..."
    terraform init -reconfigure `
        -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" `
        -backend-config="container_name=$env:STATE_CONTAINER" `
        -backend-config="key=$env:STATE_KEY" `
        -backend-config="resource_group_name=$env:STATE_RG" `
        -backend-config="subscription_id=$env:ARM_SUBSCRIPTION_ID" `
        -backend-config="tenant_id=$env:ARM_TENANT_ID" `
        -backend-config="client_id=$env:ARM_CLIENT_ID" `
        -backend-config="client_secret=$env:ARM_CLIENT_SECRET"
}

# Check for and remove any existing locks
Write-Host "Checking for existing state lock..."
$LOCK_ID = terraform state list | Select-String -Pattern 'lock-[0-9a-f-]*' | Select-Object -First 1
if ($LOCK_ID) {
    Write-Host "Found lock ID: $($LOCK_ID.Matches.Value)"
    terraform force-unlock -force $($LOCK_ID.Matches.Value)
} else {
    Write-Host "No existing lock found"
}

# Run plan
Write-Host "Running terraform plan..."
terraform plan `
    -var-file="../../config/infrastructure.tfvars" `
    -lock-timeout=5m `
    -out=tfplan

# Return to original directory
Set-Location -Path "../../.." 