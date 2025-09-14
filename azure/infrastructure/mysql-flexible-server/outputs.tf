# Primary outputs
output "id" {
  description = "ID of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.main.id
}

output "name" {
  description = "Name of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.main.name
}

output "fqdn" {
  description = "Fully qualified domain name of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.main.fqdn
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled"
  value       = azurerm_mysql_flexible_server.main.public_network_access_enabled
}

# Server configuration outputs
output "administrator_login" {
  description = "Administrator login name"
  value       = azurerm_mysql_flexible_server.main.administrator_login
}

output "sku_name" {
  description = "SKU name of the server"
  value       = azurerm_mysql_flexible_server.main.sku_name
}

output "version" {
  description = "MySQL version of the server"
  value       = azurerm_mysql_flexible_server.main.version
}

output "zone" {
  description = "Availability zone of the server"
  value       = azurerm_mysql_flexible_server.main.zone
}

# Storage configuration outputs
output "storage_size_gb" {
  description = "Storage size in GB"
  value       = azurerm_mysql_flexible_server.main.storage[0].size_gb
}

output "storage_iops" {
  description = "Storage IOPS"
  value       = azurerm_mysql_flexible_server.main.storage[0].iops
}

output "storage_auto_grow_enabled" {
  description = "Whether storage auto-grow is enabled"
  value       = azurerm_mysql_flexible_server.main.storage[0].auto_grow_enabled
}

# Backup configuration outputs
output "backup_retention_days" {
  description = "Backup retention period in days"
  value       = azurerm_mysql_flexible_server.main.backup_retention_days
}

output "geo_redundant_backup_enabled" {
  description = "Whether geo-redundant backup is enabled"
  value       = azurerm_mysql_flexible_server.main.geo_redundant_backup_enabled
}

# High availability outputs
output "high_availability_enabled" {
  description = "Whether high availability is enabled"
  value       = length(azurerm_mysql_flexible_server.main.high_availability) > 0
}

output "high_availability_mode" {
  description = "High availability mode"
  value       = length(azurerm_mysql_flexible_server.main.high_availability) > 0 ? azurerm_mysql_flexible_server.main.high_availability[0].mode : null
}

output "standby_availability_zone" {
  description = "Standby availability zone"
  value       = length(azurerm_mysql_flexible_server.main.high_availability) > 0 ? azurerm_mysql_flexible_server.main.high_availability[0].standby_availability_zone : null
}

# Maintenance window outputs
output "maintenance_window" {
  description = "Maintenance window configuration"
  value = length(azurerm_mysql_flexible_server.main.maintenance_window) > 0 ? {
    day_of_week  = azurerm_mysql_flexible_server.main.maintenance_window[0].day_of_week
    start_hour   = azurerm_mysql_flexible_server.main.maintenance_window[0].start_hour
    start_minute = azurerm_mysql_flexible_server.main.maintenance_window[0].start_minute
  } : null
}

# Networking outputs
output "delegated_subnet_id" {
  description = "ID of the delegated subnet"
  value       = azurerm_mysql_flexible_server.main.delegated_subnet_id
}

output "private_dns_zone_id" {
  description = "ID of the private DNS zone"
  value       = azurerm_mysql_flexible_server.main.private_dns_zone_id
}

# Security outputs
output "replica_capacity" {
  description = "Replica capacity of the server"
  value       = azurerm_mysql_flexible_server.main.replica_capacity
}

# Database outputs
output "databases" {
  description = "Created databases"
  value = {
    for name, db in azurerm_mysql_flexible_database.databases : name => {
      id        = db.id
      name      = db.name
      charset   = db.charset
      collation = db.collation
    }
  }
}

# Configuration outputs
output "server_configurations" {
  description = "Applied server configurations"
  value = {
    for name, config in azurerm_mysql_flexible_server_configuration.server_configurations : name => {
      name  = config.name
      value = config.value
    }
  }
}

# Firewall rules outputs
output "firewall_rules" {
  description = "Created firewall rules"
  value = {
    for name, rule in azurerm_mysql_flexible_server_firewall_rule.firewall_rules : name => {
      id               = rule.id
      name             = rule.name
      start_ip_address = rule.start_ip_address
      end_ip_address   = rule.end_ip_address
    }
  }
}

# Azure AD administrator outputs
output "aad_administrator" {
  description = "Azure AD administrator configuration"
  value = var.aad_administrator != null ? {
    identity_id = azurerm_mysql_flexible_server_active_directory_administrator.aad_admin[0].identity_id
    login       = azurerm_mysql_flexible_server_active_directory_administrator.aad_admin[0].login
    object_id   = azurerm_mysql_flexible_server_active_directory_administrator.aad_admin[0].object_id
    tenant_id   = azurerm_mysql_flexible_server_active_directory_administrator.aad_admin[0].tenant_id
  } : null
}

# Private endpoint outputs
output "private_endpoint_id" {
  description = "ID of the private endpoint"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.mysql[0].id : null
}

output "private_endpoint_ip_addresses" {
  description = "Private IP addresses of the private endpoint"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.mysql[0].private_service_connection[0].private_ip_address : null
}

# Monitoring outputs
output "diagnostic_setting_id" {
  description = "ID of the diagnostic setting"
  value       = var.enable_diagnostic_settings ? azurerm_monitor_diagnostic_setting.mysql[0].id : null
}

output "action_group_id" {
  description = "ID of the monitor action group"
  value       = var.enable_monitoring && length(var.alert_email_addresses) > 0 ? azurerm_monitor_action_group.mysql_alerts[0].id : null
}

output "cpu_alert_id" {
  description = "ID of the CPU metric alert"
  value       = var.enable_monitoring && var.cpu_alert_threshold > 0 ? azurerm_monitor_metric_alert.cpu_alert[0].id : null
}

output "memory_alert_id" {
  description = "ID of the memory metric alert"
  value       = var.enable_monitoring && var.memory_alert_threshold > 0 ? azurerm_monitor_metric_alert.memory_alert[0].id : null
}

output "connection_alert_id" {
  description = "ID of the connection metric alert"
  value       = var.enable_monitoring && var.connection_alert_threshold > 0 ? azurerm_monitor_metric_alert.connection_alert[0].id : null
}

# Identity outputs
output "identity" {
  description = "Identity configuration of the server"
  value = length(azurerm_mysql_flexible_server.main.identity) > 0 ? {
    type         = azurerm_mysql_flexible_server.main.identity[0].type
    identity_ids = azurerm_mysql_flexible_server.main.identity[0].identity_ids
  } : null
}

# Connection string output (sensitive)
output "connection_string" {
  description = "MySQL connection string"
  value       = "Server=${azurerm_mysql_flexible_server.main.fqdn};Database=mysql;Uid=${azurerm_mysql_flexible_server.main.administrator_login};Pwd=${var.administrator_password};"
  sensitive   = true
}

# Tags output
output "tags" {
  description = "Tags applied to the MySQL server"
  value       = local.common_tags
}