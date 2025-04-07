# Ops Team Quick Start Guide

## Day 1: Initial Setup

### 1. Environment Setup
```bash
# Clone the repository
git clone https://github.com/your-org/devops-platform-mvp.git
cd devops-platform-mvp

# Set up environment variables
cp .env.example .env
# Edit .env with your values
```

### 2. First Deployment
```bash
# Navigate to development environment
cd terraform/environments/dev

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the changes
terraform apply
```

## Day 2: Basic Operations

### 1. Monitor Resources
- Access Azure Portal
- Check resource health
- Review monitoring dashboards
- Set up basic alerts

### 2. Security Setup
- Configure Key Vault
- Set up network security groups
- Review access controls
- Document security procedures

## Day 3: CI/CD Basics

### 1. Pipeline Setup
- Review GitHub Actions workflows
- Set up a test pipeline
- Configure deployment gates
- Test the pipeline

### 2. Backup Configuration
- Set up Terraform state backup
- Configure resource backups
- Document recovery procedures
- Test backup restoration

## Common Tasks

### Adding New Resources
1. Create a new module or use existing one
2. Add to environment configuration
3. Plan and apply changes
4. Document the changes

### Managing Secrets
1. Add to Key Vault
2. Update environment variables
3. Update documentation
4. Test access

### Monitoring Setup
1. Configure Log Analytics
2. Set up alerts
3. Create dashboards
4. Document procedures

## Troubleshooting

### Common Issues
1. **Terraform State Issues**
   - Check backend configuration
   - Verify state file access
   - Review recent changes

2. **Access Problems**
   - Check RBAC settings
   - Verify service principal
   - Review network rules

3. **Deployment Failures**
   - Check resource limits
   - Review error messages
   - Verify configurations

## Support Resources

- Internal Documentation
- Team Slack Channel
- Weekly Office Hours
- Emergency Contact List

## Next Steps

1. Complete the full learning path
2. Set up a test environment
3. Document procedures
4. Train other team members 