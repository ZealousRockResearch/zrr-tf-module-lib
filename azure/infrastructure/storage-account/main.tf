# azure-infrastructure-storage-account module
# Description: Manages Azure Storage Accounts with advanced security, monitoring, and data protection features

# Data sources
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

# Local values
locals {
  common_tags = merge(
    var.common_tags,
    var.storage_account_tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "zrr-tf-module-lib/azure/infrastructure/storage-account"
      "Layer"     = "infrastructure"
    }
  )

  # Construct storage account name with naming convention (must be globally unique)
  storage_account_name = var.use_naming_convention ? "sa${var.environment}${replace(var.name, "-", "")}${var.location_short}${random_string.suffix.result}" : var.name

  # Network access rules
  network_rules = var.enable_network_rules ? {
    default_action             = var.network_default_action
    bypass                     = var.network_bypass
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.allowed_subnet_ids
  } : null

  # Flatten containers for easier iteration
  containers_map = { for container in var.containers : container.name => container }

  # Flatten file shares for easier iteration
  file_shares_map = { for share in var.file_shares : share.name => share }

  # Flatten queues for easier iteration
  queues_map = { for queue in var.queues : queue.name => queue }

  # Flatten tables for easier iteration
  tables_map = { for table in var.tables : table.name => table }
}

# Random suffix for storage account name uniqueness
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Storage Account
resource "azurerm_storage_account" "main" {
  name                = local.storage_account_name
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  account_tier             = var.account_tier
  account_replication_type = var.replication_type
  account_kind             = var.account_kind
  access_tier              = var.access_tier

  # Security settings
  enable_https_traffic_only       = var.enable_https_traffic_only
  min_tls_version                 = var.min_tls_version
  allow_nested_items_to_be_public = var.allow_public_access
  shared_access_key_enabled       = var.enable_shared_access_key
  public_network_access_enabled   = var.enable_public_network_access

  # Advanced security features
  infrastructure_encryption_enabled = var.enable_infrastructure_encryption

  # Network rules
  dynamic "network_rules" {
    for_each = local.network_rules != null ? [local.network_rules] : []
    content {
      default_action             = network_rules.value.default_action
      bypass                     = network_rules.value.bypass
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  # Blob properties
  dynamic "blob_properties" {
    for_each = var.enable_blob_properties ? [1] : []
    content {
      versioning_enabled            = var.blob_versioning_enabled
      change_feed_enabled           = var.blob_change_feed_enabled
      change_feed_retention_in_days = var.blob_change_feed_retention_days
      default_service_version       = var.blob_default_service_version
      last_access_time_enabled      = var.blob_last_access_time_enabled

      dynamic "cors_rule" {
        for_each = var.blob_cors_rules
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }

      dynamic "delete_retention_policy" {
        for_each = var.blob_delete_retention_days > 0 ? [1] : []
        content {
          days = var.blob_delete_retention_days
        }
      }

      dynamic "restore_policy" {
        for_each = var.blob_restore_days > 0 ? [1] : []
        content {
          days = var.blob_restore_days
        }
      }

      dynamic "container_delete_retention_policy" {
        for_each = var.container_delete_retention_days > 0 ? [1] : []
        content {
          days = var.container_delete_retention_days
        }
      }
    }
  }

  # Queue properties
  dynamic "queue_properties" {
    for_each = var.enable_queue_properties ? [1] : []
    content {
      dynamic "cors_rule" {
        for_each = var.queue_cors_rules
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }

      dynamic "logging" {
        for_each = var.enable_queue_logging ? [1] : []
        content {
          delete                = var.queue_logging_delete
          read                  = var.queue_logging_read
          write                 = var.queue_logging_write
          version               = var.queue_logging_version
          retention_policy_days = var.queue_logging_retention_days
        }
      }

      dynamic "minute_metrics" {
        for_each = var.enable_queue_metrics ? [1] : []
        content {
          enabled               = true
          version               = var.queue_metrics_version
          include_apis          = var.queue_metrics_include_apis
          retention_policy_days = var.queue_metrics_retention_days
        }
      }

      dynamic "hour_metrics" {
        for_each = var.enable_queue_metrics ? [1] : []
        content {
          enabled               = true
          version               = var.queue_metrics_version
          include_apis          = var.queue_metrics_include_apis
          retention_policy_days = var.queue_metrics_retention_days
        }
      }
    }
  }

  # Share properties
  dynamic "share_properties" {
    for_each = var.enable_share_properties ? [1] : []
    content {
      dynamic "cors_rule" {
        for_each = var.share_cors_rules
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }

      dynamic "retention_policy" {
        for_each = var.share_retention_days > 0 ? [1] : []
        content {
          days = var.share_retention_days
        }
      }

      dynamic "smb" {
        for_each = var.enable_smb_settings ? [1] : []
        content {
          versions                        = var.smb_versions
          authentication_types            = var.smb_authentication_types
          kerberos_ticket_encryption_type = var.smb_kerberos_ticket_encryption
          channel_encryption_type         = var.smb_channel_encryption
        }
      }
    }
  }

  # Static website
  dynamic "static_website" {
    for_each = var.enable_static_website ? [1] : []
    content {
      index_document     = var.static_website_index_document
      error_404_document = var.static_website_error_document
    }
  }

  # Customer managed key
  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key_vault_key_id != "" ? [1] : []
    content {
      key_vault_key_id          = var.customer_managed_key_vault_key_id
      user_assigned_identity_id = var.customer_managed_key_user_assigned_identity_id
    }
  }

  # Identity
  dynamic "identity" {
    for_each = var.identity_type != "" ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  tags = local.common_tags
}

# Storage Containers
resource "azurerm_storage_container" "main" {
  for_each = local.containers_map

  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = lookup(each.value, "access_type", "private")

  metadata = lookup(each.value, "metadata", {})
}

# File Shares
resource "azurerm_storage_share" "main" {
  for_each = local.file_shares_map

  name                 = each.value.name
  storage_account_name = azurerm_storage_account.main.name
  quota                = lookup(each.value, "quota_gb", 5120)
  enabled_protocol     = lookup(each.value, "protocol", "SMB")
  access_tier          = lookup(each.value, "access_tier", "TransactionOptimized")

  metadata = lookup(each.value, "metadata", {})

  dynamic "acl" {
    for_each = lookup(each.value, "acl", [])
    content {
      id = acl.value.id

      dynamic "access_policy" {
        for_each = lookup(acl.value, "access_policy", [])
        content {
          permissions = access_policy.value.permissions
          start       = lookup(access_policy.value, "start", null)
          expiry      = lookup(access_policy.value, "expiry", null)
        }
      }
    }
  }
}

# Queues
resource "azurerm_storage_queue" "main" {
  for_each = local.queues_map

  name                 = each.value.name
  storage_account_name = azurerm_storage_account.main.name

  metadata = lookup(each.value, "metadata", {})
}

# Tables
resource "azurerm_storage_table" "main" {
  for_each = local.tables_map

  name                 = each.value.name
  storage_account_name = azurerm_storage_account.main.name

  dynamic "acl" {
    for_each = lookup(each.value, "acl", [])
    content {
      id = acl.value.id

      dynamic "access_policy" {
        for_each = lookup(acl.value, "access_policy", [])
        content {
          permissions = access_policy.value.permissions
          start       = lookup(access_policy.value, "start", null)
          expiry      = lookup(access_policy.value, "expiry", null)
        }
      }
    }
  }
}

# Storage Account Network Rules (if needed separately)
resource "azurerm_storage_account_network_rules" "main" {
  count = var.enable_network_rules && var.configure_network_rules_separately ? 1 : 0

  storage_account_id = azurerm_storage_account.main.id

  default_action             = var.network_default_action
  bypass                     = var.network_bypass
  ip_rules                   = var.allowed_ip_ranges
  virtual_network_subnet_ids = var.allowed_subnet_ids

  dynamic "private_link_access" {
    for_each = var.private_link_access_rules
    content {
      endpoint_resource_id = private_link_access.value.endpoint_resource_id
      endpoint_tenant_id   = lookup(private_link_access.value, "endpoint_tenant_id", data.azurerm_client_config.current.tenant_id)
    }
  }
}

# Private Endpoints (optional)
resource "azurerm_private_endpoint" "blob" {
  count = var.enable_private_endpoints && contains(var.private_endpoint_subresource_names, "blob") ? 1 : 0

  name                = "pe-${azurerm_storage_account.main.name}-blob"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.main.name}-blob"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_blob_id != "" ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = [var.private_dns_zone_blob_id]
    }
  }

  tags = local.common_tags
}

resource "azurerm_private_endpoint" "file" {
  count = var.enable_private_endpoints && contains(var.private_endpoint_subresource_names, "file") ? 1 : 0

  name                = "pe-${azurerm_storage_account.main.name}-file"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.main.name}-file"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_file_id != "" ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = [var.private_dns_zone_file_id]
    }
  }

  tags = local.common_tags
}

# Management Policy for lifecycle management
resource "azurerm_storage_management_policy" "main" {
  count = var.enable_lifecycle_management ? 1 : 0

  storage_account_id = azurerm_storage_account.main.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      name    = rule.value.name
      enabled = lookup(rule.value, "enabled", true)

      filters {
        prefix_match = lookup(rule.value.filters, "prefix_match", [])
        blob_types   = lookup(rule.value.filters, "blob_types", ["blockBlob"])

        dynamic "match_blob_index_tag" {
          for_each = lookup(rule.value.filters, "match_blob_index_tag", [])
          content {
            name      = match_blob_index_tag.value.name
            operation = lookup(match_blob_index_tag.value, "operation", "==")
            value     = match_blob_index_tag.value.value
          }
        }
      }

      actions {
        dynamic "base_blob" {
          for_each = lookup(rule.value.actions, "base_blob", null) != null ? [rule.value.actions.base_blob] : []
          content {
            tier_to_cool_after_days_since_modification_greater_than        = lookup(base_blob.value, "tier_to_cool_after_days", null)
            tier_to_archive_after_days_since_modification_greater_than     = lookup(base_blob.value, "tier_to_archive_after_days", null)
            delete_after_days_since_modification_greater_than              = lookup(base_blob.value, "delete_after_days", null)
            tier_to_cool_after_days_since_last_access_time_greater_than    = lookup(base_blob.value, "tier_to_cool_after_last_access_days", null)
            tier_to_archive_after_days_since_last_access_time_greater_than = lookup(base_blob.value, "tier_to_archive_after_last_access_days", null)
            delete_after_days_since_last_access_time_greater_than          = lookup(base_blob.value, "delete_after_last_access_days", null)
          }
        }

        dynamic "snapshot" {
          for_each = lookup(rule.value.actions, "snapshot", null) != null ? [rule.value.actions.snapshot] : []
          content {
            change_tier_to_archive_after_days_since_creation = lookup(snapshot.value, "tier_to_archive_after_days", null)
            change_tier_to_cool_after_days_since_creation    = lookup(snapshot.value, "tier_to_cool_after_days", null)
            delete_after_days_since_creation_greater_than    = lookup(snapshot.value, "delete_after_days", null)
          }
        }

        dynamic "version" {
          for_each = lookup(rule.value.actions, "version", null) != null ? [rule.value.actions.version] : []
          content {
            change_tier_to_archive_after_days_since_creation = lookup(version.value, "tier_to_archive_after_days", null)
            change_tier_to_cool_after_days_since_creation    = lookup(version.value, "tier_to_cool_after_days", null)
            delete_after_days_since_creation                 = lookup(version.value, "delete_after_days", null)
          }
        }
      }
    }
  }
}