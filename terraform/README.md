<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.117.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_registry.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_key_vault.platform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_log_analytics_workspace.platform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_action_group.platform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |
| [azurerm_resource_group.platform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_storage_account.artifacts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_email"></a> [alert\_email](#input\_alert\_email) | Email address for alerts | `string` | `"devops@example.com"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (dev, test, prod) | `string` | `"prod"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region to deploy resources | `string` | `"swedencentral"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to use for resource names | `string` | `"mvpops"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | `"mvpops-production-rg-test"` | no |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | Name of the team owning the resource | `string` | `"mvpops"` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Azure AD tenant ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acr_login_server"></a> [acr\_login\_server](#output\_acr\_login\_server) | The login server URL for the Azure Container Registry |
| <a name="output_acr_name"></a> [acr\_name](#output\_acr\_name) | The name of the Azure Container Registry |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | The name of the Key Vault |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | The URI of the Key Vault |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The ID of the Log Analytics Workspace |
| <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name) | The name of the Log Analytics Workspace |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The ID of the resource group |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account |

# Terraform Configuration

## Environment Variables

To configure the Terraform state backend, set the following environment variables:

Required:
- `TF_STATE_RESOURCE_GROUP`: Resource group name for Terraform state
- `TF_STATE_STORAGE_ACCOUNT`: Storage account name for Terraform state

Optional (with defaults):
- `TF_STATE_CONTAINER`: Container name for Terraform state (default: "tfstate")
- `TF_STATE_KEY`: State file name (default: "terraform.tfstate")
- `TF_LOCK_TIMEOUT`: Lock timeout duration (default: "300s")

You can set these variables in your PowerShell session:

```powershell
$env:TF_STATE_RESOURCE_GROUP = "your-resource-group"
$env:TF_STATE_STORAGE_ACCOUNT = "your-storage-account"
```

Or create a .env file in the root directory with these variables.

## Initialize Terraform

After setting the environment variables, run:

```powershell
# Process backend configuration
./terraform/scripts/process-backend-config.ps1

# Initialize Terraform
terraform init -backend-config=terraform/backend.conf.local
```

## Managing State Locks

If you encounter state lock issues, use the fix-terraform-lock script:

```powershell
./fix-terraform-lock.ps1 -Force
```
<!-- END_TF_DOCS -->