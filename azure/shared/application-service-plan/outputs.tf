# Primary outputs
output "id" {
  description = "ID of the Azure App Service Plan"
  value       = azurerm_service_plan.main.id
}

output "name" {
  description = "Name of the Azure App Service Plan"
  value       = azurerm_service_plan.main.name
}

output "location" {
  description = "Location of the Azure App Service Plan"
  value       = azurerm_service_plan.main.location
}

output "resource_group_name" {
  description = "Resource group name of the Azure App Service Plan"
  value       = azurerm_service_plan.main.resource_group_name
}

# Configuration outputs
output "os_type" {
  description = "Operating system type of the App Service Plan"
  value       = azurerm_service_plan.main.os_type
}

output "sku_name" {
  description = "SKU name of the App Service Plan"
  value       = azurerm_service_plan.main.sku_name
}

output "worker_count" {
  description = "Number of workers (instances) in the App Service Plan"
  value       = azurerm_service_plan.main.worker_count
}

output "maximum_elastic_worker_count" {
  description = "Maximum number of elastic workers for the App Service Plan"
  value       = azurerm_service_plan.main.maximum_elastic_worker_count
}

output "zone_balancing_enabled" {
  description = "Whether zone balancing is enabled for the App Service Plan"
  value       = azurerm_service_plan.main.zone_balancing_enabled
}

output "per_site_scaling_enabled" {
  description = "Whether per-site scaling is enabled for the App Service Plan"
  value       = azurerm_service_plan.main.per_site_scaling_enabled
}

# Auto-scaling outputs
output "autoscaling_enabled" {
  description = "Whether auto-scaling is enabled for the App Service Plan"
  value       = var.enable_autoscaling
}

output "autoscale_setting_id" {
  description = "ID of the auto-scaling setting (if enabled)"
  value       = var.enable_autoscaling ? azurerm_monitor_autoscale_setting.main[0].id : null
}

output "autoscale_setting_name" {
  description = "Name of the auto-scaling setting (if enabled)"
  value       = var.enable_autoscaling ? azurerm_monitor_autoscale_setting.main[0].name : null
}

# Monitoring outputs
output "diagnostic_setting_enabled" {
  description = "Whether diagnostic settings are enabled"
  value       = var.enable_diagnostic_settings
}

output "diagnostic_setting_id" {
  description = "ID of the diagnostic setting (if enabled)"
  value       = var.enable_diagnostic_settings ? azurerm_monitor_diagnostic_setting.main[0].id : null
}

# Alert outputs
output "alerts_enabled" {
  description = "Whether monitoring alerts are enabled"
  value       = var.enable_alerts
}

output "cpu_alert_id" {
  description = "ID of the CPU utilization alert (if enabled)"
  value       = var.enable_alerts && var.cpu_alert_settings.enabled ? azurerm_monitor_metric_alert.cpu_utilization[0].id : null
}

output "memory_alert_id" {
  description = "ID of the memory utilization alert (if enabled)"
  value       = var.enable_alerts && var.memory_alert_settings.enabled ? azurerm_monitor_metric_alert.memory_utilization[0].id : null
}

# Resource information for App Services
output "app_service_plan_info" {
  description = "Complete App Service Plan information for use by App Services"
  value = {
    id                           = azurerm_service_plan.main.id
    name                         = azurerm_service_plan.main.name
    location                     = azurerm_service_plan.main.location
    resource_group_name          = azurerm_service_plan.main.resource_group_name
    os_type                      = azurerm_service_plan.main.os_type
    sku_name                     = azurerm_service_plan.main.sku_name
    worker_count                 = azurerm_service_plan.main.worker_count
    maximum_elastic_worker_count = azurerm_service_plan.main.maximum_elastic_worker_count
    zone_balancing_enabled       = azurerm_service_plan.main.zone_balancing_enabled
    per_site_scaling_enabled     = azurerm_service_plan.main.per_site_scaling_enabled
  }
}

# Capacity and scaling summary
output "scaling_summary" {
  description = "Summary of scaling configuration"
  value = {
    worker_count                 = azurerm_service_plan.main.worker_count
    maximum_elastic_worker_count = azurerm_service_plan.main.maximum_elastic_worker_count
    per_site_scaling_enabled     = azurerm_service_plan.main.per_site_scaling_enabled
    zone_balancing_enabled       = azurerm_service_plan.main.zone_balancing_enabled
    autoscaling_enabled          = var.enable_autoscaling
    autoscale_min_instances      = var.enable_autoscaling ? var.autoscale_settings.minimum_instances : null
    autoscale_max_instances      = var.enable_autoscaling ? var.autoscale_settings.maximum_instances : null
  }
}

# Monitoring summary
output "monitoring_summary" {
  description = "Summary of monitoring configuration"
  value = {
    diagnostic_settings_enabled = var.enable_diagnostic_settings
    alerts_enabled              = var.enable_alerts
    cpu_alert_enabled           = var.enable_alerts && var.cpu_alert_settings.enabled
    memory_alert_enabled        = var.enable_alerts && var.memory_alert_settings.enabled
    cpu_alert_threshold         = var.enable_alerts && var.cpu_alert_settings.enabled ? var.cpu_alert_settings.threshold : null
    memory_alert_threshold      = var.enable_alerts && var.memory_alert_settings.enabled ? var.memory_alert_settings.threshold : null
  }
}

# Tags output
output "tags" {
  description = "Tags applied to the App Service Plan"
  value       = azurerm_service_plan.main.tags
}