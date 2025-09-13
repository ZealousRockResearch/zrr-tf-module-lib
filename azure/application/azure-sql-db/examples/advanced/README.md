# Azure SQL Database - Advanced Example

This example demonstrates the advanced usage of the Azure SQL Database module with enterprise-grade configurations, including comprehensive security, monitoring, and backup features.

## Features Demonstrated

### Core Database Features
- High-performance General Purpose Gen5 SKU with multiple vCores
- Zone redundancy for high availability
- Read scale-out with multiple read replicas
- Large database size (500 GB)

### Security Features
- **Threat Detection**: Advanced threat protection with email notifications
- **Auditing**: Comprehensive database auditing with long-term retention
- **Encryption**: Transparent Data Encryption (TDE) enabled
- **Vulnerability Assessment**: Security vulnerability scanning and baseline management

### Backup and Recovery
- **Short-term Retention**: 14-day point-in-time recovery
- **Long-term Retention**: Weekly, monthly, and yearly backup retention policies
- **Geo-redundancy**: Geo-zone redundant storage for disaster recovery
- **Frequent Backups**: 12-hour backup intervals

### Monitoring and Diagnostics
- **Storage Account**: Dedicated storage for audit logs and threat detection
- **Log Analytics**: Centralized logging and monitoring workspace
- **Diagnostic Settings**: Comprehensive database metrics and logs
- **Query Insights**: Query store statistics and performance metrics

## Architecture

```
┌─────────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Azure SQL DB      │    │  Storage Account │    │ Log Analytics   │
│  - Enterprise SKU   │◄──►│  - Audit Logs    │    │ - Query Metrics │
│  - Zone Redundant   │    │  - Threat Detect │    │ - Performance   │
│  - Read Replicas    │    │  - GRS Backup    │    │ - Diagnostics   │
└─────────────────────┘    └──────────────────┘    └─────────────────┘
           │
           ▼
┌─────────────────────┐
│   Security Stack    │
│  - TDE Encryption   │
│  - Vuln Assessment │
│  - Email Alerts    │
└─────────────────────┘
```

## Prerequisites

- Existing Azure SQL Server
- Resource group for deployment
- Appropriate permissions for:
  - Database creation and configuration
  - Storage account creation
  - Log Analytics workspace creation
  - Diagnostic settings configuration

## Usage

### 1. Configure Variables

Copy the example configuration:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Update key variables:
```hcl
# Required infrastructure
sql_server_name     = "your-sql-server"
resource_group_name = "your-resource-group"

# Storage account name (must be globally unique)
audit_storage_account_name = "yoursqlaudit001"

# Email addresses for security alerts
threat_detection_email_addresses = ["security@yourcompany.com"]
```

### 2. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Deploy infrastructure
terraform apply
```

### 3. Verify Deployment

Check the outputs for connection information:
```bash
terraform output connection_info
terraform output security_summary
terraform output performance_summary
```

## Configuration Options

### Performance Tiers

Choose appropriate SKU based on requirements:

```hcl
# Development/Testing
sku_name = "GP_S_Gen5_1"    # Serverless, 1 vCore

# Production Standard
sku_name = "GP_Gen5_4"      # General Purpose, 4 vCores

# High Performance
sku_name = "BC_Gen5_8"      # Business Critical, 8 vCores
```

### Security Levels

Configure security based on compliance requirements:

```hcl
# Standard Security
enable_threat_detection = true
enable_auditing = true
transparent_data_encryption_enabled = true

# Enhanced Security (adds vulnerability assessment)
enable_vulnerability_assessment = true
auditing_retention_days = 365
threat_detection_retention_days = 90
```

### Backup Strategies

Set retention policies based on business needs:

```hcl
# Standard Backup
short_term_retention_days = 7
geo_backup_enabled = true

# Enhanced Backup
short_term_retention_days = 14
backup_interval_in_hours = 12
long_term_retention_policy = {
  weekly_retention  = "P4W"
  monthly_retention = "P12M"
  yearly_retention  = "P5Y"
  week_of_year     = 1
}
```

## Monitoring and Alerts

### Log Analytics Queries

Use these queries in the created Log Analytics workspace:

```kusto
// Database performance metrics
AzureMetrics
| where ResourceProvider == "MICROSOFT.SQL"
| where MetricName in ("cpu_percent", "dtu_consumption_percent")
| summarize avg(Average) by MetricName, bin(TimeGenerated, 5m)

// Failed login attempts
AzureDiagnostics
| where Category == "SQLSecurityAuditEvents"
| where action_name_s == "LOGIN_FAILED"
| summarize count() by client_ip_s, bin(TimeGenerated, 1h)
```

### Alert Rules

Configure alerts for critical conditions:
- High CPU usage (>80% for 10 minutes)
- Failed login attempts (>10 per hour)
- Storage usage (>90% of max size)
- Blocking locks (>5 minute duration)

## Security Compliance

This configuration meets requirements for:

- **SOX Compliance**: Comprehensive auditing and access logging
- **PCI DSS**: Encryption at rest and in transit, access monitoring
- **GDPR**: Data retention policies and audit trails
- **HIPAA**: Encryption and access controls

## Cost Optimization

### Tips for Managing Costs

1. **Use Serverless for Development**: Switch to `GP_S_Gen5_*` SKUs for non-production
2. **Optimize Storage**: Use `Local` or `Zone` redundancy for non-critical databases
3. **Adjust Retention**: Reduce backup retention periods for development databases
4. **Monitor Usage**: Use diagnostic logs to identify unused read replicas

### Example Cost-Optimized Configuration

```hcl
# Development environment overrides
sku_name = "GP_S_Gen5_1"
zone_redundant = false
read_scale = false
read_replica_count = 0
storage_account_type = "Local"
short_term_retention_days = 7
long_term_retention_policy = null
```

## Troubleshooting

### Common Issues

1. **Storage Account Name Conflict**: Ensure `audit_storage_account_name` is globally unique
2. **Permission Errors**: Verify service principal has Contributor role
3. **Log Analytics Costs**: Monitor ingestion volume and adjust retention

### Validation Steps

```bash
# Check database status
az sql db show --resource-group $RG_NAME --server $SERVER_NAME --name $DB_NAME

# Verify threat detection
az sql db threat-policy show --resource-group $RG_NAME --server $SERVER_NAME --database $DB_NAME

# Check audit settings
az sql db audit-policy show --resource-group $RG_NAME --server $SERVER_NAME --database $DB_NAME
```

## Clean Up

```bash
terraform destroy
```

**Note**: This will permanently delete the database and all associated logs. Ensure backups are secured before cleanup.

## Next Steps

- Configure application connection strings using outputs
- Set up automated backup testing procedures
- Implement database maintenance scripts
- Configure additional monitoring dashboards
- Review and tune performance based on workload patterns