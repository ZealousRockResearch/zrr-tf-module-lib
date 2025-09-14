# Basic Key Vault Example

This example demonstrates the basic usage of the Azure Key Vault module with minimal configuration and secure defaults.

## Features Demonstrated

- Basic Key Vault creation with standard SKU
- RBAC authorization enabled
- Purge protection enabled
- Secure defaults for all security settings
- Basic tagging strategy

## Usage

1. Copy the `terraform.tfvars.example` file to `terraform.tfvars`
2. Modify the values in `terraform.tfvars` as needed
3. Run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

## What This Creates

- Azure Key Vault with standard SKU
- Automatically created resource group (unless specified)
- Basic security configuration with RBAC
- Common tags applied to all resources

## Configuration

The example uses the following default configuration:

- **SKU**: Standard (cost-effective for most use cases)
- **RBAC**: Enabled (recommended for modern Azure environments)
- **Purge Protection**: Enabled (prevents accidental permanent deletion)
- **Soft Delete**: 90 days retention
- **Public Access**: Enabled (can be restricted via network ACLs)

## Customization

To customize this example:

1. Uncomment sections in `terraform.tfvars.example`
2. Add your specific configuration values
3. Consider the advanced example for more complex scenarios

## Security Considerations

This basic example enables:
- RBAC authorization for better security
- Purge protection to prevent accidental deletion
- Soft delete with 90-day retention
- Proper tagging for governance

For production environments, consider:
- Enabling network restrictions
- Using private endpoints
- Setting up diagnostic logging
- Implementing proper key rotation policies