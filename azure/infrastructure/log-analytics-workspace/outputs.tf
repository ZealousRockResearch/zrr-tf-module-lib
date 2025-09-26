output "id" {
  description = "The ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "name" {
  description = "The name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "workspace_id" {
  description = "The workspace ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.workspace_id
}

output "primary_shared_key" {
  description = "The primary shared key of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}

output "secondary_shared_key" {
  description = "The secondary shared key of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.secondary_shared_key
  sensitive   = true
}

output "location" {
  description = "The location of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.location
}

output "resource_group_name" {
  description = "The resource group name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.resource_group_name
}

output "sku" {
  description = "The SKU of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.sku
}

output "retention_in_days" {
  description = "The retention period in days of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.retention_in_days
}

output "daily_quota_gb" {
  description = "The daily quota in GB of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.daily_quota_gb
}

output "internet_ingestion_enabled" {
  description = "Whether internet ingestion is enabled"
  value       = azurerm_log_analytics_workspace.main.internet_ingestion_enabled
}

output "internet_query_enabled" {
  description = "Whether internet query is enabled"
  value       = azurerm_log_analytics_workspace.main.internet_query_enabled
}

output "identity" {
  description = "The identity of the Log Analytics workspace"
  value       = try(azurerm_log_analytics_workspace.main.identity[0], null)
}

output "solutions" {
  description = "Map of installed Log Analytics solutions"
  value       = { for k, v in azurerm_log_analytics_solution.solutions : k => v.id }
}

output "data_collection_rules" {
  description = "Map of data collection rules"
  value       = { for k, v in azurerm_monitor_data_collection_rule.main : k => v.id }
}

output "saved_searches" {
  description = "Map of saved searches"
  value       = { for k, v in azurerm_log_analytics_saved_search.searches : k => v.id }
}

# Connection information for other services
output "connection_info" {
  description = "Connection information for integrating with other Azure services"
  value = {
    workspace_id           = azurerm_log_analytics_workspace.main.workspace_id
    primary_shared_key     = azurerm_log_analytics_workspace.main.primary_shared_key
    secondary_shared_key   = azurerm_log_analytics_workspace.main.secondary_shared_key
    resource_id           = azurerm_log_analytics_workspace.main.id
    name                  = azurerm_log_analytics_workspace.main.name
    location              = azurerm_log_analytics_workspace.main.location
    resource_group_name   = azurerm_log_analytics_workspace.main.resource_group_name
  }
  sensitive = true
}