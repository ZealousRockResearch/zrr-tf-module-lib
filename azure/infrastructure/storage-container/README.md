# Azure Infrastructure - Storage Container

This module manages Azure Storage Containers with comprehensive security features, lifecycle management, and enterprise governance capabilities following ZRR standards.

## Features

- **Container Management**: Full lifecycle management of Azure Storage containers with configurable access levels
- **Flexible Storage Account Reference**: Supports both storage account ID and name-based lookups
- **Access Control**: Configurable container access types (private, blob, container) for security compliance
- **Lifecycle Management**: Advanced lifecycle rules for automatic blob tiering and deletion policies
- **Legal Hold Support**: Enterprise-grade legal hold capabilities for compliance and litigation requirements
- **Immutability Policies**: Time-based retention policies for regulatory compliance and data protection
- **Metadata Management**: Custom metadata support for enhanced organization and governance
- **Security Features**: Comprehensive security controls including access policies and retention management
- **Enterprise Tagging**: Automatic application of common and resource-specific tags following ZRR standards
- **Validation**: Extensive input validation ensuring Azure naming conventions and best practices
- **Monitoring Ready**: Structured outputs for integration with monitoring and alerting systems
- **Compliance**: Built-in features for regulatory compliance including WORM (Write Once, Read Many) capabilities

## Usage

### Basic Example

```hcl
module "app_data_container" {
  source = "../../azure/infrastructure/storage-container"

  name                 = "app-data"
  storage_account_name = "mystorageaccount"
  storage_account_resource_group_name = "storage-rg"
  container_access_type = "private"

  common_tags = {
    Environment = "prod"
    Project     = "myapp"
    Owner       = "platform-team"
  }
}
```

### Advanced Example with Lifecycle Management

```hcl
module "archive_container" {
  source = "../../azure/infrastructure/storage-container"

  name                 = "long-term-archive"
  storage_account_id   = azurerm_storage_account.main.id
  container_access_type = "private"

  metadata = {
    environment = "production"
    project     = "data-archive"
    owner       = "data-team"
    purpose     = "long-term-storage"
  }

  lifecycle_rules = [
    {
      name         = "archive-policy"
      enabled      = true
      prefix_match = ["logs/", "backups/"]
      blob_types   = ["blockBlob"]
      tier_to_cool_after_days    = 30
      tier_to_archive_after_days = 90
      delete_after_days          = 2555  # 7 years
    }
  ]

  immutability_policy = {
    period_in_days = 2555  # 7 years
    locked         = true
  }

  common_tags = {
    Environment = "prod"
    Project     = "compliance"
    DataClass   = "sensitive"
  }
}
```

### Legal Hold Example

```hcl
module "legal_container" {
  source = "../../azure/infrastructure/storage-container"

  name                 = "legal-documents"
  storage_account_name = "legalstorage"
  storage_account_resource_group_name = "legal-rg"

  legal_hold = {
    tags = ["litigation-2024", "compliance-audit"]
  }

  common_tags = {
    Environment = "prod"
    Project     = "legal"
    Compliance  = "required"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_container.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_management_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_storage_account.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the storage container | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to be applied to all resources | `map(string)` | <pre>{<br>  "Environment": "dev",<br>  "ManagedBy": "Terraform",<br>  "Project": "zrr"<br>}</pre> | no |
| <a name="input_container_access_type"></a> [container\_access\_type](#input\_container\_access\_type) | The access level configured for this container | `string` | `"private"` | no |
| <a name="input_immutability_policy"></a> [immutability\_policy](#input\_immutability\_policy) | Configuration for immutability policy on the container | <pre>object({<br>    period_in_days = number<br>    locked         = bool<br>  })</pre> | `null` | no |
| <a name="input_legal_hold"></a> [legal\_hold](#input\_legal\_hold) | Configuration for legal hold on the container | <pre>object({<br>    tags = list(string)<br>  })</pre> | `null` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | List of lifecycle management rules for the container | <pre>list(object({<br>    name                       = string<br>    enabled                    = bool<br>    prefix_match               = list(string)<br>    blob_types                 = list(string)<br>    tier_to_cool_after_days    = optional(number)<br>    tier_to_archive_after_days = optional(number)<br>    delete_after_days          = optional(number)<br>    snapshot_delete_after_days = optional(number)<br>    version_delete_after_days  = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | A map of custom metadata to assign to the storage container | <pre>object({<br>    environment = optional(string)<br>    project     = optional(string)<br>    owner       = optional(string)<br>    purpose     = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | Resource ID of the storage account | `string` | `null` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the storage account | `string` | `null` | no |
| <a name="input_storage_account_resource_group_name"></a> [storage\_account\_resource\_group\_name](#input\_storage\_account\_resource\_group\_name) | Resource group name of the storage account (required when using storage\_account\_name) | `string` | `null` | no |
| <a name="input_storage_container_tags"></a> [storage\_container\_tags](#input\_storage\_container\_tags) | Additional tags specific to the storage container | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_access_type"></a> [container\_access\_type](#output\_container\_access\_type) | The access type of the container |
| <a name="output_container_url"></a> [container\_url](#output\_container\_url) | The URL of the storage container |
| <a name="output_id"></a> [id](#output\_id) | The ID of the storage container |
| <a name="output_immutability_period_days"></a> [immutability\_period\_days](#output\_immutability\_period\_days) | The immutability period in days (if configured) |
| <a name="output_immutability_policy_enabled"></a> [immutability\_policy\_enabled](#output\_immutability\_policy\_enabled) | Whether immutability policy is configured for the container |
| <a name="output_immutability_policy_locked"></a> [immutability\_policy\_locked](#output\_immutability\_policy\_locked) | Whether the immutability policy is locked (if configured) |
| <a name="output_legal_hold_enabled"></a> [legal\_hold\_enabled](#output\_legal\_hold\_enabled) | Whether legal hold is configured for the container |
| <a name="output_legal_hold_tags"></a> [legal\_hold\_tags](#output\_legal\_hold\_tags) | The legal hold tags (if configured) |
| <a name="output_lifecycle_rules_count"></a> [lifecycle\_rules\_count](#output\_lifecycle\_rules\_count) | The number of lifecycle rules configured |
| <a name="output_management_policy_id"></a> [management\_policy\_id](#output\_management\_policy\_id) | The ID of the storage management policy (if created) |
| <a name="output_metadata"></a> [metadata](#output\_metadata) | The metadata assigned to the storage container |
| <a name="output_name"></a> [name](#output\_name) | The name of the storage container |
| <a name="output_resource_manager_id"></a> [resource\_manager\_id](#output\_resource\_manager\_id) | The Resource Manager ID of the storage container |
| <a name="output_security_features"></a> [security\_features](#output\_security\_features) | Summary of security features enabled on the container |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account containing the container |