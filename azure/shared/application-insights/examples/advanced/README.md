# Advanced Application Insights Example

This example demonstrates enterprise-grade Application Insights deployment with comprehensive monitoring, alerting, analytics, governance, and compliance features.

## What This Example Creates

- Enterprise Application Insights component with advanced monitoring capabilities
- Comprehensive web tests for availability monitoring from multiple geographic locations
- Standard and custom alert rules with enterprise notification channels
- Smart detection rules with AI-powered anomaly detection
- Analytics items including saved queries and custom functions for business intelligence
- API keys for external system integrations
- Workbook templates for operational dashboards
- Continuous export configuration for long-term data retention
- Enterprise governance and compliance features
- Advanced security and data protection controls

## Enterprise Features

### 🔍 **Advanced Monitoring**
- **Multi-Region Web Tests**: Availability monitoring from 4+ geographic locations
- **Custom Alert Rules**: Application-specific performance and resource monitoring
- **Smart Detection**: AI-powered anomaly detection with targeted notifications
- **Real-time Dashboards**: Enterprise workbook templates for operational insights

### 🚨 **Enterprise Alerting**
- **Multi-Channel Notifications**: Integration with enterprise action groups
- **Severity-Based Routing**: Critical, high, medium, and low severity alert routing
- **Team-Specific Alerts**: Targeted notifications to ops, dev, SRE, and platform teams
- **Escalation Policies**: Automated escalation for unacknowledged alerts

### 📊 **Business Intelligence**
- **Custom Analytics**: Saved queries for error analysis, performance trends, and user flows
- **KQL Functions**: Reusable query functions for error rates and performance percentiles
- **Operational Dashboards**: Pre-built workbooks for performance and error monitoring
- **Data Export**: Continuous export to Azure Storage for long-term analysis

### 🔐 **Enterprise Security & Compliance**
- **Data Classification**: Confidential data handling with appropriate controls
- **Privacy Protection**: IP masking and PII detection capabilities
- **Access Control**: Azure AD-only authentication with internet access management
- **Compliance Support**: SOX, PCI-DSS, HIPAA, GDPR, ISO27001, SOC2 compliance

### 🏢 **Enterprise Governance**
- **Data Retention**: Extended 2-year retention for compliance requirements
- **Resource Tagging**: Comprehensive enterprise tagging standards
- **Change Management**: Integration with enterprise change management processes
- **Cost Management**: Data cap management and sampling optimization

## Usage

1. Copy the example configuration:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Update the configuration with your enterprise values:
   ```bash
   # Edit terraform.tfvars with your specific values
   vim terraform.tfvars
   ```

3. Customize for your environment:
   - Update workspace ID with your Log Analytics workspace
   - Configure action group IDs for your notification channels
   - Adjust web test URLs for your applications
   - Customize alert thresholds for your SLAs
   - Update compliance requirements for your industry

4. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration Examples

### Enterprise Web Tests

Multi-region availability monitoring:

```hcl
web_tests = {
  homepage = {
    kind          = "ping"
    frequency     = 300  # 5 minutes
    timeout       = 30
    enabled       = true
    retry_enabled = true
    geo_locations = [
      "us-il-ch1-azr",  # Chicago
      "us-ca-sjc-azr",  # San Jose
      "us-va-ash-azr",  # Virginia
      "emea-nl-ams-azr" # Amsterdam
    ]
    description   = "Homepage availability test from multiple regions"
    configuration = "...WebTest XML..."
  }

  user_journey = {
    kind          = "multistep"
    frequency     = 600  # 10 minutes
    timeout       = 120
    enabled       = true
    retry_enabled = false
    geo_locations = ["us-il-ch1-azr"]
    description   = "Critical user journey end-to-end test"
    configuration = "...Multi-step WebTest XML..."
  }
}
```

### Custom Alert Rules

Application-specific performance monitoring:

```hcl
custom_alerts = {
  high_cpu_usage = {
    description      = "High CPU usage alert"
    severity         = 1
    frequency        = "PT1M"
    window_size      = "PT5M"
    enabled          = true
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "performanceCounters/processCpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
    dimensions       = []
  }

  database_connections = {
    description      = "Database connection pool monitoring"
    severity         = 1
    frequency        = "PT1M"
    window_size      = "PT5M"
    enabled          = true
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "dependencies/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 5000  # 5 seconds
    dimensions = [
      {
        name     = "dependency/type"
        operator = "Include"
        values   = ["SQL"]
      }
    ]
  }
}
```

### Smart Detection Rules

AI-powered anomaly detection:

```hcl
smart_detection_rules = {
  "Slow page load time" = {
    enabled                            = true
    send_emails_to_subscription_owners = false
    additional_email_recipients        = ["ops-team@company.com", "dev-team@company.com"]
  }

  "Degradation in server response time" = {
    enabled                            = true
    send_emails_to_subscription_owners = false
    additional_email_recipients        = ["sre-team@company.com"]
  }

  "Potential memory leak detected" = {
    enabled                            = true
    send_emails_to_subscription_owners = false
    additional_email_recipients        = ["dev-team@company.com", "platform-team@company.com"]
  }
}
```

### Analytics Items

Business intelligence and troubleshooting queries:

```hcl
analytics_items = {
  error_analysis = {
    type           = "query"
    scope          = "shared"
    content        = "exceptions | where timestamp > ago(24h) | summarize count() by type, outerMessage, operation_Name | order by count_ desc | take 20"
    function_alias = ""
  }

  get_error_rate = {
    type           = "function"
    scope          = "shared"
    content        = "let timespan = 1h; requests | where timestamp > ago(timespan) | summarize total = count(), errors = countif(success == false) | extend error_rate = todouble(errors) / todouble(total) * 100"
    function_alias = "GetErrorRate"
  }
}
```

### API Keys for Integration

External system integration:

```hcl
api_keys = {
  monitoring_service = {
    read_permissions  = ["aggregate", "api", "search"]
    write_permissions = ["annotations"]
  }

  ci_cd_pipeline = {
    read_permissions  = ["api"]
    write_permissions = ["annotations"]
  }
}
```

### Continuous Export

Long-term data retention and analysis:

```hcl
enable_continuous_export = true

continuous_export_config = {
  destination_type = "storage"
  destination_config = {
    storage_account_name = "enterpriseappdatastorage"
    container_name      = "applicationinsights-export"
  }
  export_types = [
    "Request",
    "Exception",
    "CustomEvent",
    "Trace",
    "Dependency",
    "PageView",
    "PerformanceCounter"
  ]
}
```

## Enterprise Governance

### Compliance Configuration

Multi-framework compliance support:

```hcl
compliance_requirements = [
  "SOX",      # Sarbanes-Oxley Act
  "PCI-DSS",  # Payment Card Industry
  "ISO27001", # Information Security Management
  "GDPR",     # General Data Protection Regulation
  "HIPAA",    # Health Insurance Portability
  "SOC2"      # Service Organization Control 2
]

data_governance = {
  data_classification   = "confidential"
  data_retention_policy = "extended"     # 2 years
  pii_detection_enabled = true
  data_masking_enabled  = true
}
```

### Security Configuration

Enterprise security controls:

```hcl
# Security settings
local_authentication_disabled = true  # Force Azure AD
disable_ip_masking            = false # Enable privacy protection
internet_ingestion_enabled   = true   # Controlled internet access
internet_query_enabled        = true  # Controlled query access

# Data protection
retention_in_days     = 730  # 2 years for compliance
daily_data_cap_gb     = 10   # Enterprise data cap
sampling_percentage   = 100  # Full sampling for critical apps
```

## Integration Examples

### With App Service

```hcl
resource "azurerm_linux_web_app" "example" {
  # ... other configuration

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = module.application_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = module.application_insights.connection_string
    "APPINSIGHTS_PROFILERFEATURE_VERSION"  = "1.0.0"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"  = "1.0.0"
  }
}
```

### With Azure Functions

```hcl
resource "azurerm_linux_function_app" "example" {
  # ... other configuration

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = module.application_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = module.application_insights.connection_string
  }
}
```

### With Kubernetes

```yaml
# Application deployment with Application Insights
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
      - name: myapp
        env:
        - name: APPINSIGHTS_INSTRUMENTATIONKEY
          value: "{{ .Values.applicationInsights.instrumentationKey }}"
        - name: APPLICATIONINSIGHTS_CONNECTION_STRING
          value: "{{ .Values.applicationInsights.connectionString }}"
```

## Monitoring Dashboards

The advanced example creates enterprise workbook templates:

### Performance Dashboard
- Request volume trends
- Response time percentiles
- Dependency performance
- Resource utilization

### Error Dashboard
- Exception type distribution
- Error rate trends
- Failed request analysis
- Exception stack traces

## Data Export and Analytics

Continuous export enables:

- **Long-term Storage**: Archive telemetry data in Azure Storage
- **External Analytics**: Integration with Power BI, Azure Synapse, or third-party tools
- **Compliance Reporting**: Historical data for audit and compliance reporting
- **Custom Processing**: ETL pipelines for business intelligence

## Troubleshooting

### Common Enterprise Issues

1. **Workspace Access**: Ensure proper RBAC permissions on Log Analytics workspace
2. **Action Group Permissions**: Verify action group access and notification channels
3. **Web Test Failures**: Check application accessibility from test locations
4. **Data Cap Reached**: Monitor daily data usage and adjust caps as needed
5. **Export Failures**: Verify storage account access and container permissions

### Enterprise Validation

```bash
# Verify Application Insights deployment
az monitor app-insights component show \
  --app enterprise-insights \
  --resource-group rg-enterprise-monitoring

# Check web test status
az monitor app-insights web-test list \
  --resource-group rg-enterprise-monitoring

# Validate alert rules
az monitor metrics alert list \
  --resource-group rg-enterprise-monitoring

# Verify continuous export
az monitor app-insights component continues-export list \
  --app enterprise-insights \
  --resource-group rg-enterprise-monitoring
```

## Clean Up

To remove the Application Insights component and all associated resources:

```bash
terraform destroy
```

**⚠️ Warning**: This will permanently delete all monitoring data, alerts, and configurations. Ensure you have backed up any critical dashboards or queries before proceeding.

## Next Steps

1. **Dashboard Creation**: Build custom dashboards using the provided workbook templates
2. **Alert Tuning**: Adjust alert thresholds based on observed application behavior
3. **Integration Testing**: Validate web tests and alert notifications
4. **Compliance Review**: Ensure configuration meets your industry compliance requirements
5. **Training**: Train your teams on using Application Insights for monitoring and troubleshooting

For additional enterprise features, consider:
- Azure Sentinel integration for security monitoring
- Azure Automation for automated remediation
- Power BI integration for executive reporting
- Azure DevOps integration for CI/CD pipeline monitoring