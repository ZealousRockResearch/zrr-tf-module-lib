# azure-infrastructure-mysql-flexible-server module
# Description: Manages Azure MySQL Flexible Server with comprehensive enterprise features including high availability, security, backup, monitoring, and networking

# Data sources
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

# Local values
locals {
  common_tags = merge(
    var.common_tags,
    var.mysql_tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "zrr-tf-module-lib/azure/infrastructure/mysql-flexible-server"
      "Layer"     = "infrastructure"
    }
  )

  # Build server name with optional naming convention
  server_name = var.use_naming_convention ? "${var.name}-mysql-${var.environment}-${var.location_short}" : var.name

  # Backup retention configuration
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  # High availability configuration
  high_availability_enabled = var.high_availability_mode != "Disabled"

  # Maintenance window configuration
  maintenance_window = var.maintenance_window != null ? var.maintenance_window : {
    day_of_week  = 0
    start_hour   = 2
    start_minute = 0
  }
}

# MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "main" {
  name                   = local.server_name
  resource_group_name    = data.azurerm_resource_group.main.name
  location               = var.location
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  # Database configuration
  sku_name = var.sku_name
  version  = var.mysql_version
  storage {
    size_gb           = var.storage_size_gb
    iops              = var.storage_iops
    auto_grow_enabled = var.storage_auto_grow_enabled
  }

  # Backup configuration
  backup_retention_days        = local.backup_retention_days
  geo_redundant_backup_enabled = local.geo_redundant_backup_enabled

  # High availability configuration
  dynamic "high_availability" {
    for_each = local.high_availability_enabled ? [1] : []
    content {
      mode                      = var.high_availability_mode
      standby_availability_zone = var.standby_availability_zone
    }
  }

  # Maintenance window
  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      day_of_week  = maintenance_window.value.day_of_week
      start_hour   = maintenance_window.value.start_hour
      start_minute = maintenance_window.value.start_minute
    }
  }

  # Security and networking
  zone                = var.availability_zone
  delegated_subnet_id = var.delegated_subnet_id
  private_dns_zone_id = var.private_dns_zone_id

  # Data encryption
  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key_id != null ? [1] : []
    content {
      key_vault_key_id                     = var.customer_managed_key_id
      primary_user_assigned_identity_id    = var.primary_user_assigned_identity_id
      geo_backup_key_vault_key_id          = var.geo_backup_key_vault_key_id
      geo_backup_user_assigned_identity_id = var.geo_backup_user_assigned_identity_id
    }
  }

  # Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  tags = local.common_tags
}

# MySQL Flexible Server Configuration
resource "azurerm_mysql_flexible_server_configuration" "server_configurations" {
  for_each = var.server_configurations

  name                = each.key
  resource_group_name = data.azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  value               = each.value
}

# MySQL Flexible Server Database
resource "azurerm_mysql_flexible_database" "databases" {
  for_each = { for db in var.databases : db.name => db }

  name                = each.value.name
  resource_group_name = data.azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = each.value.charset
  collation           = each.value.collation
}

# MySQL Flexible Server Firewall Rules
resource "azurerm_mysql_flexible_server_firewall_rule" "firewall_rules" {
  for_each = { for rule in var.firewall_rules : rule.name => rule }

  name                = each.value.name
  resource_group_name = data.azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address
}

# Azure Active Directory Administrator
resource "azurerm_mysql_flexible_server_active_directory_administrator" "aad_admin" {
  count = var.aad_administrator != null ? 1 : 0

  server_id   = azurerm_mysql_flexible_server.main.id
  identity_id = var.aad_administrator.identity_id
  login       = var.aad_administrator.login
  object_id   = var.aad_administrator.object_id
  tenant_id   = var.aad_administrator.tenant_id
}

# Private Endpoint (if enabled)
resource "azurerm_private_endpoint" "mysql" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "${local.server_name}-pe"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${local.server_name}-psc"
    private_connection_resource_id = azurerm_mysql_flexible_server.main.id
    subresource_names              = ["mysqlServer"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_endpoint_dns_zone_id != null ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = [var.private_endpoint_dns_zone_id]
    }
  }

  tags = local.common_tags
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "mysql" {
  count = var.enable_diagnostic_settings ? 1 : 0

  name                       = "${local.server_name}-diagnostics"
  target_resource_id         = azurerm_mysql_flexible_server.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.diagnostic_storage_account_id

  # Metrics
  dynamic "metric" {
    for_each = var.diagnostic_metrics
    content {
      category = metric.value.category
      enabled  = metric.value.enabled

      retention_policy {
        enabled = metric.value.retention_policy.enabled
        days    = metric.value.retention_policy.days
      }
    }
  }

  # Logs
  dynamic "enabled_log" {
    for_each = var.diagnostic_logs
    content {
      category = enabled_log.value.category

      retention_policy {
        enabled = enabled_log.value.retention_policy.enabled
        days    = enabled_log.value.retention_policy.days
      }
    }
  }
}

# Action Group for Alerts
resource "azurerm_monitor_action_group" "mysql_alerts" {
  count = var.enable_monitoring && length(var.alert_email_addresses) > 0 ? 1 : 0

  name                = "${local.server_name}-alerts"
  resource_group_name = data.azurerm_resource_group.main.name
  short_name          = substr(replace(local.server_name, "-", ""), 0, 12)

  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name          = "email-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }

  tags = local.common_tags
}

# CPU Utilization Alert
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  count = var.enable_monitoring && var.cpu_alert_threshold > 0 ? 1 : 0

  name                = "${local.server_name}-cpu-alert"
  resource_group_name = data.azurerm_resource_group.main.name
  scopes              = [azurerm_mysql_flexible_server.main.id]
  description         = "Alert when CPU utilization exceeds ${var.cpu_alert_threshold}%"
  severity            = var.cpu_alert_severity

  criteria {
    metric_namespace = "Microsoft.DBforMySQL/flexibleServers"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_alert_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.mysql_alerts[0].id
  }

  tags = local.common_tags
}

# Memory Utilization Alert
resource "azurerm_monitor_metric_alert" "memory_alert" {
  count = var.enable_monitoring && var.memory_alert_threshold > 0 ? 1 : 0

  name                = "${local.server_name}-memory-alert"
  resource_group_name = data.azurerm_resource_group.main.name
  scopes              = [azurerm_mysql_flexible_server.main.id]
  description         = "Alert when memory utilization exceeds ${var.memory_alert_threshold}%"
  severity            = var.memory_alert_severity

  criteria {
    metric_namespace = "Microsoft.DBforMySQL/flexibleServers"
    metric_name      = "memory_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.memory_alert_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.mysql_alerts[0].id
  }

  tags = local.common_tags
}

# Connection Alert
resource "azurerm_monitor_metric_alert" "connection_alert" {
  count = var.enable_monitoring && var.connection_alert_threshold > 0 ? 1 : 0

  name                = "${local.server_name}-connection-alert"
  resource_group_name = data.azurerm_resource_group.main.name
  scopes              = [azurerm_mysql_flexible_server.main.id]
  description         = "Alert when active connections exceed ${var.connection_alert_threshold}"
  severity            = var.connection_alert_severity

  criteria {
    metric_namespace = "Microsoft.DBforMySQL/flexibleServers"
    metric_name      = "active_connections"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.connection_alert_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.mysql_alerts[0].id
  }

  tags = local.common_tags
}