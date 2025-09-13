# Database outputs
output "database_id" {
  description = "ID of the created Azure SQL Database"
  value       = module.azure_sql_db_advanced.id
}

output "database_name" {
  description = "Name of the created Azure SQL Database"
  value       = module.azure_sql_db_advanced.name
}

output "server_id" {
  description = "ID of the Azure SQL Server hosting the database"
  value       = module.azure_sql_db_advanced.server_id
}

# Configuration outputs
output "sku_name" {
  description = "SKU name of the database"
  value       = module.azure_sql_db_advanced.sku_name
}

output "max_size_gb" {
  description = "Maximum size of the database in GB"
  value       = module.azure_sql_db_advanced.max_size_gb
}

output "zone_redundant" {
  description = "Whether the database is zone redundant"
  value       = module.azure_sql_db_advanced.zone_redundant
}

output "read_scale" {
  description = "Whether read scale is enabled"
  value       = module.azure_sql_db_advanced.read_scale
}

output "read_replica_count" {
  description = "Number of read replicas"
  value       = module.azure_sql_db_advanced.read_replica_count
}

# Security outputs
output "transparent_data_encryption_enabled" {
  description = "Whether transparent data encryption is enabled"
  value       = module.azure_sql_db_advanced.transparent_data_encryption_enabled
}

output "threat_detection_enabled" {
  description = "Whether threat detection is enabled"
  value       = module.azure_sql_db_advanced.threat_detection_enabled
}

output "auditing_enabled" {
  description = "Whether auditing is enabled"
  value       = module.azure_sql_db_advanced.auditing_enabled
}

output "vulnerability_assessment_enabled" {
  description = "Whether vulnerability assessment is enabled"
  value       = module.azure_sql_db_advanced.vulnerability_assessment_enabled
}

# Backup outputs
output "short_term_retention_days" {
  description = "Short term retention period in days"
  value       = module.azure_sql_db_advanced.short_term_retention_days
}

output "geo_backup_enabled" {
  description = "Whether geo-redundant backup is enabled"
  value       = module.azure_sql_db_advanced.geo_backup_enabled
}

output "storage_account_type" {
  description = "Storage account type for backups"
  value       = module.azure_sql_db_advanced.storage_account_type
}

# Advanced example specific outputs
output "audit_storage_account_id" {
  description = "ID of the audit storage account (if created)"
  value       = var.create_audit_storage ? azurerm_storage_account.audit_storage[0].id : null
}

output "audit_storage_account_name" {
  description = "Name of the audit storage account (if created)"
  value       = var.create_audit_storage ? azurerm_storage_account.audit_storage[0].name : null
}

output "audit_storage_primary_blob_endpoint" {
  description = "Primary blob endpoint of the audit storage account (if created)"
  value       = var.create_audit_storage ? azurerm_storage_account.audit_storage[0].primary_blob_endpoint : null
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace (if created)"
  value       = var.create_log_analytics ? azurerm_log_analytics_workspace.main[0].id : null
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace (if created)"
  value       = var.create_log_analytics ? azurerm_log_analytics_workspace.main[0].name : null
}

output "diagnostic_setting_id" {
  description = "ID of the diagnostic setting (if created)"
  value       = var.enable_diagnostic_settings ? azurerm_monitor_diagnostic_setting.main[0].id : null
}

# Connection information
output "connection_info" {
  description = "Database connection information"
  value = {
    database_name = module.azure_sql_db_advanced.name
    server_id     = module.azure_sql_db_advanced.server_id
    sku_name      = module.azure_sql_db_advanced.sku_name
    collation     = module.azure_sql_db_advanced.collation
    license_type  = module.azure_sql_db_advanced.license_type
  }
}

# Security summary
output "security_summary" {
  description = "Summary of security features enabled"
  value = {
    transparent_data_encryption = module.azure_sql_db_advanced.transparent_data_encryption_enabled
    threat_detection            = module.azure_sql_db_advanced.threat_detection_enabled
    auditing                    = module.azure_sql_db_advanced.auditing_enabled
    vulnerability_assessment    = module.azure_sql_db_advanced.vulnerability_assessment_enabled
    geo_backup                  = module.azure_sql_db_advanced.geo_backup_enabled
  }
}

# Performance summary
output "performance_summary" {
  description = "Summary of performance configurations"
  value = {
    sku_name           = module.azure_sql_db_advanced.sku_name
    max_size_gb        = module.azure_sql_db_advanced.max_size_gb
    zone_redundant     = module.azure_sql_db_advanced.zone_redundant
    read_scale         = module.azure_sql_db_advanced.read_scale
    read_replica_count = module.azure_sql_db_advanced.read_replica_count
  }
}

output "tags" {
  description = "Tags applied to all resources"
  value       = module.azure_sql_db_advanced.tags
}