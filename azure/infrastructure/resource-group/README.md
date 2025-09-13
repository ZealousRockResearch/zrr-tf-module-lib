# Azure Infrastructure - Resource Group

This Terraform module creates and manages Azure Resource Groups with enterprise-grade features including tagging standards, resource locks, and budget alerts.

## Features

- ✅ Standardized naming convention support
- ✅ Comprehensive tagging strategy
- ✅ Optional resource locks (CanNotDelete or ReadOnly)
- ✅ Budget alerts with configurable thresholds
- ✅ Lifecycle management with destroy protection
- ✅ Multi-environment support (dev, test, staging, prod, dr)
- ✅ Input validation for all variables
- ✅ Complete output values for integration

## Usage

### Basic Example

```hcl
module "resource_group" {
  source = "../../azure/infrastructure/resource-group"
  
  name     = "my-application"
  location = "eastus"
  
  common_tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

### Advanced Example

```hcl
module "resource_group" {
  source = "../../azure/infrastructure/resource-group"
  
  name               = "critical-app"
  location           = "westeurope"
  environment        = "prod"
  location_short     = "weu"
  use_naming_convention = true
  
  # Enable resource protection
  prevent_destroy      = true
  enable_resource_lock = true
  lock_level          = "CanNotDelete"
  lock_notes          = "Production resource group - deletion requires approval"
  
  # Enable budget alerts
  enable_budget_alert         = true
  budget_amount              = 5000
  budget_time_grain          = "Monthly"
  budget_threshold_percentage = 80
  budget_contact_emails      = ["devops@example.com", "finance@example.com"]
  
  common_tags = {
    Environment = "prod"
    Project     = "critical-app"
    Owner       = "platform-team"
    CostCenter  = "engineering"
  }
  
  resource_group_tags = {
    Compliance = "PCI-DSS"
    Backup     = "enabled"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_management_lock.resource_group_lock](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_consumption_budget_resource_group.budget](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_resource_group) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the resource group | `string` | n/a | yes |
| location | Azure region where the resource group will be created | `string` | n/a | yes |
| environment | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| location_short | Short abbreviation for the Azure region | `string` | `""` | no |
| use_naming_convention | Use ZRR naming convention for resource group name | `bool` | `true` | no |
| common_tags | Common tags to be applied to all resources | `map(string)` | `{"Environment": "dev", "Project": "zrr", "ManagedBy": "Terraform"}` | no |
| resource_group_tags | Additional tags specific to the resource group | `map(string)` | `{}` | no |
| prevent_destroy | Prevent accidental deletion of the resource group | `bool` | `false` | no |
| enable_resource_lock | Enable resource lock on the resource group | `bool` | `false` | no |
| lock_level | Lock level for the resource group | `string` | `"CanNotDelete"` | no |
| lock_notes | Notes for the resource lock | `string` | `"Resource locked by Terraform to prevent accidental deletion"` | no |
| enable_budget_alert | Enable budget alert for the resource group | `bool` | `false` | no |
| budget_amount | Budget amount in USD | `number` | `1000` | no |
| budget_time_grain | Time grain for the budget | `string` | `"Monthly"` | no |
| budget_start_date | Start date for the budget in ISO 8601 format | `string` | `""` | no |
| budget_threshold_percentage | Threshold percentage for budget alert | `number` | `80` | no |
| budget_contact_emails | List of email addresses to notify | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | ID of the resource group |
| name | Name of the resource group |
| location | Location of the resource group |
| tags | Tags applied to the resource group |
| subscription_id | Subscription ID where the resource group is created |
| tenant_id | Tenant ID of the subscription |
| lock_id | ID of the resource lock (if enabled) |
| lock_level | Lock level applied to the resource group |
| budget_id | ID of the budget alert (if enabled) |
| budget_amount | Budget amount configured for the resource group |
| resource_group_urn | Uniform Resource Name for the resource group |
| is_locked | Boolean indicating if the resource group has a lock |
| has_budget_alert | Boolean indicating if the resource group has a budget alert |
<!-- END_TF_DOCS -->