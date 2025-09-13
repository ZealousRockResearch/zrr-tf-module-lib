# Azure Shared - Key Vault

This Terraform module creates and manages an Azure Key Vault with comprehensive security features, access policies, secrets, keys, and certificates management. The module is designed for the shared layer in the ZRR enterprise architecture.

## Features

- **Secure Key Vault Creation**: Creates Azure Key Vault with configurable SKU (Standard/Premium)
- **Access Control**: Supports both RBAC and access policies for fine-grained permissions
- **Network Security**: Configurable network ACLs and private endpoint support
- **Secret Management**: Create and manage secrets with expiration dates and content types
- **Key Management**: Support for RSA, EC, and other key types with configurable sizes
- **Certificate Contacts**: Manage certificate notification contacts
- **Monitoring**: Diagnostic settings for logging and monitoring
- **Security Features**: Purge protection, soft delete, and disk encryption enablement
- **Private Networking**: Private endpoint with DNS zone group integration
- **Compliance**: Built-in security defaults and validation rules

## Usage

### Basic Example

```hcl
module "key_vault" {
  source = "../../azure/shared/key-vault"

  name     = "example-kv-001"
  location = "East US"

  common_tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

### Advanced Example with Secrets and Access Policies

```hcl
module "key_vault" {
  source = "../../azure/shared/key-vault"

  name                = "example-kv-001"
  location            = "East US"
  resource_group_name = "example-rg"

  sku_name                   = "premium"
  purge_protection_enabled   = true
  enable_rbac_authorization  = false

  access_policies = {
    admin = {
      object_id               = "00000000-0000-0000-0000-000000000000"
      key_permissions         = ["Get", "List", "Create", "Delete", "Update"]
      secret_permissions      = ["Get", "List", "Set", "Delete"]
      certificate_permissions = ["Get", "List", "Create", "Delete", "Update"]
    }
  }

  secrets = {
    database-connection-string = {
      value        = "Server=...;Database=...;Trusted_Connection=True;"
      content_type = "Connection String"
    }
  }

  keys = {
    encryption-key = {
      key_type = "RSA"
      key_size = 2048
      key_opts = ["encrypt", "decrypt", "sign", "verify", "wrapKey", "unwrapKey"]
    }
  }

  network_acls = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = ["203.0.113.0/24"]
    virtual_network_subnet_ids = ["/subscriptions/.../subnets/example"]
  }

  common_tags = {
    Environment = "prod"
    Project     = "example"
    Owner       = "security-team"
  }
}
```

## Requirements

- Terraform >= 1.0
- Azure Provider ~> 3.0

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name of the Key Vault | `string` | n/a | yes |
| `location` | Azure region where the Key Vault will be created | `string` | `"East US"` | no |
| `resource_group_name` | Name of the resource group. If not provided, a new resource group will be created | `string` | `null` | no |
| `sku_name` | The Name of the SKU used for this Key Vault. Possible values are standard and premium | `string` | `"standard"` | no |
| `enabled_for_disk_encryption` | Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys | `bool` | `false` | no |
| `enabled_for_deployment` | Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault | `bool` | `false` | no |
| `enabled_for_template_deployment` | Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault | `bool` | `false` | no |
| `enable_rbac_authorization` | Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions | `bool` | `true` | no |
| `purge_protection_enabled` | Is Purge Protection enabled for this Key Vault? | `bool` | `true` | no |
| `soft_delete_retention_days` | The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 days | `number` | `90` | no |
| `public_network_access_enabled` | Whether public network access is allowed for this Key Vault | `bool` | `true` | no |
| `network_acls` | Network ACLs configuration for the Key Vault | `object({...})` | `null` | no |
| `access_policies` | Map of access policies for the Key Vault | `map(object({...}))` | `{}` | no |
| `secrets` | Map of secrets to create in the Key Vault | `map(object({...}))` | `{}` | no |
| `keys` | Map of keys to create in the Key Vault | `map(object({...}))` | `{}` | no |
| `certificate_contacts` | List of certificate contacts for the Key Vault | `list(object({...}))` | `[]` | no |
| `private_endpoint` | Private endpoint configuration for the Key Vault | `object({...})` | `null` | no |
| `diagnostic_setting` | Diagnostic setting configuration for the Key Vault | `object({...})` | `null` | no |
| `common_tags` | Common tags to be applied to all resources | `map(string)` | `{"Environment" = "dev", "Project" = "zrr", "ManagedBy" = "Terraform"}` | no |
| `key_vault_tags` | Additional tags specific to the Key Vault | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id` | ID of the Key Vault |
| `name` | Name of the Key Vault |
| `uri` | URI of the Key Vault |
| `resource_group_name` | Name of the resource group containing the Key Vault |
| `location` | Location of the Key Vault |
| `tenant_id` | Tenant ID of the Key Vault |
| `secret_ids` | Map of secret names to their IDs |
| `secret_versions` | Map of secret names to their versions |
| `secret_version_ids` | Map of secret names to their version IDs |
| `key_ids` | Map of key names to their IDs |
| `key_versions` | Map of key names to their versions |
| `key_version_ids` | Map of key names to their version IDs |
| `private_endpoint_id` | ID of the private endpoint (if created) |
| `private_endpoint_ip_address` | Private IP address of the private endpoint (if created) |
| `diagnostic_setting_id` | ID of the diagnostic setting (if created) |
| `access_policy_object_ids` | List of object IDs that have access policies configured |
| `tags` | Tags applied to the Key Vault |

## Examples

- [Basic Example](./examples/basic/) - Simple Key Vault with secure defaults
- [Advanced Example](./examples/advanced/) - Production-ready configuration with all features

## Testing

This module includes comprehensive tests:

- **Unit Tests**: Variable validation and configuration testing
- **Integration Tests**: Full deployment and validation tests

To run tests:

```bash
# Unit tests
terraform test

# Integration tests (requires Go and Terratest)
cd tests/integration
go test -v
```

## Security Considerations

- RBAC authorization is enabled by default for better security
- Purge protection is enabled by default to prevent accidental deletion
- Soft delete is configured with 90-day retention
- Network ACLs can be configured to restrict access
- Private endpoints are supported for network isolation
- Diagnostic logging should be configured for audit trails

## Contributing

When contributing to this module:

1. Ensure all tests pass
2. Update documentation as needed
3. Follow the existing code style and conventions
4. Add tests for new features

## License

This module is part of the ZRR Terraform Module Library.