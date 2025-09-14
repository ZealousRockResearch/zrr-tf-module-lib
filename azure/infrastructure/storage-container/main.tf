# azure-infrastructure-storage-container module
# Description: Manages Azure Storage Containers with comprehensive security, access management, and enterprise features

terraform {
  required_version = ">= 1.0"
}

# Data sources
data "azurerm_storage_account" "main" {
  count               = var.storage_account_name != null ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = var.storage_account_resource_group_name
}

data "azurerm_client_config" "current" {}

# Local values
locals {
  common_tags = merge(
    var.common_tags,
    var.storage_container_tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "zrr-tf-module-lib/azure/infrastructure/storage-container"
      "Layer"     = "infrastructure"
    }
  )

  storage_account_name = var.storage_account_id != null ? split("/", var.storage_account_id)[8] : var.storage_account_name
}

# Storage Container
resource "azurerm_storage_container" "main" {
  name                  = var.name
  storage_account_name  = local.storage_account_name
  container_access_type = var.container_access_type
  metadata             = var.metadata
}

# Storage Management Policy (if lifecycle rules are defined)
resource "azurerm_storage_management_policy" "main" {
  count              = length(var.lifecycle_rules) > 0 ? 1 : 0
  storage_account_id = var.storage_account_id != null ? var.storage_account_id : data.azurerm_storage_account.main[0].id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      name    = rule.value.name
      enabled = rule.value.enabled

      filters {
        prefix_match = rule.value.prefix_match
        blob_types   = rule.value.blob_types
      }

      actions {
        base_blob {
          tier_to_cool_after_days_since_modification_greater_than    = rule.value.tier_to_cool_after_days
          tier_to_archive_after_days_since_modification_greater_than = rule.value.tier_to_archive_after_days
          delete_after_days_since_modification_greater_than          = rule.value.delete_after_days
        }

        dynamic "snapshot" {
          for_each = rule.value.snapshot_delete_after_days != null ? [1] : []
          content {
            delete_after_days_since_creation_greater_than = rule.value.snapshot_delete_after_days
          }
        }

        dynamic "version" {
          for_each = rule.value.version_delete_after_days != null ? [1] : []
          content {
            delete_after_days_since_creation = rule.value.version_delete_after_days
          }
        }
      }
    }
  }
}

# Note: Legal Hold and Immutability Policy resources are managed through the container properties
# These features are available in Azure but require specific storage account configurations
# The variables are kept for future provider support and external management

locals {
  # Legal hold configuration for reference
  legal_hold_enabled = var.legal_hold != null
  legal_hold_tags_configured = var.legal_hold != null ? var.legal_hold.tags : []

  # Immutability policy configuration for reference
  immutability_policy_enabled = var.immutability_policy != null
  immutability_period_configured = var.immutability_policy != null ? var.immutability_policy.period_in_days : null
  immutability_locked_configured = var.immutability_policy != null ? var.immutability_policy.locked : false
}