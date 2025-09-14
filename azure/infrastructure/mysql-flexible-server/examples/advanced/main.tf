module "mysql_server_advanced" {
  source = "../../"

  name                   = var.mysql_server_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  # Server configuration
  sku_name          = var.sku_name
  mysql_version     = var.mysql_version
  storage_size_gb   = var.storage_size_gb
  storage_iops      = var.storage_iops
  availability_zone = var.availability_zone

  # High availability
  high_availability_mode    = var.high_availability_mode
  standby_availability_zone = var.standby_availability_zone

  # Backup configuration
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  # Networking
  delegated_subnet_id           = var.delegated_subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = var.public_network_access_enabled

  # Security
  identity_type                     = var.identity_type
  identity_ids                      = var.identity_ids
  customer_managed_key_id           = var.customer_managed_key_id
  primary_user_assigned_identity_id = var.primary_user_assigned_identity_id

  # Databases
  databases = var.databases

  # Server configurations
  server_configurations = var.server_configurations

  # Firewall rules
  firewall_rules = var.firewall_rules

  # Azure AD administrator
  aad_administrator = var.aad_administrator

  # Maintenance window
  maintenance_window = var.maintenance_window

  # Private endpoint
  enable_private_endpoint      = var.enable_private_endpoint
  private_endpoint_subnet_id   = var.private_endpoint_subnet_id
  private_endpoint_dns_zone_id = var.private_endpoint_dns_zone_id

  # Monitoring and alerting
  enable_monitoring          = var.enable_monitoring
  alert_email_addresses      = var.alert_email_addresses
  cpu_alert_threshold        = var.cpu_alert_threshold
  memory_alert_threshold     = var.memory_alert_threshold
  connection_alert_threshold = var.connection_alert_threshold

  # Diagnostic settings
  enable_diagnostic_settings    = var.enable_diagnostic_settings
  log_analytics_workspace_id    = var.log_analytics_workspace_id
  diagnostic_storage_account_id = var.diagnostic_storage_account_id

  # Tags
  common_tags = var.common_tags
  mysql_tags  = var.mysql_tags
}

# Output all key values for reference
output "mysql_server_id" {
  description = "ID of the MySQL server"
  value       = module.mysql_server_advanced.id
}

output "mysql_server_name" {
  description = "Name of the MySQL server"
  value       = module.mysql_server_advanced.name
}

output "mysql_server_fqdn" {
  description = "FQDN of the MySQL server"
  value       = module.mysql_server_advanced.fqdn
}

output "high_availability_enabled" {
  description = "Whether high availability is enabled"
  value       = module.mysql_server_advanced.high_availability_enabled
}

output "high_availability_mode" {
  description = "High availability mode"
  value       = module.mysql_server_advanced.high_availability_mode
}

output "standby_availability_zone" {
  description = "Standby availability zone"
  value       = module.mysql_server_advanced.standby_availability_zone
}

output "databases" {
  description = "Created databases"
  value       = module.mysql_server_advanced.databases
}

output "server_configurations" {
  description = "Applied server configurations"
  value       = module.mysql_server_advanced.server_configurations
}

output "firewall_rules" {
  description = "Created firewall rules"
  value       = module.mysql_server_advanced.firewall_rules
}

output "aad_administrator" {
  description = "Azure AD administrator configuration"
  value       = module.mysql_server_advanced.aad_administrator
}

output "private_endpoint_id" {
  description = "ID of the private endpoint"
  value       = module.mysql_server_advanced.private_endpoint_id
}

output "private_endpoint_ip_addresses" {
  description = "Private IP addresses of the private endpoint"
  value       = module.mysql_server_advanced.private_endpoint_ip_addresses
}

output "action_group_id" {
  description = "ID of the monitor action group"
  value       = module.mysql_server_advanced.action_group_id
}

output "cpu_alert_id" {
  description = "ID of the CPU metric alert"
  value       = module.mysql_server_advanced.cpu_alert_id
}

output "memory_alert_id" {
  description = "ID of the memory metric alert"
  value       = module.mysql_server_advanced.memory_alert_id
}

output "connection_alert_id" {
  description = "ID of the connection metric alert"
  value       = module.mysql_server_advanced.connection_alert_id
}

output "diagnostic_setting_id" {
  description = "ID of the diagnostic setting"
  value       = module.mysql_server_advanced.diagnostic_setting_id
}

output "connection_string" {
  description = "MySQL connection string"
  value       = module.mysql_server_advanced.connection_string
  sensitive   = true
}

output "tags" {
  description = "All tags applied to the resources"
  value       = module.mysql_server_advanced.tags
}