# Terraform Helper Scripts

This directory contains helper scripts for managing Terraform operations in the DevOps MVP Platform.

## Scripts

### `force-unlock-state.ps1`

A PowerShell script to detect and forcibly remove Azure Storage-based Terraform state locks.

**Usage:**
```powershell
./force-unlock-state.ps1 -StorageAccount <name> -ResourceGroup <name> -Container <name> -StateKey <name> [-Force]
```

**Parameters:**
- `StorageAccount`: The Azure Storage account name (or set via `$env:STATE_SA`)
- `ResourceGroup`: The resource group containing the storage account (or set via `$env:STATE_RG`)
- `Container`: The blob container name for the Terraform state (or set via `$env:STATE_CONTAINER`)
- `StateKey`: The blob name for the Terraform state file (or set via `$env:STATE_KEY`)
- `SubscriptionId`: Optional Azure subscription ID (or set via `$env:ARM_SUBSCRIPTION_ID`)
- `Force`: Switch to force removal of locks without prompting

### `tf-wrapper.ps1`

A wrapper script for Terraform commands that handles common operations with appropriate locking settings.

**Usage:**
```powershell
./tf-wrapper.ps1 -Action <action> [-VarFile <path>] [-LockTimeout <seconds>] [-ClearLocks]
```

**Parameters:**
- `Action`: The Terraform action to perform (init, plan, apply, destroy, validate, state)
- `VarFile`: Optional path to a tfvars file
- `LockTimeout`: Number of seconds to wait for a lock (default: 300)
- `ClearLocks`: Switch to clear any existing locks before running the command
- `AdditionalArgs`: Any additional arguments to pass to Terraform

## Troubleshooting State Lock Issues

If your Terraform commands hang on "Acquiring state lock", try these solutions:

1. **Increase the lock timeout**:
   ```powershell
   ./tf-wrapper.ps1 -Action plan -LockTimeout 600
   ```

2. **Clear locks before running commands**:
   ```powershell
   ./tf-wrapper.ps1 -Action plan -ClearLocks
   ```

3. **Directly remove a lock**:
   ```powershell
   ./force-unlock-state.ps1
   ```

4. **Using native Terraform commands**:

   First, find the lock ID:
   ```powershell
   terraform force-unlock -force <LOCK_ID>
   ```

## Common Issues and Solutions

### Lock Remains After Failed Execution

If a lock remains after a failed Terraform execution, use the `force-unlock-state.ps1` script to remove it.

### Multiple Workflow Runs Conflict

Use a consistent approach in your CI/CD workflow by adding lock timeouts and handling mechanisms:

1. Add retry logic with exponential backoff
2. Implement lock detection and automatic breaking of stale locks
3. Queue operations in your CI/CD system to avoid concurrent runs

### Local & Remote Lock Conflicts

If you run Terraform locally and in CI/CD, ensure you're not competing for locks by:
1. Using different state files for different environments
2. Coordinating timing of automated operations 