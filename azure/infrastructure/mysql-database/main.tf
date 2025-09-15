# azure-infrastructure-mysql-database module
# Description: Manages Azure MySQL Database with comprehensive enterprise features including database configuration, performance tuning, character sets, and collation settings

# Data sources
data "azurerm_mysql_server" "mysql_server" {
  count               = var.mysql_server_id == null ? 0 : 1
  name                = split("/", var.mysql_server_id)[8]
  resource_group_name = var.resource_group_name
}

data "azurerm_mysql_flexible_server" "mysql_flexible_server" {
  count               = var.mysql_flexible_server_id == null ? 0 : 1
  name                = split("/", var.mysql_flexible_server_id)[8]
  resource_group_name = var.resource_group_name
}

# Local values
locals {
  common_tags = merge(
    var.common_tags,
    var.mysql_database_tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "zrr-tf-module-lib/azure/infrastructure/mysql-database"
      "Layer"     = "infrastructure"
    }
  )

  # Determine server name and type
  server_name = var.mysql_server_id != null ? data.azurerm_mysql_server.mysql_server[0].name : (
    var.mysql_flexible_server_id != null ? data.azurerm_mysql_flexible_server.mysql_flexible_server[0].name : var.mysql_server_name
  )

  # Server type detection
  is_flexible_server = var.mysql_flexible_server_id != null || var.use_flexible_server

  # Database name with optional naming convention
  database_name = var.use_naming_convention ? "${var.name}-db-${var.environment}-${var.location_short}" : var.name

  # Character set validation
  valid_charsets = [
    "armscii8", "ascii", "big5", "binary", "cp1250", "cp1251", "cp1256", "cp1257",
    "cp850", "cp852", "cp866", "cp932", "dec8", "eucjpms", "euckr", "gb18030",
    "gb2312", "gbk", "geostd8", "greek", "hebrew", "hp8", "keybcs2", "koi8r",
    "koi8u", "latin1", "latin2", "latin5", "latin7", "macce", "macroman",
    "sjis", "swe7", "tis620", "ucs2", "ujis", "utf16", "utf16le", "utf32",
    "utf8", "utf8mb3", "utf8mb4"
  ]

  # Collation validation for utf8mb4 (most common)
  valid_utf8mb4_collations = [
    "utf8mb4_general_ci", "utf8mb4_unicode_ci", "utf8mb4_unicode_520_ci",
    "utf8mb4_bin", "utf8mb4_0900_ai_ci", "utf8mb4_0900_as_ci",
    "utf8mb4_0900_as_cs", "utf8mb4_0900_bin"
  ]
}

# MySQL Database (Single Server - Legacy)
resource "azurerm_mysql_database" "main" {
  count               = !local.is_flexible_server ? 1 : 0
  name                = local.database_name
  resource_group_name = var.resource_group_name
  server_name         = local.server_name
  charset             = var.charset
  collation           = var.collation
}

# MySQL Flexible Database (Flexible Server)
resource "azurerm_mysql_flexible_database" "main" {
  count               = local.is_flexible_server ? 1 : 0
  name                = local.database_name
  resource_group_name = var.resource_group_name
  server_name         = local.server_name
  charset             = var.charset
  collation           = var.collation
}

# Additional databases (if specified)
resource "azurerm_mysql_database" "additional" {
  for_each = !local.is_flexible_server ? { for db in var.additional_databases : db.name => db } : {}

  name                = each.value.name
  resource_group_name = var.resource_group_name
  server_name         = local.server_name
  charset             = each.value.charset
  collation           = each.value.collation
}

resource "azurerm_mysql_flexible_database" "additional" {
  for_each = local.is_flexible_server ? { for db in var.additional_databases : db.name => db } : {}

  name                = each.value.name
  resource_group_name = var.resource_group_name
  server_name         = local.server_name
  charset             = each.value.charset
  collation           = each.value.collation
}

# Note: User management is not supported in the AzureRM provider for MySQL
# Users must be created using MySQL client or other tools after server deployment

# Database performance configuration (if using Single Server)
resource "azurerm_mysql_configuration" "performance_configs" {
  for_each = !local.is_flexible_server ? var.performance_configurations : {}

  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = local.server_name
  value               = each.value
}

# Database monitoring and alerting
resource "azurerm_monitor_metric_alert" "database_connections" {
  count               = var.enable_monitoring ? 1 : 0
  name                = "${local.database_name}-db-connections-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.mysql_server_id != null ? var.mysql_server_id : var.mysql_flexible_server_id]

  description = "Alert when database connections exceed threshold"
  frequency   = "PT1M"
  window_size = "PT5M"
  severity    = 2

  criteria {
    metric_namespace = "Microsoft.DBforMySQL/servers"
    metric_name      = "active_connections"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.connection_alert_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = local.common_tags
}

resource "azurerm_monitor_metric_alert" "database_storage" {
  count               = var.enable_monitoring && var.storage_alert_threshold > 0 ? 1 : 0
  name                = "${local.database_name}-db-storage-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.mysql_server_id != null ? var.mysql_server_id : var.mysql_flexible_server_id]

  description = "Alert when database storage usage exceeds threshold"
  frequency   = "PT5M"
  window_size = "PT15M"
  severity    = 2

  criteria {
    metric_namespace = "Microsoft.DBforMySQL/servers"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.storage_alert_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = local.common_tags
}

# Database backup configuration (if using Single Server)
resource "azurerm_mysql_virtual_network_rule" "database_vnet_rule" {
  count               = !local.is_flexible_server && var.subnet_id != null ? 1 : 0
  name                = "${local.database_name}-vnet-rule"
  resource_group_name = var.resource_group_name
  server_name         = local.server_name
  subnet_id           = var.subnet_id
}

# Database audit logging (if enabled)
resource "azurerm_mysql_configuration" "audit_log" {
  count               = !local.is_flexible_server && var.enable_audit_logging ? 1 : 0
  name                = "audit_log_enabled"
  resource_group_name = var.resource_group_name
  server_name         = local.server_name
  value               = "ON"
}

resource "azurerm_mysql_configuration" "audit_log_events" {
  count               = !local.is_flexible_server && var.enable_audit_logging ? 1 : 0
  name                = "audit_log_events"
  resource_group_name = var.resource_group_name
  server_name         = local.server_name
  value               = var.audit_log_events
}

# Database slow query logging (if enabled)
resource "azurerm_mysql_configuration" "slow_query_log" {
  count               = !local.is_flexible_server && var.enable_slow_query_log ? 1 : 0
  name                = "slow_query_log"
  resource_group_name = var.resource_group_name
  server_name         = local.server_name
  value               = "ON"
}

resource "azurerm_mysql_configuration" "long_query_time" {
  count               = !local.is_flexible_server && var.enable_slow_query_log ? 1 : 0
  name                = "long_query_time"
  resource_group_name = var.resource_group_name
  server_name         = local.server_name
  value               = tostring(var.slow_query_threshold)
}