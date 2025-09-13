# Azure SQL Database - Basic Example

This example demonstrates the basic usage of the Azure SQL Database module with minimal configuration.

## Features Demonstrated

- Basic Azure SQL Database creation
- Serverless SKU configuration
- Standard security settings (threat detection and auditing)
- Basic backup configuration
- Proper tagging strategy

## Prerequisites

- Existing Azure SQL Server
- Resource group containing the SQL Server
- Appropriate permissions to create databases

## Usage

1. Copy the `terraform.tfvars.example` file to `terraform.tfvars`
2. Update the variables with your specific values
3. Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

## Configuration

### Required Variables

- `sql_server_name`: Name of your existing Azure SQL Server
- `resource_group_name`: Resource group containing the SQL Server

### Optional Variables

All other variables have sensible defaults for a basic configuration:

- SKU: `GP_S_Gen5_1` (General Purpose Serverless, 1 vCore)
- Max Size: `2 GB`
- Security: Threat detection and auditing enabled
- Backups: 7-day retention with geo-redundancy

## Example Output

After successful deployment, you'll see outputs similar to:

```
database_id = "/subscriptions/.../resourceGroups/my-rg/providers/Microsoft.Sql/servers/my-server/databases/example-database"
database_name = "example-database"
server_id = "/subscriptions/.../resourceGroups/my-rg/providers/Microsoft.Sql/servers/my-server"
```

## Clean Up

```bash
terraform destroy
```

## Next Steps

- Review the [advanced example](../advanced/README.md) for more features
- Explore additional security configurations
- Consider implementing backup strategies based on your requirements