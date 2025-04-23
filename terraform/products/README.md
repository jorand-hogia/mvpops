# Product Infrastructure Management

This directory contains infrastructure configurations for different products. Each product team can define their infrastructure requirements using a simple YAML configuration file.

## Getting Started

1. Create a new directory for your product:
```bash
mkdir -p terraform/products/your-product-name
```

2. Copy the example configuration:
```bash
cp terraform/products/example-product/config.yaml terraform/products/your-product-name/config.yaml
```

3. Edit the configuration file according to your needs:
```yaml
product:
  name: "your-product-name"    # Lowercase letters, numbers, and hyphens only
  environment: "dev"           # dev, test, or prod
  team: "your-team-name"
  contact: "team@company.com"  # Team contact email

infrastructure:
  compute:
    vm_type: "Standard_D4s_v3"  # Azure VM size
    instances: 2                 # Number of VM instances (1-10)
    requirements:
      cpu: 4                    # Required CPU cores
      memory: 16                # Required memory in GB
      disk: 256                 # Required disk size in GB
  
  networking:
    vnet_address_space: "10.1.0.0/16"  # Virtual network CIDR
    subnet_config:
      - name: "app-subnet"             # Subnet name
        address_prefix: "10.1.1.0/24"  # Subnet CIDR
      - name: "data-subnet"
        address_prefix: "10.1.2.0/24"
  
  monitoring:
    log_retention_days: 30             # 30-730 days
    alerts:
      - name: "high-cpu"              # Alert name
        threshold: 80                  # Threshold value
        window: "5m"                  # Time window (e.g., 5m, 1h)
      - name: "memory-pressure"
        threshold: 90
        window: "5m"

  security:
    allowed_ips: ["10.0.0.0/8"]       # Allowed IP ranges
```

4. Create a pull request with your changes:
```bash
git checkout -b add-your-product-infrastructure
git add terraform/products/your-product-name/
git commit -m "Add infrastructure configuration for your-product-name"
git push origin add-your-product-infrastructure
```

## Workflow

1. When you create a pull request:
   - The configuration is automatically validated
   - Terraform plan is generated and added as a comment
   - Infrastructure team reviews the changes

2. After approval and merge:
   - Infrastructure is automatically provisioned
   - You'll receive access credentials via secure channel
   - Monitoring is automatically configured

## Configuration Guidelines

### Compute
- Choose VM sizes based on your workload requirements
- Start with minimum instances needed
- Consider high availability for production

### Networking
- Use non-overlapping CIDR ranges
- Plan subnet sizes for future growth
- Follow security best practices

### Monitoring
- Configure meaningful alert thresholds
- Use appropriate time windows
- Set up alerts for critical metrics

### Security
- Restrict IP ranges appropriately
- Follow least privilege principle
- Enable required security features

## Support

For assistance:
1. Infrastructure issues: Create a GitHub issue
2. Configuration help: Contact the infrastructure team
3. Emergency: Use the on-call support channel

## FAQ

**Q: Can I modify the configuration after deployment?**
A: Yes, update the config.yaml and create a PR. Changes will be reviewed and applied.

**Q: How long does deployment take?**
A: Typically 15-30 minutes after PR merge.

**Q: Can I request custom configurations?**
A: Yes, discuss with the infrastructure team for special requirements.

**Q: How do I access my resources?**
A: Access details will be provided securely after deployment.

## Best Practices

1. **Configuration Management**
   - Keep configurations simple and clear
   - Document special requirements
   - Use meaningful names

2. **Resource Planning**
   - Right-size your resources
   - Consider cost implications
   - Plan for scaling

3. **Security**
   - Follow security guidelines
   - Restrict access appropriately
   - Review regularly

4. **Monitoring**
   - Set meaningful alerts
   - Monitor resource usage
   - Review and adjust thresholds 