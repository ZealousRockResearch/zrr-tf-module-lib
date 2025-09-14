# azure-shared-application-service-plan module
# Description: Creates an Azure App Service Plan with comprehensive scaling, performance, and monitoring features

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# Local values
locals {
  common_tags = merge(
    var.common_tags,
    var.application_plan_tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "zrr-tf-module-lib/azure/shared/application-service-plan"
      "Layer"     = "shared"
    }
  )
}

# Main Azure App Service Plan resource
resource "azurerm_service_plan" "main" {
  name                = var.name
  location            = var.location != null ? var.location : data.azurerm_resource_group.main.location
  resource_group_name = var.resource_group_name

  # Service Plan Configuration
  os_type  = var.os_type
  sku_name = var.sku_name

  # Capacity and Scaling
  worker_count                 = var.worker_count
  maximum_elastic_worker_count = var.maximum_elastic_worker_count
  zone_balancing_enabled       = var.zone_balancing_enabled

  # Per Site Scaling
  per_site_scaling_enabled = var.per_site_scaling_enabled

  tags = local.common_tags
}

# Auto-scaling settings (if enabled)
resource "azurerm_monitor_autoscale_setting" "main" {
  count = var.enable_autoscaling ? 1 : 0

  name                = "${var.name}-autoscale"
  location            = azurerm_service_plan.main.location
  resource_group_name = var.resource_group_name
  target_resource_id  = azurerm_service_plan.main.id

  profile {
    name = "default"

    capacity {
      default = var.autoscale_settings.default_instances
      minimum = var.autoscale_settings.minimum_instances
      maximum = var.autoscale_settings.maximum_instances
    }

    # CPU-based scaling rule (scale out)
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT${var.autoscale_settings.scale_out_cooldown}M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.autoscale_settings.cpu_threshold_out
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT${var.autoscale_settings.scale_out_cooldown}M"
      }
    }

    # CPU-based scaling rule (scale in)
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT${var.autoscale_settings.scale_in_cooldown}M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.autoscale_settings.cpu_threshold_in
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT${var.autoscale_settings.scale_in_cooldown}M"
      }
    }

    # Memory-based scaling rule (scale out) - if enabled
    dynamic "rule" {
      for_each = var.autoscale_settings.enable_memory_scaling ? [1] : []
      content {
        metric_trigger {
          metric_name        = "MemoryPercentage"
          metric_resource_id = azurerm_service_plan.main.id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT${var.autoscale_settings.scale_out_cooldown}M"
          time_aggregation   = "Average"
          operator           = "GreaterThan"
          threshold          = var.autoscale_settings.memory_threshold_out
        }

        scale_action {
          direction = "Increase"
          type      = "ChangeCount"
          value     = "1"
          cooldown  = "PT${var.autoscale_settings.scale_out_cooldown}M"
        }
      }
    }

    # Memory-based scaling rule (scale in) - if enabled
    dynamic "rule" {
      for_each = var.autoscale_settings.enable_memory_scaling ? [1] : []
      content {
        metric_trigger {
          metric_name        = "MemoryPercentage"
          metric_resource_id = azurerm_service_plan.main.id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT${var.autoscale_settings.scale_in_cooldown}M"
          time_aggregation   = "Average"
          operator           = "LessThan"
          threshold          = var.autoscale_settings.memory_threshold_in
        }

        scale_action {
          direction = "Decrease"
          type      = "ChangeCount"
          value     = "1"
          cooldown  = "PT${var.autoscale_settings.scale_in_cooldown}M"
        }
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = var.autoscale_notifications.send_to_subscription_administrator
      send_to_subscription_co_administrator = var.autoscale_notifications.send_to_subscription_co_administrator
      custom_emails                         = var.autoscale_notifications.custom_emails
    }

    dynamic "webhook" {
      for_each = var.autoscale_notifications.webhooks
      content {
        service_uri = webhook.value.service_uri
        properties  = webhook.value.properties
      }
    }
  }

  tags = local.common_tags
}

# Diagnostic settings (if enabled)
resource "azurerm_monitor_diagnostic_setting" "main" {
  count = var.enable_diagnostic_settings ? 1 : 0

  name                       = "${var.name}-diagnostics"
  target_resource_id         = azurerm_service_plan.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.diagnostic_log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = var.diagnostic_metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
}

# Action Group for alerts (if provided)
data "azurerm_monitor_action_group" "alerts" {
  count               = var.alert_action_group_name != null ? 1 : 0
  name                = var.alert_action_group_name
  resource_group_name = var.alert_action_group_resource_group != null ? var.alert_action_group_resource_group : var.resource_group_name
}

# CPU utilization alert
resource "azurerm_monitor_metric_alert" "cpu_utilization" {
  count = var.enable_alerts && var.cpu_alert_settings.enabled ? 1 : 0

  name                = "${var.name}-cpu-utilization"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_service_plan.main.id]
  description         = "Alert when CPU utilization is high"
  severity            = var.cpu_alert_settings.severity

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_alert_settings.threshold

    dimension {
      name     = "Instance"
      operator = "Include"
      values   = ["*"]
    }
  }

  window_size   = "PT${var.cpu_alert_settings.window_size}M"
  frequency     = "PT${var.cpu_alert_settings.frequency}M"
  auto_mitigate = var.cpu_alert_settings.auto_mitigate

  dynamic "action" {
    for_each = var.alert_action_group_name != null ? [1] : []
    content {
      action_group_id = data.azurerm_monitor_action_group.alerts[0].id
    }
  }

  tags = local.common_tags
}

# Memory utilization alert
resource "azurerm_monitor_metric_alert" "memory_utilization" {
  count = var.enable_alerts && var.memory_alert_settings.enabled ? 1 : 0

  name                = "${var.name}-memory-utilization"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_service_plan.main.id]
  description         = "Alert when memory utilization is high"
  severity            = var.memory_alert_settings.severity

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.memory_alert_settings.threshold

    dimension {
      name     = "Instance"
      operator = "Include"
      values   = ["*"]
    }
  }

  window_size   = "PT${var.memory_alert_settings.window_size}M"
  frequency     = "PT${var.memory_alert_settings.frequency}M"
  auto_mitigate = var.memory_alert_settings.auto_mitigate

  dynamic "action" {
    for_each = var.alert_action_group_name != null ? [1] : []
    content {
      action_group_id = data.azurerm_monitor_action_group.alerts[0].id
    }
  }

  tags = local.common_tags
}