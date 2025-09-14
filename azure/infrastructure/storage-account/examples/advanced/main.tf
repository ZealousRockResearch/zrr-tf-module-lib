# Advanced Enterprise Azure Storage Account Example
# This example demonstrates comprehensive enterprise features including:
# - Enhanced security with private endpoints and network restrictions
# - Advanced data protection and lifecycle management
# - Customer-managed encryption keys
# - Comprehensive monitoring and analytics
# - Multiple storage services with advanced configurations

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Data sources for existing infrastructure
data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

# Resource Group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-storage-advanced-example"
  location = "East US"

  tags = {
    Environment = "prod"
    Project     = "zrr-terraform-modules"
    Purpose     = "advanced-storage-example"
    Criticality = "high"
  }
}

# Virtual Network for private endpoints
resource "azurerm_virtual_network" "example" {
  name                = "vnet-storage-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = azurerm_resource_group.example.tags
}

# Subnet for private endpoints
resource "azurerm_subnet" "private_endpoint" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  private_endpoint_network_policies_enabled = false
}

# Subnet for applications (to demonstrate network access rules)
resource "azurerm_subnet" "application" {
  name                 = "snet-applications"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  service_endpoints = ["Microsoft.Storage"]
}

# Key Vault for customer-managed keys (simplified for example)
resource "azurerm_key_vault" "example" {
  name                = "kv-storage-example-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled = true

  tags = azurerm_resource_group.example.tags
}

# User Assigned Identity for storage account
resource "azurerm_user_assigned_identity" "storage" {
  name                = "id-storage-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = azurerm_resource_group.example.tags
}

# Key Vault access policy for the identity
resource "azurerm_key_vault_access_policy" "storage_identity" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.storage.principal_id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ]
}

# Key Vault access policy for current user (for key creation)
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Get",
    "Delete",
    "List",
    "Update",
    "Import",
    "Backup",
    "Restore",
    "Recover"
  ]
}

# Customer-managed key
resource "azurerm_key_vault_key" "storage" {
  name         = "storage-encryption-key"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_key_vault_access_policy.current_user]

  tags = azurerm_resource_group.example.tags
}

# Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-storage-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 90

  tags = azurerm_resource_group.example.tags
}

# Private DNS Zones for private endpoints
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name

  tags = azurerm_resource_group.example.tags
}

resource "azurerm_private_dns_zone" "file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name

  tags = azurerm_resource_group.example.tags
}

# Link DNS zones to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "blob-dns-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.example.id

  tags = azurerm_resource_group.example.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "file" {
  name                  = "file-dns-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.file.name
  virtual_network_id    = azurerm_virtual_network.example.id

  tags = azurerm_resource_group.example.tags
}

# Random suffix for unique names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Advanced Enterprise Storage Account Configuration
module "enterprise_storage_account" {
  source = "../../"

  # Required variables
  name                = "enterprisestorage"
  resource_group_name = azurerm_resource_group.example.name
  environment         = "prod"

  # Premium tier with zone-redundant storage for high availability
  account_tier     = "Standard" # Note: Premium tier has limitations with some features
  replication_type = "ZRS"      # Zone-redundant for high availability
  account_kind     = "StorageV2"
  access_tier      = "Hot"

  # Enhanced security configuration
  enable_https_traffic_only        = true
  min_tls_version                  = "TLS1_2"
  allow_public_access              = false
  enable_infrastructure_encryption = true
  enable_shared_access_key         = false # Disable for enhanced security
  enable_public_network_access     = false # Private access only

  # Network security configuration
  enable_network_rules   = true
  network_default_action = "Deny"
  network_bypass         = ["AzureServices", "Logging", "Metrics"]
  allowed_ip_ranges      = ["203.0.113.0/24"] # Replace with your allowed IP ranges
  allowed_subnet_ids     = [azurerm_subnet.application.id]

  # Private endpoints configuration
  enable_private_endpoints           = true
  private_endpoint_subnet_id         = azurerm_subnet.private_endpoint.id
  private_endpoint_subresource_names = ["blob", "file"]
  private_dns_zone_blob_id           = azurerm_private_dns_zone.blob.id
  private_dns_zone_file_id           = azurerm_private_dns_zone.file.id

  # Advanced blob properties
  enable_blob_properties          = true
  blob_versioning_enabled         = true
  blob_change_feed_enabled        = true
  blob_change_feed_retention_days = 30
  blob_last_access_time_enabled   = true
  blob_delete_retention_days      = 30
  blob_restore_days               = 7
  container_delete_retention_days = 30

  # Customer-managed encryption
  customer_managed_key_vault_key_id              = azurerm_key_vault_key.storage.id
  customer_managed_key_user_assigned_identity_id = azurerm_user_assigned_identity.storage.id

  # Managed identity
  identity_type = "UserAssigned"
  identity_ids  = [azurerm_user_assigned_identity.storage.id]

  # Queue properties for enterprise messaging
  enable_queue_properties      = true
  enable_queue_logging         = true
  queue_logging_delete         = true
  queue_logging_read           = true
  queue_logging_write          = true
  queue_logging_retention_days = 30
  enable_queue_metrics         = true
  queue_metrics_include_apis   = true
  queue_metrics_retention_days = 30

  # File share properties for enterprise file storage
  enable_share_properties  = true
  share_retention_days     = 30
  enable_smb_settings      = true
  smb_versions             = ["SMB3.0", "SMB3.1.1"] # Secure versions only
  smb_authentication_types = ["Kerberos"]           # Enhanced authentication

  # Lifecycle management for cost optimization
  enable_lifecycle_management = true
  lifecycle_rules = [
    {
      name    = "production_lifecycle"
      enabled = true
      filters = {
        prefix_match = ["production/"]
        blob_types   = ["blockBlob"]
      }
      actions = {
        base_blob = {
          tier_to_cool_after_days    = 30
          tier_to_archive_after_days = 90
          delete_after_days          = 2555 # 7 years retention
        }
        snapshot = {
          tier_to_cool_after_days    = 7
          tier_to_archive_after_days = 30
          delete_after_days          = 90
        }
        version = {
          tier_to_cool_after_days    = 7
          tier_to_archive_after_days = 30
          delete_after_days          = 90
        }
      }
    },
    {
      name    = "logs_lifecycle"
      enabled = true
      filters = {
        prefix_match = ["logs/"]
        blob_types   = ["blockBlob"]
      }
      actions = {
        base_blob = {
          tier_to_cool_after_days    = 7
          tier_to_archive_after_days = 30
          delete_after_days          = 365
        }
      }
    }
  ]

  # Enterprise storage containers
  containers = [
    {
      name        = "production-data"
      access_type = "private"
      metadata = {
        environment = "production"
        purpose     = "application-data"
        retention   = "7-years"
        encryption  = "customer-managed"
      }
    },
    {
      name        = "logs"
      access_type = "private"
      metadata = {
        environment = "production"
        purpose     = "application-logs"
        retention   = "1-year"
      }
    },
    {
      name        = "backups"
      access_type = "private"
      metadata = {
        environment = "production"
        purpose     = "backup-storage"
        retention   = "7-years"
      }
    },
    {
      name        = "analytics"
      access_type = "private"
      metadata = {
        environment = "production"
        purpose     = "analytics-data"
        retention   = "2-years"
      }
    }
  ]

  # Enterprise file shares
  file_shares = [
    {
      name        = "enterprise-shared-files"
      quota_gb    = 2048
      access_tier = "Premium"
      protocol    = "SMB"
      metadata = {
        purpose     = "enterprise-file-storage"
        environment = "production"
        encryption  = "customer-managed"
      }
      acl = [
        {
          id = "enterprise-access"
          access_policy = [
            {
              permissions = "rwdl"
              start       = "2025-01-01T00:00:00.0000000Z"
              expiry      = "2025-12-31T23:59:59.0000000Z"
            }
          ]
        }
      ]
    },
    {
      name        = "backup-files"
      quota_gb    = 5120
      access_tier = "Cool"
      protocol    = "SMB"
      metadata = {
        purpose     = "backup-file-storage"
        environment = "production"
      }
    }
  ]

  # Enterprise queues for messaging
  queues = [
    {
      name = "high-priority-processing"
      metadata = {
        purpose     = "critical-message-processing"
        environment = "production"
        priority    = "high"
      }
    },
    {
      name = "batch-processing"
      metadata = {
        purpose     = "batch-job-processing"
        environment = "production"
        priority    = "normal"
      }
    },
    {
      name = "audit-events"
      metadata = {
        purpose     = "audit-event-processing"
        environment = "production"
        compliance  = "required"
      }
    }
  ]

  # Enterprise tables for NoSQL data
  tables = [
    {
      name = "UserProfiles"
      acl = [
        {
          id = "read-access"
          access_policy = [
            {
              permissions = "r"
              start       = "2025-01-01T00:00:00.0000000Z"
              expiry      = "2025-12-31T23:59:59.0000000Z"
            }
          ]
        }
      ]
    },
    {
      name = "AuditLogs"
    },
    {
      name = "ConfigurationData"
    }
  ]

  # Naming convention
  use_naming_convention = true
  location_short        = "eus"

  # Enterprise tagging strategy
  common_tags = {
    Environment     = "prod"
    Project         = "zrr-terraform-modules"
    Owner           = "platform-team"
    CostCenter      = "engineering"
    Criticality     = "high"
    DataClass       = "confidential"
    Compliance      = "required"
    BackupRequired  = "yes"
    MonitoringLevel = "enhanced"
  }

  storage_account_tags = {
    Purpose        = "enterprise-storage"
    Tier           = "production"
    EncryptionType = "customer-managed"
    AccessLevel    = "private-only"
    DataRetention  = "7-years"
  }

  depends_on = [
    azurerm_key_vault_access_policy.storage_identity,
    azurerm_private_dns_zone_virtual_network_link.blob,
    azurerm_private_dns_zone_virtual_network_link.file
  ]
}

# Diagnostic settings for comprehensive monitoring
resource "azurerm_monitor_diagnostic_setting" "storage_account" {
  name                       = "storage-diagnostics"
  target_resource_id         = module.enterprise_storage_account.storage_account_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

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

# Output comprehensive information
output "storage_account_name" {
  description = "The name of the created enterprise storage account"
  value       = module.enterprise_storage_account.storage_account_name
}

output "storage_account_id" {
  description = "The ID of the created enterprise storage account"
  value       = module.enterprise_storage_account.storage_account_id
}

output "private_endpoints" {
  description = "Private endpoint details"
  value = {
    blob = module.enterprise_storage_account.private_endpoint_blob
    file = module.enterprise_storage_account.private_endpoint_file
  }
}

output "identity" {
  description = "Managed identity details"
  value       = module.enterprise_storage_account.identity
}

output "containers" {
  description = "Created enterprise storage containers"
  value       = module.enterprise_storage_account.containers
}

output "file_shares" {
  description = "Created enterprise file shares"
  value       = module.enterprise_storage_account.file_shares
}

output "queues" {
  description = "Created enterprise storage queues"
  value       = module.enterprise_storage_account.queues
}

output "tables" {
  description = "Created enterprise storage tables"
  value       = module.enterprise_storage_account.tables
}

output "network_rules" {
  description = "Network rules configuration"
  value       = module.enterprise_storage_account.network_rules
}

output "lifecycle_management_policy_id" {
  description = "Lifecycle management policy ID"
  value       = module.enterprise_storage_account.lifecycle_management_policy_id
}

output "key_vault_key_id" {
  description = "Customer-managed key ID"
  value       = azurerm_key_vault_key.storage.id
}

output "user_assigned_identity_id" {
  description = "User assigned identity ID"
  value       = azurerm_user_assigned_identity.storage.id
}