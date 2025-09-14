# App Service Plan outputs
output "app_service_plan_id" {
  description = "ID of the created App Service Plan"
  value       = module.app_service_plan_advanced.id
}

output "app_service_plan_name" {
  description = "Name of the created App Service Plan"
  value       = module.app_service_plan_advanced.name
}

output "app_service_plan_location" {
  description = "Location of the created App Service Plan"
  value       = module.app_service_plan_advanced.location
}

# Configuration outputs
output "os_type" {
  description = "Operating system type of the App Service Plan"
  value       = module.app_service_plan_advanced.os_type
}

output "sku_name" {
  description = "SKU name of the App Service Plan"
  value       = module.app_service_plan_advanced.sku_name
}

output "worker_count" {
  description = "Number of workers (instances) in the App Service Plan"
  value       = module.app_service_plan_advanced.worker_count
}

output "maximum_elastic_worker_count" {
  description = "Maximum number of elastic workers for the App Service Plan"
  value       = module.app_service_plan_advanced.maximum_elastic_worker_count
}

output "zone_balancing_enabled" {
  description = "Whether zone balancing is enabled"
  value       = module.app_service_plan_advanced.zone_balancing_enabled
}

output "per_site_scaling_enabled" {
  description = "Whether per-site scaling is enabled"
  value       = module.app_service_plan_advanced.per_site_scaling_enabled
}

# Auto-scaling outputs
output "autoscaling_enabled" {
  description = "Whether auto-scaling is enabled"
  value       = module.app_service_plan_advanced.autoscaling_enabled
}

output "autoscale_setting_id" {
  description = "ID of the auto-scaling setting (if enabled)"
  value       = module.app_service_plan_advanced.autoscale_setting_id
}

# Monitoring outputs
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace (if created)"
  value       = var.create_log_analytics ? azurerm_log_analytics_workspace.main[0].id : null
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace (if created)"
  value       = var.create_log_analytics ? azurerm_log_analytics_workspace.main[0].name : null
}

output "application_insights_id" {
  description = "ID of the Application Insights instance (if created)"
  value       = var.create_application_insights ? azurerm_application_insights.main[0].id : null
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights (if created)"
  value       = var.create_application_insights ? azurerm_application_insights.main[0].instrumentation_key : null
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights (if created)"
  value       = var.create_application_insights ? azurerm_application_insights.main[0].connection_string : null
  sensitive   = true
}

# Alert outputs
output "action_group_id" {
  description = "ID of the action group (if created)"
  value       = var.create_action_group ? azurerm_monitor_action_group.main[0].id : null
}

output "action_group_name" {
  description = "Name of the action group (if created)"
  value       = var.create_action_group ? azurerm_monitor_action_group.main[0].name : null
}

output "cpu_alert_id" {
  description = "ID of the CPU utilization alert"
  value       = module.app_service_plan_advanced.cpu_alert_id
}

output "memory_alert_id" {
  description = "ID of the memory utilization alert"
  value       = module.app_service_plan_advanced.memory_alert_id
}

# Storage outputs
output "diagnostics_storage_account_id" {
  description = "ID of the diagnostics storage account (if created)"
  value       = var.create_diagnostics_storage ? azurerm_storage_account.diagnostics[0].id : null
}

output "diagnostics_storage_account_name" {
  description = "Name of the diagnostics storage account (if created)"
  value       = var.create_diagnostics_storage ? azurerm_storage_account.diagnostics[0].name : null
}

# Network Security Group outputs
output "app_service_nsg_id" {
  description = "ID of the App Service Network Security Group (if created)"
  value       = var.create_app_service_nsg ? azurerm_network_security_group.app_service[0].id : null
}

output "app_service_nsg_name" {
  description = "Name of the App Service Network Security Group (if created)"
  value       = var.create_app_service_nsg ? azurerm_network_security_group.app_service[0].name : null
}

# Complete App Service Plan information
output "app_service_plan_info" {
  description = "Complete App Service Plan information for use by App Services"
  value       = module.app_service_plan_advanced.app_service_plan_info
}

# Summaries for easier consumption
output "scaling_summary" {
  description = "Summary of scaling configuration"
  value       = module.app_service_plan_advanced.scaling_summary
}

output "monitoring_summary" {
  description = "Summary of monitoring configuration"
  value       = module.app_service_plan_advanced.monitoring_summary
}

output "advanced_features_summary" {
  description = "Summary of advanced features enabled"
  value = {
    log_analytics_created          = var.create_log_analytics
    application_insights_created   = var.create_application_insights
    action_group_created           = var.create_action_group
    diagnostics_storage_created    = var.create_diagnostics_storage
    network_security_group_created = var.create_app_service_nsg
    autoscaling_enabled            = var.enable_autoscaling
    alerts_enabled                 = var.enable_alerts
    diagnostic_settings_enabled    = var.enable_diagnostic_settings
  }
}

# Connection information for dependent resources
output "connection_info" {
  description = "Connection information for App Services and other dependent resources"
  value = {
    app_service_plan_id                    = module.app_service_plan_advanced.id
    log_analytics_workspace_id             = var.create_log_analytics ? azurerm_log_analytics_workspace.main[0].id : var.existing_log_analytics_workspace_id
    application_insights_connection_string = var.create_application_insights ? azurerm_application_insights.main[0].connection_string : null
    action_group_id                        = var.create_action_group ? azurerm_monitor_action_group.main[0].id : null
    diagnostics_storage_account_id         = var.create_diagnostics_storage ? azurerm_storage_account.diagnostics[0].id : null
    network_security_group_id              = var.create_app_service_nsg ? azurerm_network_security_group.app_service[0].id : null
  }
  sensitive = true
}

output "tags" {
  description = "Tags applied to all resources"
  value       = module.app_service_plan_advanced.tags
}