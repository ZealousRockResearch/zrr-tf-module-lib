# Advanced Example - Azure MySQL Flexible Server

This example demonstrates the full enterprise-grade usage of the Azure MySQL Flexible Server module with comprehensive configuration for production workloads.

## Overview

This advanced example creates:
- An Azure MySQL Flexible Server with enterprise configuration
- High availability with zone redundancy (ZoneRedundant)
- Enhanced backup retention (35 days) with geo-redundancy
- Private networking with subnet delegation
- Customer-managed encryption (optional)
- Multiple databases with specific charset/collation
- Advanced MySQL server configurations
- Firewall rules for secure access
- Azure AD administrator (optional)
- Scheduled maintenance window
- Private endpoint for enhanced security
- Comprehensive monitoring and alerting
- Diagnostic settings for audit and performance logs
- Enterprise-grade tagging for governance

## Prerequisites

Before running this example, you need:

1. An existing Azure Resource Group
2. Azure Virtual Network with properly configured subnets:
   - Delegated subnet for MySQL server
   - Private endpoint subnet (if using private endpoints)
3. Private DNS zone for MySQL (if using private networking)
4. User-assigned managed identity (if using customer-managed keys)
5. Azure Key Vault with encryption key (if using customer-managed encryption)
6. Log Analytics workspace (if enabling diagnostic settings)
7. Appropriate Azure permissions to create all resources

## Network Configuration

For production deployments, this example requires:

```hcl
# Example network configuration (not included in this module)
resource "azurerm_virtual_network" "mysql_vnet" {
  name                = "mysql-vnet"
  location            = "East US"
  resource_group_name = "production-rg"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "mysql_subnet" {
  name                 = "mysql-subnet"
  resource_group_name  = "production-rg"
  virtual_network_name = azurerm_virtual_network.mysql_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "mysql-delegation"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "mysql_dns" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = "production-rg"
}
```

## Usage

1. Copy the `terraform.tfvars.example` file to `terraform.tfvars`:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and configure all required values:
   ```hcl
   resource_group_name = "production-rg"
   administrator_password = "VerySecurePassword123!"

   # Network configuration
   delegated_subnet_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/virtualNetworks/xxx/subnets/mysql-subnet"
   private_dns_zone_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/privateDnsZones/privatelink.mysql.database.azure.com"

   # Optional: Customer-managed encryption
   # customer_managed_key_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.KeyVault/vaults/xxx/keys/xxx"
   # identity_ids = ["/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mysql-identity"]

   # Optional: Monitoring
   # log_analytics_workspace_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.OperationalInsights/workspaces/xxx"
   ```

3. Initialize and apply the Terraform configuration:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Enterprise Configuration

The advanced example includes these production-ready features:

### High Availability
- **Mode**: ZoneRedundant for automatic failover
- **Standby Zone**: Configured in different availability zone
- **Recovery**: Automatic failover and point-in-time restore

### Security
- **Network**: Private networking with subnet delegation
- **Access**: Disabled public network access
- **Encryption**: Support for customer-managed keys
- **Identity**: User-assigned managed identity
- **Firewall**: Restricted access rules

### Performance
- **SKU**: Memory Optimized (MO_Standard_E4ds_v4) with 4 vCores and 32GB RAM
- **Storage**: 1TB with 3000 IOPS
- **Configuration**: Optimized MySQL parameters for production workloads

### Monitoring & Alerting
- **Metrics**: CPU, memory, and connection monitoring
- **Alerts**: Email notifications for threshold breaches
- **Diagnostics**: Audit logs and slow query logs
- **Retention**: 90-day log retention for compliance

### Backup & Recovery
- **Retention**: 35 days (maximum supported)
- **Geo-redundancy**: Enabled for disaster recovery
- **Point-in-time**: Restore capability within retention period

## Outputs

After applying, you'll get comprehensive outputs including:

- `mysql_server_id` - Azure resource ID
- `mysql_server_fqdn` - Connection endpoint
- `high_availability_enabled` - HA status
- `databases` - Created database details
- `private_endpoint_id` - Private endpoint resource ID
- `action_group_id` - Monitor action group for alerts
- `connection_string` - MySQL connection string (sensitive)
- Complete monitoring and diagnostic resource IDs

## Security Considerations

This advanced example implements enterprise security:

### Network Security
- Private subnet delegation for MySQL server
- No public network access
- Private endpoint for additional isolation
- Private DNS zone for name resolution

### Data Security
- Customer-managed encryption at rest (optional)
- TLS encryption in transit
- Azure AD authentication (optional)
- Comprehensive audit logging

### Access Control
- Firewall rules for IP-based access control
- Azure AD integration for identity management
- User-assigned managed identity
- Role-based access control (RBAC)

## Performance Tuning

The example includes production-optimized MySQL configurations:

```hcl
server_configurations = {
  # Buffer pool (75% of available memory)
  "innodb_buffer_pool_size" = "75"

  # Connection limits
  "max_connections" = "200"
  "max_user_connections" = "190"

  # Query performance
  "slow_query_log" = "ON"
  "long_query_time" = "2"

  # InnoDB settings
  "innodb_lock_wait_timeout" = "50"
  "innodb_log_file_size" = "512"

  # Security
  "sql_mode" = "STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO"
}
```

## Monitoring Setup

The example configures comprehensive monitoring:

### Metric Alerts
- **CPU Utilization**: Alert at 85%
- **Memory Usage**: Alert at 90%
- **Active Connections**: Alert at 150 connections

### Diagnostic Logs
- MySQL slow query logs
- MySQL audit logs
- All metrics with 90-day retention

### Action Groups
- Email notifications to multiple recipients
- Escalation procedures for critical alerts

## Maintenance

Scheduled maintenance window:
- **Day**: Sunday (day 0)
- **Time**: 2:00 AM UTC
- **Duration**: Automatic based on update requirements

## Connection Examples

### Using MySQL CLI
```bash
# Private connection (from within VNet or via VPN)
mysql -h production-mysql-server.privatelink.mysql.database.azure.com -u mysqladmin -p

# Connect to specific database
mysql -h production-mysql-server.privatelink.mysql.database.azure.com -u mysqladmin -p -D app_db
```

### Application Connection String
```bash
# Use the sensitive connection_string output
terraform output -raw connection_string
```

## Cost Optimization

This configuration is optimized for production with:
- Memory Optimized SKU for performance
- Storage auto-grow enabled for cost efficiency
- 35-day backup retention for compliance
- Zone redundancy for availability

## Compliance Features

The advanced example supports enterprise compliance:
- **SOX Compliance**: Comprehensive audit logging
- **Data Governance**: Detailed tagging strategy
- **Backup Policies**: Long-term retention
- **Access Control**: RBAC and Azure AD integration
- **Encryption**: Customer-managed keys
- **Monitoring**: Real-time alerting and diagnostics

## Clean Up

To remove all resources:

```bash
terraform destroy
```

**Note**: Ensure you have backups of critical data before destroying resources.

## Next Steps

For additional customization:
1. Review the [basic example](../basic/) for simpler configurations
2. Customize server configurations for your workload
3. Implement additional monitoring dashboards
4. Set up automated backup verification
5. Configure disaster recovery procedures