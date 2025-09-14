# Azure Shared - Application Service Plan

This module creates an Azure App Service Plan with comprehensive scaling, performance, monitoring, and alerting features following ZRR enterprise standards.

## Features

- **Performance Tiers**: Support for all Azure App Service Plan SKUs from Free to Isolated v2
- **Auto-scaling**: Configurable auto-scaling rules based on CPU and memory metrics
- **Zone Redundancy**: High availability with zone balancing for Premium v2/v3 tiers
- **Monitoring**: Built-in diagnostic settings with Log Analytics integration
- **Alerting**: Configurable CPU and memory utilization alerts with action groups
- **Per-site Scaling**: Enable independent scaling for individual web apps
- **Elastic Scaling**: Support for elastic worker scaling in Premium v3 tiers
- **Notifications**: Email and webhook notifications for auto-scaling events
- **Comprehensive Outputs**: Complete plan information for use by dependent App Services

## Usage

### Basic Example

```hcl
module "app_service_plan" {
  source = "../../azure/shared/application-service-plan"

  name                = "myapp-service-plan"
  resource_group_name = "myapp-rg"
  location           = "East US"

  # Performance configuration
  os_type   = "Linux"
  sku_name  = "B1"

  common_tags = {
    Environment = "production"
    Project     = "myapp"
    Owner       = "platform-team"
  }
}
```

### Advanced Example with Auto-scaling and Monitoring

```hcl
module "app_service_plan_advanced" {
  source = "../../azure/shared/application-service-plan"

  name                = "enterprise-service-plan"
  resource_group_name = "enterprise-rg"
  location           = "East US"

  # Performance and scaling configuration
  os_type                      = "Linux"
  sku_name                    = "P1v3"
  worker_count                = 3
  maximum_elastic_worker_count = 10
  zone_balancing_enabled      = true
  per_site_scaling_enabled    = true

  # Auto-scaling configuration
  enable_autoscaling = true
  autoscale_settings = {
    default_instances     = 3
    minimum_instances     = 2
    maximum_instances     = 10
    cpu_threshold_out     = 70
    cpu_threshold_in      = 25
    memory_threshold_out  = 80
    memory_threshold_in   = 60
    enable_memory_scaling = true
    scale_out_cooldown    = 5
    scale_in_cooldown     = 10
  }

  autoscale_notifications = {
    send_to_subscription_administrator = true
    custom_emails                     = ["ops@company.com"]
    webhooks = [{
      service_uri = "https://alerts.company.com/webhook"
      properties  = { "severity": "warning" }
    }]
  }

  # Monitoring and diagnostics
  enable_diagnostic_settings  = true
  log_analytics_workspace_id  = "/subscriptions/.../workspaces/my-workspace"

  # Alerting
  enable_alerts               = true
  alert_action_group_name     = "critical-alerts"

  cpu_alert_settings = {
    enabled   = true
    threshold = 80
    severity  = 2
  }

  memory_alert_settings = {
    enabled   = true
    threshold = 85
    severity  = 2
  }

  common_tags = {
    Environment = "production"
    Project     = "enterprise-app"
    Owner       = "platform-team"
    Criticality = "high"
  }

  application_plan_tags = {
    Scaling     = "auto"
    Monitoring  = "enhanced"
    Alerts      = "enabled"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_autoscale_setting.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) | resource |
| [azurerm_monitor_diagnostic_setting.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_metric_alert.cpu_utilization](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.memory_utilization](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_service_plan.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_monitor_action_group.alerts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_action_group) | data source |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_action_group_name"></a> [alert\_action\_group\_name](#input\_alert\_action\_group\_name) | Name of the action group to send alerts to | `string` | `null` | no |
| <a name="input_alert_action_group_resource_group"></a> [alert\_action\_group\_resource\_group](#input\_alert\_action\_group\_resource\_group) | Resource group name where the action group is located (defaults to main resource group) | `string` | `null` | no |
| <a name="input_application_plan_tags"></a> [application\_plan\_tags](#input\_application\_plan\_tags) | Additional tags specific to the App Service Plan | `map(string)` | `{}` | no |
| <a name="input_autoscale_notifications"></a> [autoscale\_notifications](#input\_autoscale\_notifications) | Auto-scaling notification settings | <pre>object({<br>    send_to_subscription_administrator    = optional(bool, true)<br>    send_to_subscription_co_administrator = optional(bool, false)<br>    custom_emails                         = optional(list(string), [])<br>    webhooks = optional(list(object({<br>      service_uri = string<br>      properties  = optional(map(string), {})<br>    })), [])<br>  })</pre> | <pre>{<br>  "custom_emails": [],<br>  "send_to_subscription_administrator": true,<br>  "send_to_subscription_co_administrator": false,<br>  "webhooks": []<br>}</pre> | no |
| <a name="input_autoscale_settings"></a> [autoscale\_settings](#input\_autoscale\_settings) | Auto-scaling configuration settings | <pre>object({<br>    default_instances     = number<br>    minimum_instances     = number<br>    maximum_instances     = number<br>    cpu_threshold_out     = number<br>    cpu_threshold_in      = number<br>    memory_threshold_out  = optional(number, 80)<br>    memory_threshold_in   = optional(number, 60)<br>    enable_memory_scaling = optional(bool, false)<br>    scale_out_cooldown    = optional(number, 5)<br>    scale_in_cooldown     = optional(number, 10)<br>  })</pre> | <pre>{<br>  "cpu_threshold_in": 25,<br>  "cpu_threshold_out": 70,<br>  "default_instances": 2,<br>  "enable_memory_scaling": false,<br>  "maximum_instances": 10,<br>  "memory_threshold_in": 60,<br>  "memory_threshold_out": 80,<br>  "minimum_instances": 1,<br>  "scale_in_cooldown": 10,<br>  "scale_out_cooldown": 5<br>}</pre> | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to be applied to all resources | `map(string)` | <pre>{<br>  "Environment": "dev",<br>  "ManagedBy": "Terraform",<br>  "Project": "zrr"<br>}</pre> | no |
| <a name="input_cpu_alert_settings"></a> [cpu\_alert\_settings](#input\_cpu\_alert\_settings) | CPU utilization alert settings | <pre>object({<br>    enabled       = bool<br>    threshold     = number<br>    severity      = optional(number, 2)<br>    window_size   = optional(number, 5)<br>    frequency     = optional(number, 1)<br>    auto_mitigate = optional(bool, true)<br>  })</pre> | <pre>{<br>  "auto_mitigate": true,<br>  "enabled": true,<br>  "frequency": 1,<br>  "severity": 2,<br>  "threshold": 80,<br>  "window_size": 5<br>}</pre> | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | List of diagnostic log categories to enable | `list(string)` | <pre>[<br>  "AppServicePlatformLogs",<br>  "AppServiceHTTPLogs",<br>  "AppServiceConsoleLogs",<br>  "AppServiceAppLogs",<br>  "AppServiceFileAuditLogs",<br>  "AppServiceAuditLogs"<br>]</pre> | no |
| <a name="input_diagnostic_metrics"></a> [diagnostic\_metrics](#input\_diagnostic\_metrics) | List of diagnostic metrics to enable | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_enable_alerts"></a> [enable\_alerts](#input\_enable\_alerts) | Enable monitoring alerts for the App Service Plan | `bool` | `false` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Enable auto-scaling for the App Service Plan | `bool` | `false` | no |
| <a name="input_enable_diagnostic_settings"></a> [enable\_diagnostic\_settings](#input\_enable\_diagnostic\_settings) | Enable diagnostic settings for the App Service Plan | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where the App Service Plan will be created. If not specified, uses the resource group location | `string` | `null` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace ID for diagnostic settings | `string` | `null` | no |
| <a name="input_maximum_elastic_worker_count"></a> [maximum\_elastic\_worker\_count](#input\_maximum\_elastic\_worker\_count) | Maximum number of elastic workers for the App Service Plan (Premium v3 and above) | `number` | `null` | no |
| <a name="input_memory_alert_settings"></a> [memory\_alert\_settings](#input\_memory\_alert\_settings) | Memory utilization alert settings | <pre>object({<br>    enabled       = bool<br>    threshold     = number<br>    severity      = optional(number, 2)<br>    window_size   = optional(number, 5)<br>    frequency     = optional(number, 1)<br>    auto_mitigate = optional(bool, true)<br>  })</pre> | <pre>{<br>  "auto_mitigate": true,<br>  "enabled": true,<br>  "frequency": 1,<br>  "severity": 2,<br>  "threshold": 85,<br>  "window_size": 5<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Azure App Service Plan | `string` | n/a | yes |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | The operating system type for the App Service Plan (Linux or Windows) | `string` | `"Linux"` | no |
| <a name="input_per_site_scaling_enabled"></a> [per\_site\_scaling\_enabled](#input\_per\_site\_scaling\_enabled) | Enable per-site scaling for the App Service Plan | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where the App Service Plan will be created | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU name for the App Service Plan. Examples: B1, B2, B3, S1, S2, S3, P1v2, P2v2, P3v2, P1v3, P2v3, P3v3 | `string` | `"B1"` | no |
| <a name="input_worker_count"></a> [worker\_count](#input\_worker\_count) | Number of workers (instances) for the App Service Plan | `number` | `null` | no |
| <a name="input_zone_balancing_enabled"></a> [zone\_balancing\_enabled](#input\_zone\_balancing\_enabled) | Enable zone balancing for the App Service Plan (requires Premium v2 or Premium v3) | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alerts_enabled"></a> [alerts\_enabled](#output\_alerts\_enabled) | Whether monitoring alerts are enabled |
| <a name="output_app_service_plan_info"></a> [app\_service\_plan\_info](#output\_app\_service\_plan\_info) | Complete App Service Plan information for use by App Services |
| <a name="output_autoscale_setting_id"></a> [autoscale\_setting\_id](#output\_autoscale\_setting\_id) | ID of the auto-scaling setting (if enabled) |
| <a name="output_autoscale_setting_name"></a> [autoscale\_setting\_name](#output\_autoscale\_setting\_name) | Name of the auto-scaling setting (if enabled) |
| <a name="output_autoscaling_enabled"></a> [autoscaling\_enabled](#output\_autoscaling\_enabled) | Whether auto-scaling is enabled for the App Service Plan |
| <a name="output_cpu_alert_id"></a> [cpu\_alert\_id](#output\_cpu\_alert\_id) | ID of the CPU utilization alert (if enabled) |
| <a name="output_diagnostic_setting_enabled"></a> [diagnostic\_setting\_enabled](#output\_diagnostic\_setting\_enabled) | Whether diagnostic settings are enabled |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | ID of the diagnostic setting (if enabled) |
| <a name="output_id"></a> [id](#output\_id) | ID of the Azure App Service Plan |
| <a name="output_location"></a> [location](#output\_location) | Location of the Azure App Service Plan |
| <a name="output_maximum_elastic_worker_count"></a> [maximum\_elastic\_worker\_count](#output\_maximum\_elastic\_worker\_count) | Maximum number of elastic workers for the App Service Plan |
| <a name="output_memory_alert_id"></a> [memory\_alert\_id](#output\_memory\_alert\_id) | ID of the memory utilization alert (if enabled) |
| <a name="output_monitoring_summary"></a> [monitoring\_summary](#output\_monitoring\_summary) | Summary of monitoring configuration |
| <a name="output_name"></a> [name](#output\_name) | Name of the Azure App Service Plan |
| <a name="output_os_type"></a> [os\_type](#output\_os\_type) | Operating system type of the App Service Plan |
| <a name="output_per_site_scaling_enabled"></a> [per\_site\_scaling\_enabled](#output\_per\_site\_scaling\_enabled) | Whether per-site scaling is enabled for the App Service Plan |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name of the Azure App Service Plan |
| <a name="output_scaling_summary"></a> [scaling\_summary](#output\_scaling\_summary) | Summary of scaling configuration |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | SKU name of the App Service Plan |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the App Service Plan |
| <a name="output_worker_count"></a> [worker\_count](#output\_worker\_count) | Number of workers (instances) in the App Service Plan |
| <a name="output_zone_balancing_enabled"></a> [zone\_balancing\_enabled](#output\_zone\_balancing\_enabled) | Whether zone balancing is enabled for the App Service Plan |
<!-- END_TF_DOCS -->