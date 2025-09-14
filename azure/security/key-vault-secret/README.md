# Azure Security - Key Vault Secret

This module manages Azure Key Vault secrets following ZRR enterprise standards and security best practices.

## Features

- **Secure Secret Management**: Stores sensitive values in Azure Key Vault with proper encryption
- **Flexible Key Vault Reference**: Supports both Key Vault ID and name-based lookups
- **Secret Lifecycle Management**: Configurable expiration dates and not-before dates
- **Content Type Support**: Optional content type specification for better secret organization
- **Enterprise Tagging**: Automatic application of common and resource-specific tags
- **Validation**: Comprehensive input validation for names, values, and dates
- **Ignore Changes**: Lifecycle rule to prevent accidental secret value updates

## Usage

### Basic Example

```hcl
module "database_password" {
  source = "../../azure/security/key-vault-secret"

  name           = "database-password"
  value          = var.database_password
  key_vault_id   = azurerm_key_vault.main.id

  common_tags = {
    Environment = "prod"
    Project     = "example"
    Owner       = "platform-team"
  }
}
```

### Using Key Vault Name Reference

```hcl
module "api_key" {
  source = "../../azure/security/key-vault-secret"

  name                           = "third-party-api-key"
  value                          = var.api_key
  key_vault_name                 = "my-keyvault"
  key_vault_resource_group_name  = "security-rg"
  content_type                   = "text/plain"

  expiration_date = "2025-12-31T23:59:59Z"

  common_tags = {
    Environment = "prod"
    Project     = "integration"
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
| [azurerm_key_vault_secret.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the key vault secret | `string` | n/a | yes |
| <a name="input_value"></a> [value](#input\_value) | The value of the key vault secret | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to be applied to all resources | `map(string)` | <pre>{<br>  "Environment": "dev",<br>  "ManagedBy": "Terraform",<br>  "Project": "zrr"<br>}</pre> | no |
| <a name="input_content_type"></a> [content\_type](#input\_content\_type) | Specifies the content type for the key vault secret | `string` | `null` | no |
| <a name="input_expiration_date"></a> [expiration\_date](#input\_expiration\_date) | Expiration UTC datetime (Y-m-d'T'H:M:S'Z') | `string` | `null` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | ID of the key vault to store the secret in | `string` | `null` | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | Name of the key vault to store the secret in | `string` | `null` | no |
| <a name="input_key_vault_resource_group_name"></a> [key\_vault\_resource\_group\_name](#input\_key\_vault\_resource\_group\_name) | Resource group name of the key vault (required when using key\_vault\_name) | `string` | `null` | no |
| <a name="input_key_vault_secret_tags"></a> [key\_vault\_secret\_tags](#input\_key\_vault\_secret\_tags) | Additional tags specific to the key vault secret | `map(string)` | `{}` | no |
| <a name="input_not_before_date"></a> [not\_before\_date](#input\_not\_before\_date) | Key not usable before the provided UTC datetime (Y-m-d'T'H:M:S'Z') | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of the key vault secret |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | ID of the key vault containing the secret |
| <a name="output_name"></a> [name](#output\_name) | Name of the key vault secret |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | The resource ID of the key vault secret |
| <a name="output_resource_versionless_id"></a> [resource\_versionless\_id](#output\_resource\_versionless\_id) | The versionless resource ID of the key vault secret |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the key vault secret |
| <a name="output_version"></a> [version](#output\_version) | The current version of the key vault secret |
| <a name="output_versionless_id"></a> [versionless\_id](#output\_versionless\_id) | The versionless ID of the key vault secret |