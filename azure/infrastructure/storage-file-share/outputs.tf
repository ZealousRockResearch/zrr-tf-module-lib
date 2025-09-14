# Primary outputs
output "id" {
  description = "ID of the storage file share"
  value       = azurerm_storage_share.main.id
}

output "name" {
  description = "Name of the storage file share"
  value       = azurerm_storage_share.main.name
}

output "url" {
  description = "URL of the storage file share"
  value       = azurerm_storage_share.main.url
}

output "storage_account_name" {
  description = "Name of the storage account containing the file share"
  value       = data.azurerm_storage_account.main.name
}

# Configuration outputs
output "quota_gb" {
  description = "Quota of the file share in GB"
  value       = azurerm_storage_share.main.quota
}

output "access_tier" {
  description = "Access tier of the file share"
  value       = azurerm_storage_share.main.access_tier
}

output "enabled_protocol" {
  description = "Enabled protocol for the file share"
  value       = azurerm_storage_share.main.enabled_protocol
}

output "metadata" {
  description = "Metadata of the file share"
  value       = azurerm_storage_share.main.metadata
}

# Directory outputs
output "directories" {
  description = "Created directories in the file share"
  value = {
    for name, dir in azurerm_storage_share_directory.directories : name => {
      id       = dir.id
      name     = dir.name
      metadata = dir.metadata
    }
  }
}

# Backup outputs
output "backup_vault_id" {
  description = "ID of the backup vault (if backup is enabled)"
  value       = var.enable_backup ? azurerm_recovery_services_vault.backup[0].id : null
}

output "backup_vault_name" {
  description = "Name of the backup vault (if backup is enabled)"
  value       = var.enable_backup ? azurerm_recovery_services_vault.backup[0].name : null
}

output "backup_policy_id" {
  description = "ID of the backup policy (if backup is enabled)"
  value       = var.enable_backup ? azurerm_backup_policy_file_share.main[0].id : null
}

output "backup_protected_file_share_id" {
  description = "ID of the protected file share backup (if backup is enabled)"
  value       = var.enable_backup ? azurerm_backup_protected_file_share.main[0].id : null
}

# Monitoring outputs
output "action_group_id" {
  description = "ID of the monitor action group (if monitoring is enabled)"
  value       = var.enable_monitoring && length(var.alert_email_addresses) > 0 ? azurerm_monitor_action_group.main[0].id : null
}

output "quota_alert_id" {
  description = "ID of the quota metric alert (if monitoring is enabled)"
  value       = var.enable_monitoring && var.quota_alert_threshold_percentage > 0 ? azurerm_monitor_metric_alert.quota_alert[0].id : null
}

# Private endpoint outputs
output "private_endpoint_id" {
  description = "ID of the private endpoint (if enabled)"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.file_share[0].id : null
}

output "private_endpoint_ip_addresses" {
  description = "Private IP addresses of the private endpoint (if enabled)"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.file_share[0].private_service_connection[0].private_ip_address : null
}

# Tags output
output "tags" {
  description = "Tags applied to the resources"
  value       = local.common_tags
}