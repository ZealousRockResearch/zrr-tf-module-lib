# Primary outputs
output "id" {
  description = "ID of the Azure SQL Database"
  value       = azurerm_mssql_database.main.id
}

output "name" {
  description = "Name of the Azure SQL Database"
  value       = azurerm_mssql_database.main.name
}

output "server_id" {
  description = "ID of the Azure SQL Server hosting the database"
  value       = azurerm_mssql_database.main.server_id
}

# Configuration outputs
output "sku_name" {
  description = "SKU name of the database"
  value       = azurerm_mssql_database.main.sku_name
}

output "max_size_gb" {
  description = "Maximum size of the database in GB"
  value       = azurerm_mssql_database.main.max_size_gb
}

output "collation" {
  description = "Collation of the database"
  value       = azurerm_mssql_database.main.collation
}

output "license_type" {
  description = "License type of the database"
  value       = azurerm_mssql_database.main.license_type
}

# Performance and scaling outputs
output "zone_redundant" {
  description = "Whether the database is zone redundant"
  value       = azurerm_mssql_database.main.zone_redundant
}

output "read_scale" {
  description = "Whether read scale is enabled"
  value       = azurerm_mssql_database.main.read_scale
}

output "auto_pause_delay_in_minutes" {
  description = "Auto pause delay in minutes"
  value       = azurerm_mssql_database.main.auto_pause_delay_in_minutes
}

output "min_capacity" {
  description = "Minimum capacity for serverless databases"
  value       = azurerm_mssql_database.main.min_capacity
}

# Backup and retention outputs
output "short_term_retention_days" {
  description = "Short term retention period in days"
  value       = azurerm_mssql_database.main.short_term_retention_policy[0].retention_days
}

output "backup_interval_in_hours" {
  description = "Backup interval in hours"
  value       = azurerm_mssql_database.main.short_term_retention_policy[0].backup_interval_in_hours
}

# Security outputs
output "transparent_data_encryption_enabled" {
  description = "Whether transparent data encryption is enabled"
  value       = azurerm_mssql_database.main.transparent_data_encryption_enabled
}

output "threat_detection_enabled" {
  description = "Whether threat detection is enabled"
  value       = var.enable_threat_detection
}

output "auditing_enabled" {
  description = "Whether auditing is enabled"
  value       = var.enable_auditing
}

output "vulnerability_assessment_enabled" {
  description = "Whether vulnerability assessment is enabled"
  value       = var.enable_vulnerability_assessment
}

# Storage and geo backup outputs
output "geo_backup_enabled" {
  description = "Whether geo-redundant backup is enabled"
  value       = azurerm_mssql_database.main.geo_backup_enabled
}

output "storage_account_type" {
  description = "Storage account type for backups"
  value       = azurerm_mssql_database.main.storage_account_type
}

# Read replica outputs
output "read_replica_count" {
  description = "Number of read replicas"
  value       = azurerm_mssql_database.main.read_replica_count
}

# Creation mode outputs
output "create_mode" {
  description = "Database creation mode"
  value       = azurerm_mssql_database.main.create_mode
}

# Tags output
output "tags" {
  description = "Tags applied to the Azure SQL Database"
  value       = azurerm_mssql_database.main.tags
}