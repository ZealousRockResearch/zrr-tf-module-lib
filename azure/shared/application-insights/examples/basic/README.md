# Basic Application Insights Example

This example demonstrates basic usage of the Application Insights module for standard application monitoring scenarios.

## What This Example Creates

- Application Insights component with basic monitoring capabilities
- Integration with Log Analytics workspace
- Standard alert rules for performance monitoring
- Basic data retention and sampling configuration
- Enterprise tagging standards

## Usage

1. Copy the example configuration:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your specific values:
   - Application Insights name and resource group
   - Log Analytics workspace details
   - Environment and criticality settings
   - Appropriate tags for your environment

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

### Required Variables

- `name`: Name of your Application Insights component
- `resource_group_name`: Resource group for the Application Insights
- `location`: Azure region for deployment
- `workspace_name`: Name of the Log Analytics workspace
- `workspace_resource_group_name`: Resource group of the Log Analytics workspace

### Application Types

The basic example supports all Application Insights application types:
- **web**: Web applications (default)
- **java**: Java applications
- **ios**: iOS mobile applications
- **android**: Android applications
- **other**: Other application types
- **mobile**: Mobile applications (general)
- **desktop**: Desktop applications

### Example Configurations

#### Web Application (Default)
```hcl
name             = "myapp-insights"
application_type = "web"
environment      = "dev"
criticality      = "medium"
```

#### Java Application
```hcl
name             = "myapi-insights"
application_type = "java"
environment      = "prod"
criticality      = "high"
```

#### Mobile Application
```hcl
name             = "mobileapp-insights"
application_type = "ios"
environment      = "prod"
criticality      = "high"
```

### Data Management

Configure data retention and sampling:

```hcl
retention_in_days = 90          # 30, 60, 90, 120, 180, 270, 365, 550, 730
daily_data_cap_gb = 1           # Optional: automatic based on criticality
sampling_percentage = 50        # Optional: automatic based on criticality
```

### Standard Alerts

The basic example includes standard alert rules:
- **Server Response Time**: Alerts when response time > 5 seconds
- **Failure Rate**: Alerts when failure count > 10
- **Exception Rate**: Alerts when exception count > 5

To customize thresholds:
```hcl
server_response_time_threshold = 3000  # 3 seconds
failure_rate_threshold = 5            # 5 failures
exception_rate_threshold = 2          # 2 exceptions
```

### Integration Examples

#### With App Service
```hcl
# Use outputs in your App Service configuration
app_settings = {
  "APPINSIGHTS_INSTRUMENTATIONKEY"        = module.application_insights.instrumentation_key
  "APPLICATIONINSIGHTS_CONNECTION_STRING" = module.application_insights.connection_string
}
```

#### With Function App
```hcl
# Configure Function App monitoring
site_config {
  application_insights_key               = module.application_insights.instrumentation_key
  application_insights_connection_string = module.application_insights.connection_string
}
```

## Clean Up

To remove the Application Insights component:
```bash
terraform destroy
```

**Note**: This will remove all monitoring data and alert rules. Ensure this won't disrupt your monitoring before proceeding.

## Next Steps

- Review the [Advanced Example](../advanced/README.md) for enterprise features
- Configure [custom alerts](../advanced/README.md#custom-alerts-configuration) for specific metrics
- Set up [availability tests](../advanced/README.md#web-tests-configuration) for proactive monitoring
- Implement [data governance](../advanced/README.md#data-governance) for compliance requirements

## Troubleshooting

### Common Issues

1. **Workspace not found**: Ensure the Log Analytics workspace exists and the name is correct
2. **Permission denied**: Verify you have Contributor access to the resource group
3. **Location mismatch**: Application Insights and Log Analytics workspace should be in the same region
4. **Missing alerts**: Check that `enable_standard_alerts = true` and action groups are configured

### Validation

Verify the deployment:
```bash
# Check Application Insights component
az monitor app-insights component show --app myapp-insights --resource-group my-app-rg

# Verify Log Analytics integration
az monitor log-analytics workspace show --workspace-name my-log-analytics --resource-group my-app-rg
```