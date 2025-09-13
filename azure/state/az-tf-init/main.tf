# azure-state-az-tf-init module
# Description: Manages Azure infrastructure for Terraform state management including storage account, key vault, and RBAC

# Data sources
data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

# Local values
locals {
  common_tags = merge(
    var.common_tags,
    var.az_tf_init_tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "zrr-tf-module-lib/azure/state/az-tf-init"
      "Layer"     = "state"
      "Purpose"   = "terraform-state-management"
    }
  )

  # Generate standardized names
  resource_group_name = var.use_naming_convention ? "rg-${var.project_name}-${var.environment}-tfstate-${var.location_short}" : var.resource_group_name

  storage_account_name = var.use_naming_convention ? "sa${var.project_name}${var.environment}tfstate${var.location_short}${random_string.suffix.result}" : var.storage_account_name

  key_vault_name = var.use_naming_convention ? "kv-${var.project_name}-${var.environment}-tfstate-${random_string.suffix.result}" : var.key_vault_name

  container_name = var.container_name

  # State locking table name (using storage account for consistency with Azure)
  state_lock_container = "${local.container_name}-locks"
}

# Random suffix for globally unique names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Resource Group for Terraform state infrastructure
resource "azurerm_resource_group" "tfstate" {
  name     = local.resource_group_name
  location = var.location

  tags = local.common_tags
}

# Storage Account for Terraform state
resource "azurerm_storage_account" "tfstate" {
  name                = local.storage_account_name
  resource_group_name = azurerm_resource_group.tfstate.name
  location            = azurerm_resource_group.tfstate.location

  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  account_kind             = "StorageV2"

  # Security settings
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = var.enable_shared_access_key

  # Network security
  public_network_access_enabled = var.enable_public_network_access

  # Blob properties for versioning and protection
  blob_properties {
    versioning_enabled  = var.enable_blob_versioning
    change_feed_enabled = false

    delete_retention_policy {
      days = var.blob_soft_delete_retention_days
    }

    container_delete_retention_policy {
      days = var.container_soft_delete_retention_days
    }
  }

  # Network rules if specified
  dynamic "network_rules" {
    for_each = var.enable_network_restrictions ? [1] : []
    content {
      default_action             = var.network_default_action
      bypass                     = ["AzureServices", "Logging", "Metrics"]
      ip_rules                   = var.allowed_ip_ranges
      virtual_network_subnet_ids = var.allowed_subnet_ids
    }
  }

  tags = local.common_tags
}

# Storage Container for Terraform state files
resource "azurerm_storage_container" "tfstate" {
  name                  = local.container_name
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"

  metadata = {
    purpose     = "terraform-state"
    environment = var.environment
    project     = var.project_name
  }
}

# Storage Container for state locking
resource "azurerm_storage_container" "tfstate_locks" {
  count = var.enable_state_locking ? 1 : 0

  name                  = local.state_lock_container
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"

  metadata = {
    purpose     = "terraform-state-locking"
    environment = var.environment
    project     = var.project_name
  }
}

# Key Vault for state encryption and secrets
resource "azurerm_key_vault" "tfstate" {
  count = var.enable_key_vault ? 1 : 0

  name                = local.key_vault_name
  location            = azurerm_resource_group.tfstate.location
  resource_group_name = azurerm_resource_group.tfstate.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.key_vault_sku

  # Security settings
  enable_rbac_authorization  = var.enable_key_vault_rbac
  purge_protection_enabled   = var.enable_key_vault_purge_protection
  soft_delete_retention_days = var.key_vault_soft_delete_retention_days

  # Network access
  public_network_access_enabled = var.enable_key_vault_public_access

  # Network ACLs if specified
  dynamic "network_acls" {
    for_each = var.enable_key_vault_network_restrictions ? [1] : []
    content {
      default_action             = var.key_vault_network_default_action
      bypass                     = "AzureServices"
      ip_rules                   = var.key_vault_allowed_ip_ranges
      virtual_network_subnet_ids = var.key_vault_allowed_subnet_ids
    }
  }

  tags = local.common_tags
}

# Key Vault access policy for current user/service principal (if using access policies)
resource "azurerm_key_vault_access_policy" "current_user" {
  count = var.enable_key_vault && !var.enable_key_vault_rbac ? 1 : 0

  key_vault_id = azurerm_key_vault.tfstate[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "List",
    "Update",
    "Import",
    "Backup",
    "Restore",
    "Recover"
  ]

  secret_permissions = [
    "Set",
    "Get",
    "Delete",
    "List",
    "Recover",
    "Backup",
    "Restore"
  ]

  certificate_permissions = [
    "Create",
    "Delete",
    "Get",
    "List",
    "Update",
    "Import"
  ]
}

# Additional access policies for specified users/groups
resource "azurerm_key_vault_access_policy" "additional" {
  count = var.enable_key_vault && !var.enable_key_vault_rbac ? length(var.additional_access_policies) : 0

  key_vault_id = azurerm_key_vault.tfstate[0].id
  tenant_id    = var.additional_access_policies[count.index].tenant_id
  object_id    = var.additional_access_policies[count.index].object_id

  key_permissions         = lookup(var.additional_access_policies[count.index], "key_permissions", [])
  secret_permissions      = lookup(var.additional_access_policies[count.index], "secret_permissions", [])
  certificate_permissions = lookup(var.additional_access_policies[count.index], "certificate_permissions", [])
}

# Storage Account RBAC assignments
resource "azurerm_role_assignment" "storage_contributors" {
  count = length(var.storage_contributors)

  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.storage_contributors[count.index]
}

resource "azurerm_role_assignment" "storage_readers" {
  count = length(var.storage_readers)

  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = var.storage_readers[count.index]
}

# Key Vault RBAC assignments (if RBAC is enabled)
resource "azurerm_role_assignment" "key_vault_administrators" {
  count = var.enable_key_vault && var.enable_key_vault_rbac ? length(var.key_vault_administrators) : 0

  scope                = azurerm_key_vault.tfstate[0].id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.key_vault_administrators[count.index]
}

resource "azurerm_role_assignment" "key_vault_users" {
  count = var.enable_key_vault && var.enable_key_vault_rbac ? length(var.key_vault_users) : 0

  scope                = azurerm_key_vault.tfstate[0].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.key_vault_users[count.index]
}

# Log Analytics Workspace for monitoring (optional)
resource "azurerm_log_analytics_workspace" "tfstate" {
  count = var.enable_monitoring ? 1 : 0

  name                = "law-${var.project_name}-${var.environment}-tfstate"
  location            = azurerm_resource_group.tfstate.location
  resource_group_name = azurerm_resource_group.tfstate.name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_days

  tags = local.common_tags
}

# Diagnostic settings for Storage Account
resource "azurerm_monitor_diagnostic_setting" "storage_account" {
  count = var.enable_monitoring ? 1 : 0

  name                       = "diag-${azurerm_storage_account.tfstate.name}"
  target_resource_id         = azurerm_storage_account.tfstate.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.tfstate[0].id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Transaction"
    enabled  = true
  }

  metric {
    category = "Capacity"
    enabled  = true
  }
}

# Diagnostic settings for Key Vault
resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  count = var.enable_key_vault && var.enable_monitoring ? 1 : 0

  name                       = "diag-${azurerm_key_vault.tfstate[0].name}"
  target_resource_id         = azurerm_key_vault.tfstate[0].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.tfstate[0].id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}