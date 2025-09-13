# azure-application-azure-sql-db module
# Description: Creates an Azure SQL Database with comprehensive security and monitoring features

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}

data "azurerm_mssql_server" "main" {
  count               = var.sql_server_id != null ? 0 : 1
  name                = var.sql_server_name
  resource_group_name = var.resource_group_name
}

# Local values
locals {
  common_tags = merge(
    var.common_tags,
    var.azure_sql_db_tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "zrr-tf-module-lib/azure/application/azure-sql-db"
      "Layer"     = "application"
    }
  )

  sql_server_id = var.sql_server_id != null ? var.sql_server_id : data.azurerm_mssql_server.main[0].id
}

# Main Azure SQL Database resource
resource "azurerm_mssql_database" "main" {
  name      = var.name
  server_id = local.sql_server_id

  # Performance and scaling
  sku_name                    = var.sku_name
  max_size_gb                 = var.max_size_gb
  zone_redundant              = var.zone_redundant
  read_scale                  = var.read_scale
  auto_pause_delay_in_minutes = var.auto_pause_delay_in_minutes
  min_capacity                = var.min_capacity

  # Backup and retention
  short_term_retention_policy {
    retention_days           = var.short_term_retention_days
    backup_interval_in_hours = var.backup_interval_in_hours
  }

  dynamic "long_term_retention_policy" {
    for_each = var.long_term_retention_policy != null ? [var.long_term_retention_policy] : []
    content {
      weekly_retention  = long_term_retention_policy.value.weekly_retention
      monthly_retention = long_term_retention_policy.value.monthly_retention
      yearly_retention  = long_term_retention_policy.value.yearly_retention
      week_of_year      = long_term_retention_policy.value.week_of_year
    }
  }

  # Threat protection
  dynamic "threat_detection_policy" {
    for_each = var.enable_threat_detection ? [1] : []
    content {
      state                      = "Enabled"
      email_account_admins       = var.threat_detection_email_admins
      email_addresses            = var.threat_detection_email_addresses
      retention_days             = var.threat_detection_retention_days
      storage_account_access_key = var.threat_detection_storage_account_access_key
      storage_endpoint           = var.threat_detection_storage_endpoint
    }
  }

  # Collation and license
  collation          = var.collation
  license_type       = var.license_type
  read_replica_count = var.read_replica_count

  # Creation mode and source
  create_mode                 = var.create_mode
  creation_source_database_id = var.creation_source_database_id
  restore_point_in_time       = var.restore_point_in_time
  recover_database_id         = var.recover_database_id
  restore_dropped_database_id = var.restore_dropped_database_id

  # Geo backup and replication
  geo_backup_enabled   = var.geo_backup_enabled
  storage_account_type = var.storage_account_type

  # Transparent data encryption
  transparent_data_encryption_enabled = var.transparent_data_encryption_enabled

  tags = local.common_tags
}

# Database auditing (if enabled)
resource "azurerm_mssql_database_extended_auditing_policy" "main" {
  count       = var.enable_auditing ? 1 : 0
  database_id = azurerm_mssql_database.main.id

  storage_endpoint                        = var.auditing_storage_endpoint
  storage_account_access_key              = var.auditing_storage_account_access_key
  storage_account_access_key_is_secondary = var.auditing_storage_account_access_key_is_secondary
  retention_in_days                       = var.auditing_retention_days

  log_monitoring_enabled = var.auditing_log_monitoring_enabled
}

# Note: Vulnerability assessment requires additional server-level configuration
# and is typically managed at the server level rather than database level.
# For vulnerability assessment, configure it on the SQL Server resource.