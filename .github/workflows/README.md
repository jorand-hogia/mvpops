# DevOps MVP Platform CI/CD Workflows

This directory contains GitHub Actions workflows for the DevOps MVP Platform project. These workflows automate infrastructure management through Terraform.

## Workflow Overview

### Terraform Infrastructure Management (`terraform-deploy.yml`)
- **Purpose**: Manages Azure infrastructure as code with Terraform
- **Triggers**:
  - Changes to terraform directory on main/master branch
  - Pull requests with changes to terraform directory
  - Manual trigger with environment selection
- **Jobs**:
  1. **Validate**: Format and validate Terraform code
     - Format check
     - Terraform validation
     - Security scanning with tfsec
  2. **Plan**: Create and share Terraform plans
     - Storage account initialization (if needed)
     - Terraform plan generation
     - Plan archiving for apply job
     - Comment plan results on PRs
  3. **Apply**: Apply infrastructure changes
     - Automatically on push to main/master
     - Manual approval flow for workflow_dispatch
     - Documentation generation

## Required Secrets

The following secrets need to be configured in GitHub:

- `AZURE_CREDENTIALS`: Azure service principal credentials in JSON format
- `AZURE_CLIENT_ID`: Azure service principal client ID
- `AZURE_CLIENT_SECRET`: Azure service principal client secret
- `AZURE_SUBSCRIPTION_ID`: Azure subscription ID
- `AZURE_TENANT_ID`: Azure tenant ID
- `TF_API_TOKEN`: Terraform Cloud API token (if using Terraform Cloud)
- `TF_STORAGE_ACCOUNT_NAME`: Azure storage account for Terraform state
- `TF_CONTAINER_NAME`: Container name for Terraform state

## Repository Structure

For this workflow to function properly, you should organize your Terraform code as follows:

```
/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── backend.tf
│   └── modules/
│       └── ...
└── .github/
    └── workflows/
        └── terraform-deploy.yml
```

## Usage Guidelines

1. **For development**: Create feature branches and open PRs to see plan output
2. **For applying changes**: 
   - Merge to main/master for automatic application
   - Use the manual workflow trigger with the apply option

## Security Considerations

The workflow includes:
- Infrastructure security scanning with tfsec
- Separate plan and apply stages for review
- Required approvals for manual deployments
- Proper Azure credentials management 