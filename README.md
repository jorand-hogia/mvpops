# DevOps Platform MVP

This repository contains a modular DevOps platform implementation that can be deployed to both Azure and vSphere environments. It provides a foundation for building a modern DevOps platform with centralized services for container registry, monitoring, and security.

## Project Structure

```
.
├── terraform/                 # Infrastructure as Code
│   ├── modules/              # Reusable Terraform modules
│   │   ├── azure/           # Azure-specific modules
│   │   ├── azure-vm/        # Azure VM modules
│   │   └── vsphere/         # vSphere-specific modules
│   ├── environments/         # Environment-specific configurations
│   │   ├── dev/             # Development environment
│   │   └── prod/            # Production environment
│   └── backend.conf         # Terraform backend configuration
├── .github/                  # GitHub Actions workflows
├── .env                      # Environment variables
└── README.md                 # This file
```

## Prerequisites

- Terraform >= 1.0.0
- Azure CLI (for Azure deployments)
- vSphere CLI (for vSphere deployments)
- GitHub account with repository access
- Required environment variables (see `.env.example`)

## Getting Started

1. **Clone the Repository**
   ```bash
   git clone https://github.com/your-org/devops-platform-mvp.git
   cd devops-platform-mvp
   ```

2. **Configure Environment Variables**
   - Copy `.env.example` to `.env`
   - Update the values in `.env` with your specific configuration
   - Never commit `.env` to version control

3. **Choose Your Environment**
   - For Azure: Use the `azure` modules
   - For vSphere: Use the `vsphere` modules

4. **Initialize Terraform**
   ```bash
   cd terraform/environments/dev  # or prod
   terraform init
   ```

5. **Deploy Infrastructure**
   ```bash
   terraform plan
   terraform apply
   ```

## Environment Variables

The following environment variables are required:

### Azure Configuration
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID
- `AZURE_TENANT_ID`: Your Azure tenant ID
- `AZURE_CLIENT_ID`: Service principal client ID
- `AZURE_CLIENT_SECRET`: Service principal client secret

### Resource Groups
- `RESOURCE_GROUP_DEV`: Development resource group name
- `RESOURCE_GROUP_STAGING`: Staging resource group name
- `RESOURCE_GROUP_PROD`: Production resource group name

### Container Registry
- `CONTAINER_REGISTRY_NAME`: Azure Container Registry name
- `CONTAINER_REGISTRY_SKU`: ACR SKU (Basic, Standard, Premium)

### Storage Account
- `STORAGE_ACCOUNT_NAME`: Terraform state storage account
- `STORAGE_ACCOUNT_KEY`: Storage account access key
- `TERRAFORM_STATE_CONTAINER`: Container for Terraform state

### Monitoring
- `APPLICATION_INSIGHTS_KEY`: Application Insights instrumentation key
- `LOG_ANALYTICS_WORKSPACE_ID`: Log Analytics workspace ID

### VM Configuration
- `VM_ADMIN_USERNAME`: Admin username for VMs
- `VM_SSH_PUBLIC_KEY`: SSH public key for VM access

## Terraform Variables

The following variables can be configured in your environment's `terraform.tfvars`:

| Variable | Description | Default |
|----------|-------------|---------|
| `environment` | Environment name (dev, staging, prod) | "dev" |
| `location` | Azure region or vSphere datacenter | "swedencentral" |
| `prefix` | Prefix for resource names | "mvpops" |
| `resource_group_name` | Resource group name | "mvpops-{env}-rg" |
| `team_name` | Team name for tagging | "mvpops" |
| `alert_email` | Email for alerts | "devops@example.com" |

## Modules

### Azure Modules
- `azure/container-registry`: Azure Container Registry
- `azure/key-vault`: Azure Key Vault
- `azure/log-analytics`: Log Analytics Workspace
- `azure/monitoring`: Monitoring and alerting
- `azure/storage`: Storage accounts
- `azure-vm/virtual-machine`: Azure Virtual Machines

### vSphere Modules
- `vsphere/virtual-machine`: vSphere Virtual Machines
- `vsphere/network`: Network configuration
- `vsphere/storage`: Storage configuration

## Deployment Process

1. **Development Environment**
   - Deploy to development environment first
   - Test all components
   - Validate monitoring and logging

2. **Staging Environment**
   - Deploy to staging after development validation
   - Perform integration testing
   - Validate security configurations

3. **Production Environment**
   - Deploy to production after staging validation
   - Monitor deployment closely
   - Verify all services are operational

## Security Considerations

- All sensitive data is stored in Azure Key Vault
- Use managed identities where possible
- Implement network security groups
- Enable Azure Defender for Cloud
- Regular security scanning of container images

## Monitoring and Logging

- Azure Monitor for infrastructure metrics
- Application Insights for application monitoring
- Log Analytics for centralized logging
- Alert rules for critical events

## CI/CD Pipeline

The project uses GitHub Actions for continuous integration and deployment. The pipeline includes:

### Development Pipeline
1. **Code Quality Checks**
   - Terraform validation
   - Security scanning
   - Code linting

2. **Infrastructure Testing**
   - Terraform plan validation
   - Cost estimation
   - Security compliance checks

3. **Automated Deployment**
   - Development environment deployment
   - Integration tests
   - Performance tests

### Production Pipeline
1. **Pre-deployment Checks**
   - Manual approval gates
   - Environment validation
   - Backup verification

2. **Deployment Strategy**
   - Blue-green deployment
   - Canary releases
   - Rollback procedures

3. **Post-deployment**
   - Health checks
   - Monitoring validation
   - Performance metrics collection

### Pipeline Security
- Secrets management using Azure Key Vault
- Role-based access control
- Audit logging
- Compliance checks

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue in the GitHub repository or contact the DevOps team.

## Disaster Recovery

### Backup Strategy
1. **Infrastructure State**
   - Terraform state backups
   - Infrastructure configuration versioning
   - Resource group snapshots

2. **Data Protection**
   - Regular database backups
   - Storage account replication
   - Container registry replication

3. **Configuration Backup**
   - Key Vault backup
   - Network configuration backup
   - Security policy backup

### Recovery Procedures
1. **Infrastructure Recovery**
   - Terraform state restoration
   - Resource recreation procedures
   - Network restoration

2. **Data Recovery**
   - Database restoration
   - Storage account recovery
   - Container registry recovery

3. **Service Recovery**
   - Service health checks
   - Dependency verification
   - Performance validation

### Testing
- Regular disaster recovery drills
- Automated recovery testing
- Documentation updates

## Cost Management

### Resource Optimization
1. **Infrastructure Sizing**
   - Right-sized VM instances
   - Auto-scaling configurations
   - Resource utilization monitoring

2. **Cost Controls**
   - Budget alerts
   - Resource tagging
   - Cost allocation

3. **Optimization Strategies**
   - Reserved instances
   - Spot instances
   - Resource scheduling

### Monitoring and Reporting
1. **Cost Tracking**
   - Daily cost reports
   - Resource cost breakdown
   - Trend analysis

2. **Alerting**
   - Budget threshold alerts
   - Unusual spending patterns
   - Resource optimization suggestions

3. **Reporting**
   - Monthly cost reports
   - Department cost allocation
   - ROI analysis

## Learning Path

### For Ops Teams

#### Phase 1: Platform Fundamentals (1-2 weeks)
1. **Infrastructure as Code Basics**
   - Understanding Terraform modules
   - Environment configuration
   - State management
   - Hands-on: Deploy a simple resource group

2. **Security and Compliance**
   - Key Vault management
   - Network security groups
   - Access control
   - Hands-on: Set up a secure network

3. **Monitoring and Logging**
   - Log Analytics setup
   - Alert configuration
   - Dashboard creation
   - Hands-on: Create monitoring for a test environment

#### Phase 2: Advanced Operations (2-3 weeks)
1. **CI/CD Pipeline Management**
   - GitHub Actions workflows
   - Deployment strategies
   - Environment promotion
   - Hands-on: Set up a test pipeline

2. **Disaster Recovery**
   - Backup procedures
   - Recovery testing
   - High availability
   - Hands-on: Perform a recovery drill

3. **Cost Management**
   - Resource optimization
   - Budget monitoring
   - Cost allocation
   - Hands-on: Analyze and optimize costs

### For Developers

#### Phase 1: Platform Basics (1 week)
1. **Environment Setup**
   - Local development environment
   - Access configuration
   - Basic deployment
   - Hands-on: Deploy a test application

2. **Container Registry Usage**
   - Image building
   - Registry access
   - Version management
   - Hands-on: Push a container image

3. **Basic Monitoring**
   - Application Insights
   - Logging basics
   - Alert configuration
   - Hands-on: Add monitoring to an application

#### Phase 2: Advanced Development (2-3 weeks)
1. **CI/CD Integration**
   - Pipeline configuration
   - Automated testing
   - Deployment automation
   - Hands-on: Set up a development pipeline

2. **Security Best Practices**
   - Secret management
   - Access control
   - Security scanning
   - Hands-on: Implement security in an application

3. **Performance Optimization**
   - Resource utilization
   - Scaling configuration
   - Performance monitoring
   - Hands-on: Optimize application performance

### Learning Resources

1. **Documentation**
   - [Terraform Documentation](https://www.terraform.io/docs)
   - [Azure Documentation](https://docs.microsoft.com/en-us/azure)
   - [GitHub Actions Documentation](https://docs.github.com/en/actions)

2. **Training Materials**
   - Internal training sessions
   - Video tutorials
   - Hands-on workshops

3. **Support Channels**
   - Internal Slack channel: #devops-platform-support
   - Weekly office hours
   - Mentorship program

### Getting Started Checklist

#### Ops Team
- [ ] Complete Phase 1 training
- [ ] Set up a test environment
- [ ] Configure basic monitoring
- [ ] Create a backup strategy
- [ ] Document procedures

#### Developers
- [ ] Complete Phase 1 training
- [ ] Set up development environment
- [ ] Deploy a test application
- [ ] Configure basic monitoring
- [ ] Document deployment process

### Next Steps

1. **Schedule Training**
   - Contact the DevOps team to schedule initial training
   - Join the weekly knowledge sharing sessions
   - Participate in hands-on workshops

2. **Start Small**
   - Begin with a non-critical application
   - Use the development environment
   - Gradually move to production

3. **Provide Feedback**
   - Document challenges
   - Suggest improvements
   - Share success stories 