module "azure_sql_db_advanced" {
  source = "../../"

  name                = var.database_name
  sql_server_name     = var.sql_server_name
  resource_group_name = var.resource_group_name

  # Performance and scaling configuration
  sku_name                    = var.sku_name
  max_size_gb                 = var.max_size_gb
  zone_redundant              = var.zone_redundant
  read_scale                  = var.read_scale
  read_replica_count          = var.read_replica_count
  auto_pause_delay_in_minutes = var.auto_pause_delay_in_minutes
  min_capacity                = var.min_capacity

  # Backup and retention configuration
  short_term_retention_days  = var.short_term_retention_days
  backup_interval_in_hours   = var.backup_interval_in_hours
  long_term_retention_policy = var.long_term_retention_policy
  geo_backup_enabled         = var.geo_backup_enabled
  storage_account_type       = var.storage_account_type

  # Security configuration
  enable_threat_detection                     = var.enable_threat_detection
  threat_detection_email_admins               = var.threat_detection_email_admins
  threat_detection_email_addresses            = var.threat_detection_email_addresses
  threat_detection_retention_days             = var.threat_detection_retention_days
  threat_detection_storage_endpoint           = var.threat_detection_storage_endpoint
  threat_detection_storage_account_access_key = var.threat_detection_storage_account_access_key
  transparent_data_encryption_enabled         = var.transparent_data_encryption_enabled

  # Auditing configuration
  enable_auditing                                  = var.enable_auditing
  auditing_storage_endpoint                        = var.auditing_storage_endpoint
  auditing_storage_account_access_key              = var.auditing_storage_account_access_key
  auditing_storage_account_access_key_is_secondary = var.auditing_storage_account_access_key_is_secondary
  auditing_retention_days                          = var.auditing_retention_days
  auditing_log_monitoring_enabled                  = var.auditing_log_monitoring_enabled

  # Vulnerability assessment
  enable_vulnerability_assessment         = var.enable_vulnerability_assessment
  vulnerability_assessment_baseline_rules = var.vulnerability_assessment_baseline_rules

  # Database configuration
  collation    = var.collation
  license_type = var.license_type

  # Creation options
  create_mode                 = var.create_mode
  creation_source_database_id = var.creation_source_database_id
  restore_point_in_time       = var.restore_point_in_time
  recover_database_id         = var.recover_database_id
  restore_dropped_database_id = var.restore_dropped_database_id

  common_tags       = var.common_tags
  azure_sql_db_tags = var.azure_sql_db_tags
}

# Additional resources for advanced example

# Storage account for auditing and threat detection (if endpoints provided)
resource "azurerm_storage_account" "audit_storage" {
  count = var.create_audit_storage ? 1 : 0

  name                     = var.audit_storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = var.auditing_retention_days
    }
  }

  tags = merge(var.common_tags, {
    Purpose = "sql-audit-storage"
  })
}

# Log Analytics Workspace for monitoring (optional)
resource "azurerm_log_analytics_workspace" "main" {
  count = var.create_log_analytics ? 1 : 0

  name                = "${var.database_name}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days

  tags = merge(var.common_tags, {
    Purpose = "sql-monitoring"
  })
}

# Diagnostic settings for comprehensive monitoring
resource "azurerm_monitor_diagnostic_setting" "main" {
  count = var.enable_diagnostic_settings ? 1 : 0

  name                       = "${var.database_name}-diagnostics"
  target_resource_id         = module.azure_sql_db_advanced.id
  log_analytics_workspace_id = var.create_log_analytics ? azurerm_log_analytics_workspace.main[0].id : var.existing_log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.diagnostic_log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = var.diagnostic_metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
}