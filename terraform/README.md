# DevOps MVP Platform - Terraform Infrastructure

This directory contains the Terraform code for managing Azure resources for the DevOps MVP Platform.

## Structure

- `modules/` - Reusable Terraform modules
  - `azure-vm/` - Module for creating Azure virtual machines with standardized configuration
  
- `environments/` - Environment-specific configurations
  - `dev/` - Development environment
  - `prod/` - Production environment

## Prerequisites

- Terraform v1.0.0 or newer
- Azure CLI installed and authenticated
- Storage account for Terraform state (already configured in the environment configs)

## Getting Started

1. Navigate to the environment directory you want to work with:

```bash
cd environments/prod
```

2. Create a `terraform.tfvars` file (you can use the provided example):

```bash
cp terraform.tfvars.example terraform.tfvars
```

3. Edit the `terraform.tfvars` file with your specific values:
   - Update the `vm_ssh_public_key` with your actual SSH public key
   - Adjust any other variables as needed for your environment

4. Initialize Terraform to download required providers and set up the backend:

```bash
terraform init
```

5. Create a plan to review the changes:

```bash
terraform plan -out=tfplan
```

6. Apply the changes:

```bash
terraform apply tfplan
```

## VM Management

This configuration will create:

- CI/CD Agent VMs (Standard_D4s_v3, Linux)
- Monitoring VMs (Standard_E4s_v3, Linux)
- Management VMs (Standard_B2ms, Linux)

All VMs have:
- Azure Monitor agents installed
- Boot diagnostics enabled
- Standardized tagging
- Appropriate security configurations

## Adding New VM Types

To add a new VM type:

1. Create a new module instance in the environment's `main.tf` file
2. Configure the appropriate variables in `variables.tf` and `terraform.tfvars`
3. Add any outputs needed in `outputs.tf`

## Best Practices

- Always use the provided modules to ensure standardization
- Apply consistent tagging for all resources
- Use the variables to control VM counts instead of duplicating code
- Keep sensitive information in encrypted files or Azure Key Vault 