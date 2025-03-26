# DevOps MVP Platform CI/CD Workflows

This directory contains GitHub Actions workflows for the DevOps MVP Platform project. These workflows automate building, testing, and deploying the platform components to Azure.

## Workflow Overview

### 1. Build and Publish (`build-and-publish.yml`)
- **Purpose**: Builds container images and publishes them to Azure Container Registry
- **Triggers**: 
  - Push to main branch
  - Pull requests to main branch
  - Manual trigger
- **Key Steps**:
  - Build Docker images
  - Run security scans with Trivy
  - Push to Azure Container Registry (only on main branch)

### 2. Deploy to Azure (`deploy-to-azure.yml`)
- **Purpose**: Deploys platform components to Azure
- **Triggers**:
  - Manual trigger with environment and image selection
- **Key Steps**:
  - Deploy to Azure Container Instance
  - Run post-deployment verification
  - Send deployment notifications

### 3. Terraform Deploy (`terraform-deploy.yml`)
- **Purpose**: Manages infrastructure as code with Terraform
- **Triggers**:
  - Changes to terraform directory on main branch
  - Pull requests with changes to terraform directory
  - Manual trigger with environment selection
- **Key Steps**:
  - Format and validate Terraform code
  - Run security scans with tfsec
  - Plan infrastructure changes
  - Apply changes (only on manual approval)

## Required Secrets

The following secrets need to be configured in GitHub:

- `AZURE_CREDENTIALS`: Azure service principal credentials in JSON format
- `ACR_USERNAME`: Azure Container Registry username
- `ACR_PASSWORD`: Azure Container Registry password
- `AZURE_CLIENT_ID`: Azure service principal client ID
- `AZURE_CLIENT_SECRET`: Azure service principal client secret
- `AZURE_SUBSCRIPTION_ID`: Azure subscription ID
- `AZURE_TENANT_ID`: Azure tenant ID
- `TF_API_TOKEN`: Terraform Cloud API token (if using Terraform Cloud)
- `TF_STORAGE_ACCOUNT_NAME`: Azure storage account for Terraform state
- `TF_CONTAINER_NAME`: Container name for Terraform state

## Usage Guidelines

1. **For development**: Push changes to feature branches and create PRs to trigger build validation
2. **For deploying infrastructure**: Use the Terraform workflow with manual approval
3. **For deploying applications**: Use the Deploy to Azure workflow after images are built and published

## Environment Configuration

The workflows are configured for the following environments:
- **Production**: Default target environment

## Security Considerations

All workflows include:
- Security scanning for container images
- Infrastructure security validation
- Manual approval steps for production deployments
- Proper secrets management 