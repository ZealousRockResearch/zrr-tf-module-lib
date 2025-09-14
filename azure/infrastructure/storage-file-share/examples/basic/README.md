# Basic Example - Azure Storage File Share

This example demonstrates the basic usage of the Azure Storage File Share module with minimal configuration.

## Overview

This example creates:
- An Azure File Share with basic configuration
- Default backup enabled with daily retention
- Basic tagging and metadata

## Prerequisites

Before running this example, you need:

1. An existing Azure Storage Account
2. An existing Resource Group
3. Appropriate Azure permissions to create file shares and backup resources

## Usage

1. Copy the `terraform.tfvars.example` file to `terraform.tfvars`:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and set the required values:
   ```hcl
   storage_account_name = "your-existing-storage-account"
   resource_group_name  = "your-resource-group"
   ```

3. Initialize and apply the Terraform configuration:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

The basic example uses these default settings:

- **File Share Name**: `example-share` (configurable)
- **Quota**: 100 GB
- **Access Tier**: Hot
- **Protocol**: SMB
- **Backup**: Enabled with 30-day retention
- **Location**: East US

## Outputs

After applying, you'll get these outputs:

- `file_share_id` - The Azure resource ID of the file share
- `file_share_name` - The name of the created file share
- `file_share_url` - The URL to access the file share
- `backup_vault_id` - The ID of the backup vault (if backup is enabled)

## Clean Up

To remove all resources created by this example:

```bash
terraform destroy
```

## Next Steps

For more advanced configurations, see the [advanced example](../advanced/) which includes:
- Custom directories and metadata
- Advanced backup policies
- Monitoring and alerting
- Private endpoints
- Access policies