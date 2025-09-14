# Basic Example - Azure MySQL Flexible Server

This example demonstrates the basic usage of the Azure MySQL Flexible Server module with minimal configuration.

## Overview

This example creates:
- An Azure MySQL Flexible Server with basic configuration
- Standard backup retention (7 days)
- Public network access (suitable for development/testing)
- Basic tagging and metadata

## Prerequisites

Before running this example, you need:

1. An existing Azure Resource Group
2. Appropriate Azure permissions to create MySQL servers
3. A secure administrator password

## Usage

1. Copy the `terraform.tfvars.example` file to `terraform.tfvars`:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and set the required values:
   ```hcl
   resource_group_name    = "your-resource-group"
   administrator_password = "YourSecurePassword123!"
   ```

3. Initialize and apply the Terraform configuration:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

The basic example uses these default settings:

- **Server Name**: `example-mysql` (configurable)
- **SKU**: GP_Standard_D2ds_v4 (General Purpose, 2 vCores)
- **MySQL Version**: 8.0.21
- **Storage**: 100 GB with auto-grow enabled
- **Backup Retention**: 7 days
- **High Availability**: Disabled
- **Network Access**: Public (development use)

## Outputs

After applying, you'll get these outputs:

- `mysql_server_id` - The Azure resource ID of the MySQL server
- `mysql_server_name` - The name of the created MySQL server
- `mysql_server_fqdn` - The fully qualified domain name for connections
- `connection_string` - MySQL connection string (marked as sensitive)

## Security Considerations

This basic example includes:
- Public network access for simplicity
- Basic firewall rules
- Standard backup retention

For production use, consider the [advanced example](../advanced/) which includes:
- Private networking with subnet delegation
- Enhanced security features
- High availability configuration
- Advanced monitoring and alerting

## Connection

Once deployed, you can connect to your MySQL server using:

```bash
# Using MySQL CLI
mysql -h <mysql_server_fqdn> -u mysqladmin -p

# Using connection string from output
# See the sensitive connection_string output for full details
```

## Clean Up

To remove all resources created by this example:

```bash
terraform destroy
```

## Next Steps

For more advanced configurations, see the [advanced example](../advanced/) which includes:
- High availability with zone redundancy
- Private networking and security
- Custom database creation
- Monitoring and alerting
- Advanced backup policies