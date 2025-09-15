# Advanced Example - Azure MySQL Database

This example demonstrates the full enterprise-grade usage of the Azure MySQL Database module with comprehensive configuration for production workloads.

## Overview

This advanced example creates:
- A primary MySQL database with enterprise configuration
- Multiple additional databases for different purposes
- Database users with granular privilege management (Single Server only)
- Advanced performance tuning and optimization
- Comprehensive monitoring and alerting
- Network security with VNet integration
- Audit logging and compliance features
- Enterprise-grade tagging for governance

## Prerequisites

Before running this example, you need:

1. An existing Azure MySQL Single Server (for full feature demonstration)
2. Azure Virtual Network with database subnet
3. Azure Monitor Action Group for alerts
4. Appropriate permissions to create databases and users
5. Strong passwords for database users

## Network Configuration

For production deployments, this example requires:

```hcl
# Example network configuration (not included in this module)
resource "azurerm_virtual_network" "database_vnet" {
  name                = "database-vnet"
  location            = "East US"
  resource_group_name = "production-rg"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "database_subnet" {
  name                 = "database-subnet"
  resource_group_name  = "production-rg"
  virtual_network_name = azurerm_virtual_network.database_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.Sql"]
}
```

## Usage

1. Copy the `terraform.tfvars.example` file to `terraform.tfvars`:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and configure all required values:
   ```hcl
   database_name       = "primary_db"
   resource_group_name = "production-rg"
   mysql_server_name   = "production-mysql-server"
   use_flexible_server = false

   # Network configuration
   subnet_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/virtualNetworks/xxx/subnets/database-subnet"

   # Monitoring configuration
   action_group_id = "/subscriptions/xxx/resourceGroups/xxx/providers/microsoft.insights/actionGroups/database-alerts"
   ```

3. Initialize and apply the Terraform configuration:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Enterprise Configuration

The advanced example includes these production-ready features:

### Multiple Databases
- **Primary Database**: Main application database
- **Analytics Database**: For data analytics and reporting
- **Logging Database**: For application logs and audit trails
- **Reporting Database**: For business intelligence
- **Staging Database**: For testing and staging operations

### User Management (Single Server Only)
- **Application User**: Full CRUD operations on primary database
- **Analytics User**: Read/write access to analytics database
- **Read-Only User**: Read access across multiple databases
- **Backup User**: Special privileges for backup operations

### Performance Optimization
- **Memory Configuration**: Optimized InnoDB buffer pool settings
- **Connection Management**: Tuned connection limits and timeouts
- **Query Performance**: Slow query logging and optimization
- **InnoDB Settings**: Production-optimized InnoDB parameters

### Security Features
- **Network Isolation**: VNet service endpoint integration
- **Audit Logging**: Comprehensive audit trail for compliance
- **User Privileges**: Granular privilege management
- **Encryption**: Encryption at rest and in transit

### Monitoring & Alerting
- **Connection Monitoring**: Alerts when connections exceed threshold
- **Storage Monitoring**: Alerts for storage usage
- **Performance Monitoring**: Slow query detection
- **Email Notifications**: Multi-recipient alert distribution

### Compliance Features
- **Audit Logging**: CONNECTION, DML, DDL, and DCL events
- **Data Retention**: Configurable log retention policies
- **Access Control**: Role-based database access
- **Change Tracking**: Complete audit trail of schema changes

## Performance Tuning

The example includes production-optimized MySQL configurations:

```hcl
performance_configurations = {
  # Memory and buffer settings (75% of available memory)
  innodb_buffer_pool_size = "75"
  innodb_log_file_size    = "512"

  # Connection settings
  max_connections      = "200"
  max_user_connections = "190"
  wait_timeout         = "28800"
  interactive_timeout  = "28800"

  # Query performance
  slow_query_log      = "ON"
  long_query_time     = "2"
  query_cache_type    = "OFF"

  # InnoDB optimization
  innodb_lock_wait_timeout = "50"
  innodb_flush_log_at_trx_commit = "1"

  # Security
  sql_mode = "STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO"
}
```

## Database Users and Privileges

Example user configuration with different access levels:

```hcl
database_users = [
  {
    username = "app_user"
    password = "VerySecurePassword123!"
    privileges = [
      { type = "SELECT", database = "primary_db" },
      { type = "INSERT", database = "primary_db" },
      { type = "UPDATE", database = "primary_db" },
      { type = "DELETE", database = "primary_db" }
    ]
  },
  {
    username = "readonly_user"
    password = "ReadOnlySecure789!"
    privileges = [
      { type = "SELECT", database = "primary_db" },
      { type = "SELECT", database = "analytics_db" },
      { type = "SELECT", database = "reporting_db" }
    ]
  }
]
```

## Monitoring Setup

The example configures comprehensive monitoring:

### Metric Alerts
- **Connection Usage**: Alert at 150 concurrent connections
- **Storage Usage**: Alert at 85% storage capacity
- **Performance**: Slow query detection and alerting

### Audit Logging
- **Connection Events**: User login/logout tracking
- **DML Operations**: INSERT, UPDATE, DELETE tracking
- **DDL Operations**: Schema change tracking
- **DCL Operations**: Permission change tracking

## Character Set and Collation

### Production Recommendations
- **Character Set**: `utf8mb4` for full Unicode support including emojis
- **Collation**: `utf8mb4_unicode_ci` for Unicode-aware, case-insensitive sorting

### Alternative Configurations
```hcl
# For legacy applications
charset   = "latin1"
collation = "latin1_swedish_ci"

# For case-sensitive applications
charset   = "utf8mb4"
collation = "utf8mb4_bin"

# For MySQL 8.0+ with accent-insensitive sorting
charset   = "utf8mb4"
collation = "utf8mb4_0900_ai_ci"
```

## Network Security

### VNet Integration
- Service endpoint configuration for secure database access
- Private networking without public internet exposure
- Network security group integration

### Firewall Configuration
- IP-based access control
- Service endpoint routing
- Secure application connectivity

## Compliance and Governance

### Enterprise Tagging
```hcl
common_tags = {
  Environment = "production"
  Project     = "enterprise-database"
  Owner       = "platform-team"
  Compliance  = "SOX"
  DataClass   = "confidential"
}
```

### Audit Requirements
- Complete audit trail for all database operations
- User access logging and monitoring
- Schema change tracking
- Performance monitoring and optimization

## Connection Examples

### Application Connection
```bash
# Using application user
mysql -h production-mysql-server.mysql.database.azure.com \
      -u app_user@production-mysql-server \
      -p -D primary_db
```

### Read-Only Access
```bash
# Using read-only user
mysql -h production-mysql-server.mysql.database.azure.com \
      -u readonly_user@production-mysql-server \
      -p -D primary_db
```

### Analytics Connection
```bash
# Using analytics user
mysql -h production-mysql-server.mysql.database.azure.com \
      -u analytics_user@production-mysql-server \
      -p -D analytics_db
```

## Cost Optimization

This configuration balances performance and cost:
- Optimized connection pooling to reduce resource usage
- Efficient memory allocation for InnoDB buffer pool
- Query cache disabled for better performance in high-write scenarios
- Appropriate storage monitoring to prevent unnecessary growth

## Backup and Recovery

### Built-in Backup Features
- Automatic backup with configurable retention
- Point-in-time restore capabilities
- Geo-redundant backup options
- Backup monitoring and alerting

### Best Practices
- Regular backup verification
- Recovery testing procedures
- Backup retention policy compliance
- Cross-region backup replication

## Clean Up

To remove all databases and configurations:

```bash
terraform destroy
```

**Note**: This will remove all databases, users, and configurations. Ensure you have proper backups before destruction.

## Next Steps

For additional customization:
1. Review the [basic example](../basic/) for simpler configurations
2. Customize performance parameters for your specific workload
3. Implement additional monitoring dashboards
4. Set up automated backup verification
5. Configure disaster recovery procedures
6. Implement application-specific database schemas
7. Set up development and staging environment mirrors