module "mysql_database_advanced" {
  source = "../../"

  name                = var.database_name
  resource_group_name = var.resource_group_name
  mysql_server_name   = var.mysql_server_name
  mysql_server_id     = var.mysql_server_id
  use_flexible_server = var.use_flexible_server

  # Database configuration
  charset   = var.charset
  collation = var.collation

  # Additional databases
  additional_databases = var.additional_databases

  # Database users and privileges (Single Server only)
  database_users = var.database_users

  # Performance configurations
  performance_configurations = var.performance_configurations

  # Monitoring and alerting
  enable_monitoring          = var.enable_monitoring
  action_group_id            = var.action_group_id
  connection_alert_threshold = var.connection_alert_threshold
  storage_alert_threshold    = var.storage_alert_threshold

  # Network security
  subnet_id = var.subnet_id

  # Audit and logging
  enable_audit_logging  = var.enable_audit_logging
  audit_log_events      = var.audit_log_events
  enable_slow_query_log = var.enable_slow_query_log
  slow_query_threshold  = var.slow_query_threshold

  # Naming convention
  use_naming_convention = var.use_naming_convention
  environment           = var.environment
  location_short        = var.location_short

  # Tags
  common_tags         = var.common_tags
  mysql_database_tags = var.mysql_database_tags
}

# Output all key values for reference
output "database_id" {
  description = "ID of the MySQL database"
  value       = module.mysql_database_advanced.id
}

output "database_name" {
  description = "Name of the MySQL database"
  value       = module.mysql_database_advanced.name
}

output "server_name" {
  description = "Name of the MySQL server"
  value       = module.mysql_database_advanced.server_name
}

output "server_type" {
  description = "Type of MySQL server (flexible or single)"
  value       = module.mysql_database_advanced.server_type
}

output "charset" {
  description = "Character set of the database"
  value       = module.mysql_database_advanced.charset
}

output "collation" {
  description = "Collation of the database"
  value       = module.mysql_database_advanced.collation
}

output "additional_databases" {
  description = "Information about additional databases created"
  value       = module.mysql_database_advanced.additional_databases
}

output "user_management_note" {
  description = "Note about user management"
  value       = module.mysql_database_advanced.user_management_note
}

output "performance_configurations" {
  description = "Applied performance configurations"
  value       = module.mysql_database_advanced.performance_configurations
}

output "monitoring_enabled" {
  description = "Whether monitoring is enabled"
  value       = module.mysql_database_advanced.monitoring_enabled
}

output "connection_alert_id" {
  description = "ID of the connection metric alert"
  value       = module.mysql_database_advanced.connection_alert_id
}

output "storage_alert_id" {
  description = "ID of the storage metric alert"
  value       = module.mysql_database_advanced.storage_alert_id
}

output "alert_thresholds" {
  description = "Configured alert thresholds"
  value       = module.mysql_database_advanced.alert_thresholds
}

output "vnet_rule_id" {
  description = "ID of the VNet rule"
  value       = module.mysql_database_advanced.vnet_rule_id
}

output "logging_configuration" {
  description = "Logging configuration details"
  value       = module.mysql_database_advanced.logging_configuration
}

output "database_name_convention" {
  description = "Database naming convention used"
  value       = module.mysql_database_advanced.database_name_convention
}

output "database_summary" {
  description = "Comprehensive summary of the database configuration"
  value       = module.mysql_database_advanced.database_summary
}

output "tags" {
  description = "Tags applied to resources"
  value       = module.mysql_database_advanced.tags
}