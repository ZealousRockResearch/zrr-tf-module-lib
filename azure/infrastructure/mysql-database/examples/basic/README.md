# Basic Example - Azure MySQL Database

This example demonstrates the basic usage of the Azure MySQL Database module with minimal configuration.

## Overview

This example creates:
- A MySQL database on an existing Azure MySQL server
- UTF-8 character set with Unicode collation (default)
- Basic tagging for identification and governance

## Prerequisites

Before running this example, you need:

1. An existing Azure MySQL server (either Flexible Server or Single Server)
2. Appropriate permissions to create databases on the MySQL server
3. The resource group containing the MySQL server

## Usage

1. Copy the `terraform.tfvars.example` file to `terraform.tfvars`:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and configure your MySQL server details:

   **For MySQL Flexible Server (Recommended):**
   ```hcl
   database_name            = "my_application_db"
   resource_group_name      = "my-resource-group"
   mysql_flexible_server_id = "/subscriptions/.../flexibleServers/my-mysql-server"
   use_flexible_server      = true
   ```

   **For MySQL Single Server (Legacy):**
   ```hcl
   database_name       = "my_application_db"
   resource_group_name = "my-resource-group"
   mysql_server_id     = "/subscriptions/.../servers/my-mysql-server"
   use_flexible_server = false
   ```

   **Using Server Name (when in same resource group):**
   ```hcl
   database_name       = "my_application_db"
   resource_group_name = "my-resource-group"
   mysql_server_name   = "my-mysql-server"
   use_flexible_server = true
   ```

3. Initialize and apply the Terraform configuration:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

The basic example uses these default settings:

- **Database Name**: `example_db` (configurable)
- **Character Set**: `utf8mb4` (Unicode with emoji support)
- **Collation**: `utf8mb4_unicode_ci` (Unicode-aware, case-insensitive)
- **Server Type**: MySQL Flexible Server (recommended)

## Character Sets and Collations

### Common Character Sets
- `utf8mb4` - Full Unicode including emojis (recommended)
- `utf8` - Unicode basic multilingual plane
- `latin1` - Western European characters
- `ascii` - Basic ASCII only

### Common Collations for utf8mb4
- `utf8mb4_unicode_ci` - Unicode-aware, case-insensitive (recommended)
- `utf8mb4_general_ci` - General purpose, case-insensitive
- `utf8mb4_bin` - Binary collation, case-sensitive
- `utf8mb4_0900_ai_ci` - MySQL 8.0+ accent-insensitive

## Outputs

After applying, you'll get these outputs:

- `database_id` - The Azure resource ID of the database
- `database_name` - The name of the created database
- `server_name` - The name of the MySQL server
- `server_type` - Type of server (flexible or single)
- `charset` - Character set used
- `collation` - Collation used
- `database_summary` - Comprehensive configuration summary

## Server Type Differences

### MySQL Flexible Server (Recommended)
- Latest Azure MySQL offering
- Better performance and features
- Enhanced security and networking
- Supports availability zones

### MySQL Single Server (Legacy)
- Original Azure MySQL offering
- Still supported but not recommended for new deployments
- Limited features compared to Flexible Server

## Best Practices

1. **Use UTF-8**: Always use `utf8mb4` character set for new applications
2. **Choose Collation Carefully**: Use `utf8mb4_unicode_ci` for most applications
3. **Resource Naming**: Use consistent naming conventions for databases
4. **Tagging**: Apply consistent tags for governance and cost tracking

## Connecting to the Database

Once deployed, you can connect to your database using:

```bash
# For MySQL Flexible Server
mysql -h <server-name>.mysql.database.azure.com -u <username> -p -D <database-name>

# For MySQL Single Server
mysql -h <server-name>.mysql.database.azure.com -u <username>@<server-name> -p -D <database-name>
```

## Clean Up

To remove the database:

```bash
terraform destroy
```

**Note**: This will only remove the database, not the MySQL server itself.

## Next Steps

For more advanced configurations, see the [advanced example](../advanced/) which includes:
- Multiple databases
- User management and privileges
- Performance configurations
- Monitoring and alerting
- Audit logging
- Network security