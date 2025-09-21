# Azure Shared Application Insights module
# Description: Manages Azure Application Insights with comprehensive monitoring, alerting, and analytics features

# Data sources
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "this" {
  count = var.resource_group_name != null ? 1 : 0
  name  = var.resource_group_name
}

data "azurerm_log_analytics_workspace" "this" {
  count               = var.workspace_id == null && var.workspace_name != null ? 1 : 0
  name                = var.workspace_name
  resource_group_name = var.workspace_resource_group_name
}

# Local values
locals {
  # Determine workspace ID
  workspace_id = var.workspace_id != null ? var.workspace_id : (
    var.workspace_name != null ? data.azurerm_log_analytics_workspace.this[0].id : null
  )

  # Resource group ID
  resource_group_id = var.resource_group_name != null ? data.azurerm_resource_group.this[0].id : null

  # Common tags
  common_tags = merge(
    var.common_tags,
    var.application_insights_tags,
    {
      "ManagedBy"   = "Terraform"
      "Module"      = "zrr-tf-module-lib/azure/shared/application-insights"
      "Layer"       = "shared"
      "Environment" = var.environment
      "Criticality" = var.criticality
    }
  )

  # Application type mapping
  application_type_map = {
    "web"     = "web"
    "other"   = "other"
    "java"    = "java"
    "ios"     = "ios"
    "android" = "Node.JS"
    "mobile"  = "other"
    "desktop" = "other"
  }

  # Sampling percentage based on criticality
  sampling_percentage = var.sampling_percentage != null ? var.sampling_percentage : (
    var.criticality == "critical" ? 100 : (
      var.criticality == "high" ? 75 : (
        var.criticality == "medium" ? 50 : 25
      )
    )
  )

  # Daily data cap based on environment and criticality
  daily_data_cap_gb = var.daily_data_cap_gb != null ? var.daily_data_cap_gb : (
    var.environment == "prod" && var.criticality == "critical" ? 10 : (
      var.environment == "prod" ? 5 : 1
    )
  )
}

# Application Insights component
resource "azurerm_application_insights" "this" {
  name                                  = var.name
  location                              = var.location
  resource_group_name                   = var.resource_group_name
  application_type                      = local.application_type_map[var.application_type]
  workspace_id                          = local.workspace_id
  daily_data_cap_in_gb                  = local.daily_data_cap_gb
  daily_data_cap_notifications_disabled = var.daily_data_cap_notifications_disabled
  retention_in_days                     = var.retention_in_days
  sampling_percentage                   = local.sampling_percentage
  disable_ip_masking                    = var.disable_ip_masking
  local_authentication_disabled         = var.local_authentication_disabled
  internet_ingestion_enabled            = var.internet_ingestion_enabled
  internet_query_enabled                = var.internet_query_enabled
  force_customer_storage_for_profiler   = var.force_customer_storage_for_profiler

  tags = local.common_tags
}

# Web test for availability monitoring
resource "azurerm_application_insights_web_test" "this" {
  for_each = var.web_tests

  name                    = "${var.name}-${each.key}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = azurerm_application_insights.this.id
  kind                    = each.value.kind
  frequency               = each.value.frequency
  timeout                 = each.value.timeout
  enabled                 = each.value.enabled
  retry_enabled           = each.value.retry_enabled
  geo_locations           = each.value.geo_locations
  description             = each.value.description

  configuration = each.value.configuration

  tags = merge(
    local.common_tags,
    {
      Purpose  = "availability-monitoring"
      TestType = each.value.kind
    }
  )
}

# Standard alert rules
resource "azurerm_monitor_metric_alert" "server_response_time" {
  count = var.enable_standard_alerts ? 1 : 0

  name                = "${var.name}-server-response-time"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.this.id]
  description         = "Alert when server response time is high"
  severity            = var.alert_severity
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.server_response_time_threshold
  }

  dynamic "action" {
    for_each = var.action_group_ids
    content {
      action_group_id = action.value
    }
  }

  tags = local.common_tags
}

resource "azurerm_monitor_metric_alert" "failure_rate" {
  count = var.enable_standard_alerts ? 1 : 0

  name                = "${var.name}-failure-rate"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.this.id]
  description         = "Alert when failure rate is high"
  severity            = var.alert_severity
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/failed"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.failure_rate_threshold
  }

  dynamic "action" {
    for_each = var.action_group_ids
    content {
      action_group_id = action.value
    }
  }

  tags = local.common_tags
}

resource "azurerm_monitor_metric_alert" "exception_rate" {
  count = var.enable_standard_alerts ? 1 : 0

  name                = "${var.name}-exception-rate"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.this.id]
  description         = "Alert when exception rate is high"
  severity            = var.alert_severity
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "exceptions/count"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.exception_rate_threshold
  }

  dynamic "action" {
    for_each = var.action_group_ids
    content {
      action_group_id = action.value
    }
  }

  tags = local.common_tags
}

# Custom alert rules
resource "azurerm_monitor_metric_alert" "custom" {
  for_each = var.custom_alerts

  name                = "${var.name}-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.this.id]
  description         = each.value.description
  severity            = each.value.severity
  frequency           = each.value.frequency
  window_size         = each.value.window_size
  enabled             = each.value.enabled

  criteria {
    metric_namespace = each.value.metric_namespace
    metric_name      = each.value.metric_name
    aggregation      = each.value.aggregation
    operator         = each.value.operator
    threshold        = each.value.threshold

    dynamic "dimension" {
      for_each = each.value.dimensions
      content {
        name     = dimension.value.name
        operator = dimension.value.operator
        values   = dimension.value.values
      }
    }
  }

  dynamic "action" {
    for_each = var.action_group_ids
    content {
      action_group_id = action.value
    }
  }

  tags = local.common_tags
}

# Smart detection rules
resource "azurerm_application_insights_smart_detection_rule" "this" {
  for_each = var.smart_detection_rules

  name                               = each.key
  application_insights_id            = azurerm_application_insights.this.id
  enabled                            = each.value.enabled
  send_emails_to_subscription_owners = each.value.send_emails_to_subscription_owners
  additional_email_recipients        = each.value.additional_email_recipients
}

# Continuous export (for advanced scenarios)
resource "azurerm_application_insights_analytics_item" "this" {
  for_each = var.analytics_items

  name                    = each.key
  application_insights_id = azurerm_application_insights.this.id
  type                    = each.value.type
  scope                   = each.value.scope
  content                 = each.value.content
  function_alias          = each.value.function_alias
}

# Application Insights API Key
resource "azurerm_application_insights_api_key" "this" {
  for_each = var.api_keys

  name                    = each.key
  application_insights_id = azurerm_application_insights.this.id
  read_permissions        = each.value.read_permissions
  write_permissions       = each.value.write_permissions
}

# Workbook templates for monitoring dashboards
resource "azurerm_application_insights_workbook_template" "this" {
  for_each = var.workbook_templates

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  author              = each.value.author
  priority            = each.value.priority

  template_data = jsonencode({
    version = "Notebook/1.0"
    items   = each.value.template_items
  })

  galleries {
    category      = each.value.gallery_category
    name          = each.value.gallery_name
    order         = each.value.gallery_order
    resource_type = "microsoft.insights/components"
    type          = "workbook"
  }

  tags = local.common_tags
}

# Data export configuration
resource "null_resource" "data_export_config" {
  count = var.enable_continuous_export ? 1 : 0

  triggers = {
    export_config = jsonencode(var.continuous_export_config)
  }
}

# Enterprise governance tracking
resource "null_resource" "governance_tracking" {
  triggers = {
    compliance_requirements = jsonencode(var.compliance_requirements)
    data_governance         = jsonencode(var.data_governance)
    monitoring_config = jsonencode({
      retention_days      = var.retention_in_days
      sampling_percentage = local.sampling_percentage
      daily_cap_gb        = local.daily_data_cap_gb
      alerts_enabled      = var.enable_standard_alerts
    })
  }
}