# Azure App Service Plan - Advanced Example

This example demonstrates the advanced usage of the Azure App Service Plan module with enterprise-grade configurations, including auto-scaling, comprehensive monitoring, alerting, and additional supporting resources.

## Features Demonstrated

### Core App Service Plan Features
- **Premium v3 SKU** with high performance and elastic scaling
- **Zone balancing** for high availability across availability zones
- **Per-site scaling** for independent scaling of individual applications
- **Elastic worker scaling** for dynamic capacity management

### Auto-scaling Configuration
- **CPU-based scaling** with configurable thresholds
- **Memory-based scaling** for comprehensive resource management
- **Custom cooldown periods** to prevent scaling flapping
- **Email and webhook notifications** for scaling events

### Monitoring and Observability
- **Log Analytics workspace** for centralized logging
- **Application Insights** for application performance monitoring
- **Diagnostic settings** with comprehensive log categories
- **Storage account** for long-term log retention

### Alerting and Notifications
- **Action groups** with multiple notification channels
- **CPU and memory utilization alerts** with configurable thresholds
- **Multi-channel notifications** (email, SMS, webhook, Azure Function)
- **Auto-mitigation** for transient issues

### Network Security
- **Network Security Group** for App Service subnet security
- **Predefined security rules** for web application traffic
- **DNS and HTTPS outbound rules** for application dependencies

## Architecture

```
┌─────────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  App Service Plan   │    │  Log Analytics   │    │ Application     │
│  - Premium v3 SKU   │◄──►│  - Diagnostics   │    │ Insights        │
│  - Zone Redundant   │    │  - 365-day       │    │ - 90-day        │
│  - Auto-scaling     │    │    retention     │    │   retention     │
│  - 2-10 instances   │    │  - All metrics   │    │ - Web app APM   │
└─────────────────────┘    └──────────────────┘    └─────────────────┘
           │                          │
           ▼                          ▼
┌─────────────────────┐    ┌──────────────────┐
│   Action Group      │    │  Storage Account │
│  - Email alerts    │    │  - Diagnostic    │
│  - SMS alerts      │    │    logs (30d)    │
│  - Webhook alerts  │    │  - LRS backup    │
└─────────────────────┘    └──────────────────┘
```

## Prerequisites

- Resource group for deployment
- Appropriate Azure permissions for:
  - App Service Plan creation and configuration
  - Log Analytics workspace creation
  - Application Insights creation
  - Action group and alert creation
  - Storage account creation
  - Network Security Group creation (if enabled)

## Usage

### 1. Configure Variables

Copy the example configuration:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Update key variables:
```hcl
# Required infrastructure
service_plan_name   = "your-service-plan"
resource_group_name = "your-resource-group"

# Performance configuration
sku_name = "P1v3"  # Premium v3 for production workloads
worker_count = 3   # Initial capacity

# Auto-scaling thresholds
autoscale_settings = {
  minimum_instances = 2
  maximum_instances = 10
  cpu_threshold_out = 70   # Scale out at 70% CPU
  cpu_threshold_in  = 25   # Scale in at 25% CPU
}

# Alert recipients
alert_email_receivers = [
  {
    name          = "ops-team"
    email_address = "ops@yourcompany.com"
  }
]
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
terraform output scaling_summary
terraform output monitoring_summary
```

## Configuration Options

### Performance Tiers

Choose appropriate SKU based on requirements:

```hcl
# Premium v3 (recommended for production)
sku_name = "P1v3"  # 1 core, 4 GB RAM, zone redundancy support
sku_name = "P2v3"  # 2 cores, 8 GB RAM
sku_name = "P3v3"  # 4 cores, 16 GB RAM

# Isolated (for compliance requirements)
sku_name = "I1"    # Isolated environment, 1 core, 3.5 GB RAM
sku_name = "I2"    # Isolated environment, 2 cores, 7 GB RAM
sku_name = "I3"    # Isolated environment, 4 cores, 14 GB RAM
```

### Auto-scaling Strategies

Configure scaling based on workload patterns:

```hcl
# Conservative scaling
autoscale_settings = {
  minimum_instances = 2
  maximum_instances = 5
  cpu_threshold_out = 80
  cpu_threshold_in  = 30
  scale_out_cooldown = 10
  scale_in_cooldown  = 15
}

# Aggressive scaling
autoscale_settings = {
  minimum_instances = 1
  maximum_instances = 20
  cpu_threshold_out = 60
  cpu_threshold_in  = 20
  scale_out_cooldown = 3
  scale_in_cooldown  = 5
}
```

### Alert Severity Levels

Configure appropriate alert severities:

```hcl
cpu_alert_settings = {
  threshold = 75
  severity  = 1  # Error - immediate attention required
}

memory_alert_settings = {
  threshold = 90
  severity  = 0  # Critical - urgent response needed
}
```

## Monitoring and Observability

### Key Metrics to Monitor

The module automatically configures monitoring for:

- **CPU Percentage**: Overall processor utilization
- **Memory Percentage**: RAM usage across instances
- **Instance Count**: Number of active workers
- **HTTP Queue Length**: Request backlog indicator
- **Response Time**: Application responsiveness
- **Request Rate**: Throughput metrics

### Log Analytics Queries

Use these queries in the created Log Analytics workspace:

```kusto
// App Service Plan performance over time
AzureMetrics
| where ResourceProvider == "MICROSOFT.WEB"
| where ResourceId contains "serverfarms"
| where MetricName in ("CpuPercentage", "MemoryPercentage")
| summarize avg(Average) by MetricName, bin(TimeGenerated, 5m)
| render timechart

// Auto-scaling events
AzureActivity
| where OperationName contains "Autoscale"
| where ResourceProvider == "microsoft.insights"
| project TimeGenerated, OperationName, ActivityStatus, Caller
| order by TimeGenerated desc

// High CPU instances
AzureMetrics
| where ResourceProvider == "MICROSOFT.WEB"
| where MetricName == "CpuPercentage"
| where Average > 80
| summarize count() by bin(TimeGenerated, 1h)
```

### Application Insights Integration

The module creates Application Insights for:

- **Request telemetry**: HTTP requests and responses
- **Dependency tracking**: Database and external service calls
- **Exception monitoring**: Unhandled errors and crashes
- **Performance counters**: System-level metrics
- **Custom telemetry**: Application-specific metrics

## Security Considerations

### Network Security Group Rules

When `create_app_service_nsg = true`, the module creates:

```hcl
# Inbound rules
- Allow HTTP/HTTPS (ports 80, 443) from any source
- Deny all other inbound traffic

# Outbound rules
- Allow HTTPS (port 443) to any destination
- Allow HTTP (port 80) to any destination
- Allow DNS (port 53 UDP) to any destination
- Deny all other outbound traffic
```

### Recommended Security Enhancements

1. **Custom Domain with SSL**: Configure custom domains with SSL certificates
2. **IP Restrictions**: Limit access to specific IP ranges
3. **Managed Identity**: Use managed identities for Azure service authentication
4. **Key Vault Integration**: Store secrets and certificates in Azure Key Vault
5. **VNet Integration**: Deploy into private virtual network subnets

## Cost Optimization

### Tips for Managing Costs

1. **Right-size SKUs**: Start with P1v3 and scale up based on actual usage
2. **Optimize Auto-scaling**: Fine-tune thresholds to avoid unnecessary scaling
3. **Monitor Elastic Workers**: Track elastic worker usage in Premium v3
4. **Review Retention Policies**: Adjust log retention based on compliance needs
5. **Use Reserved Instances**: Consider Azure Reserved VM Instances for steady workloads

### Cost Monitoring Queries

```kusto
// Instance hours by day
AzureMetrics
| where ResourceProvider == "MICROSOFT.WEB"
| where MetricName == "Instance Count"
| extend InstanceHours = Average * 1.0
| summarize TotalInstanceHours = sum(InstanceHours) by bin(TimeGenerated, 1d)
| render columnchart
```

## Troubleshooting

### Common Issues

1. **Auto-scaling Not Triggering**: Check metric thresholds and cooldown periods
2. **High Memory Usage**: Consider upgrading SKU or optimizing applications
3. **Zone Balancing Failures**: Ensure Premium v2/v3 SKU is selected
4. **Alert Fatigue**: Adjust alert thresholds and implement smart grouping

### Diagnostic Commands

```bash
# Check App Service Plan status
az appservice plan show --name $PLAN_NAME --resource-group $RG_NAME

# View auto-scale settings
az monitor autoscale show --resource-group $RG_NAME --name "${PLAN_NAME}-autoscale"

# Check recent auto-scale actions
az monitor autoscale profile list --autoscale-name "${PLAN_NAME}-autoscale" --resource-group $RG_NAME

# View alert rules
az monitor metrics alert list --resource-group $RG_NAME
```

## Clean Up

```bash
terraform destroy
```

**Warning**: This will permanently delete all resources including logs and monitoring data. Ensure backups are secured before cleanup.

## Next Steps

- Deploy Azure App Services to the created App Service Plan
- Configure custom domains and SSL certificates
- Implement VNet integration for network isolation
- Set up CI/CD pipelines for application deployment
- Configure backup and disaster recovery procedures
- Implement advanced security controls and compliance monitoring