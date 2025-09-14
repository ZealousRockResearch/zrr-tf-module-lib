# azure-infrastructure-storage-file-share module
# Description: Manages Azure Storage File Shares with comprehensive enterprise features including quotas, access tiers, backup, and monitoring

# Data sources
data "azurerm_storage_account" "main" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

# Local values
locals {
  common_tags = merge(
    var.common_tags,
    var.file_share_tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "zrr-tf-module-lib/azure/infrastructure/storage-file-share"
      "Layer"     = "infrastructure"
    }
  )
}

# Storage File Share
resource "azurerm_storage_share" "main" {
  name                 = var.name
  storage_account_name = data.azurerm_storage_account.main.name
  quota                = var.quota_gb
  access_tier          = var.access_tier
  enabled_protocol     = var.enabled_protocol

  dynamic "acl" {
    for_each = var.access_policies
    content {
      id = acl.value.id

      dynamic "access_policy" {
        for_each = acl.value.access_policies
        content {
          permissions = access_policy.value.permissions
          start       = access_policy.value.start
          expiry      = access_policy.value.expiry
        }
      }
    }
  }

  metadata = var.metadata
}

# Storage File Share Directories
resource "azurerm_storage_share_directory" "directories" {
  for_each = { for dir in var.directories : dir.name => dir }

  name             = each.value.name
  share_name       = azurerm_storage_share.main.name
  storage_account_name = data.azurerm_storage_account.main.name

  metadata = each.value.metadata
}

# Recovery Services Vault (if backup is enabled)
resource "azurerm_recovery_services_vault" "backup" {
  count = var.enable_backup ? 1 : 0

  name                = var.backup_vault_name != null ? var.backup_vault_name : "${var.name}-backup-vault"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.backup_vault_sku

  storage_mode_type   = "LocallyRedundant"
  soft_delete_enabled = var.backup_soft_delete_enabled

  tags = local.common_tags
}

# Backup Policy for File Shares
resource "azurerm_backup_policy_file_share" "main" {
  count = var.enable_backup ? 1 : 0

  name                = "${var.name}-backup-policy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.backup[0].name

  dynamic "backup" {
    for_each = [var.backup_policy]
    content {
      frequency = backup.value.frequency
      time      = backup.value.time
    }
  }

  dynamic "retention_daily" {
    for_each = var.backup_policy.retention_daily != null ? [var.backup_policy.retention_daily] : []
    content {
      count = retention_daily.value.count
    }
  }

  dynamic "retention_weekly" {
    for_each = var.backup_policy.retention_weekly != null ? [var.backup_policy.retention_weekly] : []
    content {
      count    = retention_weekly.value.count
      weekdays = retention_weekly.value.weekdays
    }
  }

  dynamic "retention_monthly" {
    for_each = var.backup_policy.retention_monthly != null ? [var.backup_policy.retention_monthly] : []
    content {
      count    = retention_monthly.value.count
      weekdays = retention_monthly.value.weekdays
      weeks    = retention_monthly.value.weeks
    }
  }

  dynamic "retention_yearly" {
    for_each = var.backup_policy.retention_yearly != null ? [var.backup_policy.retention_yearly] : []
    content {
      count    = retention_yearly.value.count
      weekdays = retention_yearly.value.weekdays
      weeks    = retention_yearly.value.weeks
      months   = retention_yearly.value.months
    }
  }
}

# Backup Container and Protected File Share
resource "azurerm_backup_container_storage_account" "main" {
  count = var.enable_backup ? 1 : 0

  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.backup[0].name
  storage_account_id  = data.azurerm_storage_account.main.id
}

resource "azurerm_backup_protected_file_share" "main" {
  count = var.enable_backup ? 1 : 0

  resource_group_name       = var.resource_group_name
  recovery_vault_name       = azurerm_recovery_services_vault.backup[0].name
  source_storage_account_id = data.azurerm_storage_account.main.id
  source_file_share_name    = azurerm_storage_share.main.name
  backup_policy_id          = azurerm_backup_policy_file_share.main[0].id

  depends_on = [azurerm_backup_container_storage_account.main]
}

# Monitor Action Group (if monitoring is enabled)
resource "azurerm_monitor_action_group" "main" {
  count = var.enable_monitoring && length(var.alert_email_addresses) > 0 ? 1 : 0

  name                = "${var.name}-action-group"
  resource_group_name = var.resource_group_name
  short_name          = substr(replace(var.name, "-", ""), 0, 12)

  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name          = "email-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }

  tags = local.common_tags
}

# Storage Quota Alert
resource "azurerm_monitor_metric_alert" "quota_alert" {
  count = var.enable_monitoring && var.quota_alert_threshold_percentage > 0 ? 1 : 0

  name                = "${var.name}-quota-alert"
  resource_group_name = var.resource_group_name
  scopes              = [data.azurerm_storage_account.main.id]
  description         = "Alert when file share quota usage exceeds ${var.quota_alert_threshold_percentage}%"
  severity            = var.quota_alert_severity

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts/fileServices"
    metric_name      = "FileCapacity"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = (var.quota_gb * 1024 * 1024 * 1024 * var.quota_alert_threshold_percentage) / 100

    dimension {
      name     = "FileShare"
      operator = "Include"
      values   = [var.name]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.main[0].id
  }

  tags = local.common_tags
}

# Private Endpoint (if enabled)
resource "azurerm_private_endpoint" "file_share" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "${var.name}-file-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-file-psc"
    private_connection_resource_id = data.azurerm_storage_account.main.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id != null ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }

  tags = local.common_tags
}