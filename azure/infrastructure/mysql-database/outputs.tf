# Primary database outputs
output "id" {
  description = "ID of the MySQL database"
  value       = local.is_flexible_server ? azurerm_mysql_flexible_database.main[0].id : azurerm_mysql_database.main[0].id
}

output "name" {
  description = "Name of the MySQL database"
  value       = local.is_flexible_server ? azurerm_mysql_flexible_database.main[0].name : azurerm_mysql_database.main[0].name
}

output "server_name" {
  description = "Name of the MySQL server hosting the database"
  value       = local.server_name
}

output "charset" {
  description = "Character set of the database"
  value       = var.charset
}

output "collation" {
  description = "Collation of the database"
  value       = var.collation
}

# Server information
output "server_type" {
  description = "Type of MySQL server (flexible or single)"
  value       = local.is_flexible_server ? "flexible" : "single"
}

output "is_flexible_server" {
  description = "Whether the database is on a Flexible Server"
  value       = local.is_flexible_server
}

# Additional databases outputs
output "additional_databases" {
  description = "Information about additional databases created"
  value = local.is_flexible_server ? {
    for name, db in azurerm_mysql_flexible_database.additional : name => {
      id        = db.id
      name      = db.name
      charset   = db.charset
      collation = db.collation
    }
    } : {
    for name, db in azurerm_mysql_database.additional : name => {
      id        = db.id
      name      = db.name
      charset   = db.charset
      collation = db.collation
    }
  }
}

output "additional_database_count" {
  description = "Number of additional databases created"
  value       = length(var.additional_databases)
}

# User management note
output "user_management_note" {
  description = "Note about user management"
  value       = "User management must be done using MySQL client or other tools - not supported in AzureRM provider"
}

output "user_count" {
  description = "Number of database users configured (for reference only)"
  value       = length(var.database_users)
  sensitive   = true
}

# Performance configuration outputs
output "performance_configurations" {
  description = "Applied performance configurations"
  value       = var.performance_configurations
}

output "performance_config_count" {
  description = "Number of performance configurations applied"
  value       = length(var.performance_configurations)
}

# Monitoring outputs
output "monitoring_enabled" {
  description = "Whether monitoring is enabled for the database"
  value       = var.enable_monitoring
}

output "connection_alert_id" {
  description = "ID of the connection metric alert"
  value       = var.enable_monitoring ? azurerm_monitor_metric_alert.database_connections[0].id : null
}

output "storage_alert_id" {
  description = "ID of the storage metric alert"
  value       = var.enable_monitoring && var.storage_alert_threshold > 0 ? azurerm_monitor_metric_alert.database_storage[0].id : null
}

output "alert_thresholds" {
  description = "Configured alert thresholds"
  value = {
    connections = var.connection_alert_threshold
    storage     = var.storage_alert_threshold
  }
}

# Network security outputs
output "vnet_rule_id" {
  description = "ID of the VNet rule (Single Server only)"
  value       = !local.is_flexible_server && var.subnet_id != null ? azurerm_mysql_virtual_network_rule.database_vnet_rule[0].id : null
}

output "subnet_id" {
  description = "Subnet ID used for VNet integration"
  value       = var.subnet_id
}

# Audit and logging outputs
output "audit_logging_enabled" {
  description = "Whether audit logging is enabled"
  value       = var.enable_audit_logging
}

output "slow_query_logging_enabled" {
  description = "Whether slow query logging is enabled"
  value       = var.enable_slow_query_log
}

output "logging_configuration" {
  description = "Logging configuration details"
  value = {
    audit_logging        = var.enable_audit_logging
    audit_events         = var.audit_log_events
    slow_query_log       = var.enable_slow_query_log
    slow_query_threshold = var.slow_query_threshold
  }
}

# Naming and identification outputs
output "database_name_convention" {
  description = "Database naming convention used"
  value = {
    use_convention = var.use_naming_convention
    original_name  = var.name
    final_name     = local.database_name
    environment    = var.environment
    location_short = var.location_short
  }
}

output "resource_group_name" {
  description = "Resource group name containing the database"
  value       = var.resource_group_name
}

# Tags output
output "tags" {
  description = "Tags applied to monitoring resources"
  value       = local.common_tags
}

output "database_summary" {
  description = "Comprehensive summary of the database configuration"
  value = {
    name               = local.database_name
    server_name        = local.server_name
    server_type        = local.is_flexible_server ? "flexible" : "single"
    charset            = var.charset
    collation          = var.collation
    additional_dbs     = length(var.additional_databases)
    users_configured   = length(var.database_users)
    monitoring_enabled = var.enable_monitoring
    audit_enabled      = var.enable_audit_logging
    slow_log_enabled   = var.enable_slow_query_log
    vnet_integrated    = var.subnet_id != null
  }
  sensitive = true
}