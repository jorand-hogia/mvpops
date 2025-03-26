# DevOps MVP Platform - Terraform Infrastructure

This directory contains the Terraform code for provisioning and managing the DevOps MVP Platform infrastructure on Azure.

## Infrastructure Components

The Terraform code provisions the following Azure resources:

- Resource Group for organizing all platform resources
- Storage Account for platform artifacts
- Azure Container Registry (ACR) for container images
- Key Vault for secrets management
- Log Analytics Workspace for centralized logging
- Azure Monitor Action Group for alerting

## Usage

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) version 1.0.0 or later
- Azure CLI installed and authenticated
- Appropriate Azure permissions

### Local Development

1. Initialize the Terraform working directory:

```bash
terraform init
```

2. Create a plan to preview changes:

```bash
terraform plan -out=tfplan
```

3. Apply the changes:

```bash
terraform apply tfplan
```

### CI/CD Pipeline

The infrastructure is managed through the GitHub Actions workflow defined in `.github/workflows/terraform-deploy.yml`.

The workflow:
- Validates Terraform code
- Plans changes
- Applies changes after approval (manual workflow) or on merge to main (automated)

## Variables

| Name | Description | Default |
|------|-------------|---------|
| prefix | Prefix for resource names | mvpops |
| environment | Environment name | production |
| resource_group_name | Resource group name | mvpops-production-rg |
| location | Azure region | eastus2 |
| tenant_id | Azure AD tenant ID | Required |
| alert_email | Email for alerts | devops@example.com |

## Outputs

The Terraform code outputs the names and IDs of the provisioned resources for reference in other parts of the system.

## Security Considerations

- Key Vault is configured with RBAC
- Container Registry with Premium SKU for enhanced security features
- Default TLS 1.2 enforcement
- Resource logs are sent to Log Analytics

## Best Practices

- All infrastructure is defined as code
- Resources are tagged consistently
- State is stored remotely in Azure Storage
- Secrets are never stored in the code repository 