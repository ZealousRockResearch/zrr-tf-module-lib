# azure-shared-storage-account module variables
# Description: Variable definitions for Azure Storage Account module with enterprise features

# Required variables
variable "name" {
  description = "Name of the storage account. If use_naming_convention is true, this will be part of the generated name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be between 3 and 24 characters, lowercase letters and numbers only."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group where the storage account will be created"
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name cannot be empty."
  }
}

variable "environment" {
  description = "Environment name (dev, test, staging, prod, dr)"
  type        = string

  validation {
    condition     = contains(["dev", "test", "staging", "prod", "dr"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod, dr."
  }
}

# Storage account configuration
variable "account_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be either Standard or Premium."
  }
}

variable "replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.replication_type)
    error_message = "Replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "account_kind" {
  description = "Storage account kind"
  type        = string
  default     = "StorageV2"

  validation {
    condition     = contains(["Storage", "StorageV2", "BlobStorage", "FileStorage", "BlockBlobStorage"], var.account_kind)
    error_message = "Account kind must be one of: Storage, StorageV2, BlobStorage, FileStorage, BlockBlobStorage."
  }
}

variable "access_tier" {
  description = "Access tier for BlobStorage, StorageV2 and FileStorage accounts"
  type        = string
  default     = "Hot"

  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "Access tier must be either Hot or Cool."
  }
}

# Security settings
variable "enable_https_traffic_only" {
  description = "Forces HTTPS traffic only"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "Minimum TLS version for requests"
  type        = string
  default     = "TLS1_2"

  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "TLS version must be one of: TLS1_0, TLS1_1, TLS1_2."
  }
}

variable "allow_public_access" {
  description = "Allow public access to blobs and containers"
  type        = bool
  default     = false
}

variable "enable_shared_access_key" {
  description = "Enable shared access key authentication"
  type        = bool
  default     = true
}

variable "enable_public_network_access" {
  description = "Enable public network access to the storage account"
  type        = bool
  default     = true
}

variable "enable_infrastructure_encryption" {
  description = "Enable infrastructure encryption for enhanced security"
  type        = bool
  default     = false
}

# Network rules
variable "enable_network_rules" {
  description = "Enable network access rules for the storage account"
  type        = bool
  default     = false
}

variable "configure_network_rules_separately" {
  description = "Configure network rules using separate resource instead of inline"
  type        = bool
  default     = false
}

variable "network_default_action" {
  description = "Default action for network rules"
  type        = string
  default     = "Allow"

  validation {
    condition     = contains(["Allow", "Deny"], var.network_default_action)
    error_message = "Network default action must be either Allow or Deny."
  }
}

variable "network_bypass" {
  description = "Bypass network rules for Azure services"
  type        = set(string)
  default     = ["AzureServices"]

  validation {
    condition = alltrue([
      for bypass in var.network_bypass : contains(["Logging", "Metrics", "AzureServices", "None"], bypass)
    ])
    error_message = "Network bypass values must be from: Logging, Metrics, AzureServices, None."
  }
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for network access"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "List of allowed subnet IDs for network access"
  type        = list(string)
  default     = []
}

variable "private_link_access_rules" {
  description = "Private link access rules configuration"
  type = list(object({
    endpoint_resource_id = string
    endpoint_tenant_id   = optional(string)
  }))
  default = []
}

# Private endpoints
variable "enable_private_endpoints" {
  description = "Enable private endpoints for the storage account"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoints"
  type        = string
  default     = ""
}

variable "private_endpoint_subresource_names" {
  description = "List of subresource names for private endpoints"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for name in var.private_endpoint_subresource_names :
      contains(["blob", "file", "queue", "table", "web", "dfs"], name)
    ])
    error_message = "Subresource names must be from: blob, file, queue, table, web, dfs."
  }
}

variable "private_dns_zone_blob_id" {
  description = "Private DNS zone ID for blob private endpoint"
  type        = string
  default     = ""
}

variable "private_dns_zone_file_id" {
  description = "Private DNS zone ID for file private endpoint"
  type        = string
  default     = ""
}

# Blob properties
variable "enable_blob_properties" {
  description = "Enable blob properties configuration"
  type        = bool
  default     = true
}

variable "blob_versioning_enabled" {
  description = "Enable blob versioning"
  type        = bool
  default     = false
}

variable "blob_change_feed_enabled" {
  description = "Enable blob change feed"
  type        = bool
  default     = false
}

variable "blob_change_feed_retention_days" {
  description = "Retention days for blob change feed"
  type        = number
  default     = 7

  validation {
    condition     = var.blob_change_feed_retention_days >= 1 && var.blob_change_feed_retention_days <= 146000
    error_message = "Change feed retention days must be between 1 and 146000."
  }
}

variable "blob_default_service_version" {
  description = "Default service version for blob requests"
  type        = string
  default     = "2020-06-12"
}

variable "blob_last_access_time_enabled" {
  description = "Enable last access time tracking for blobs"
  type        = bool
  default     = false
}

variable "blob_cors_rules" {
  description = "CORS rules for blob service"
  type = list(object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  }))
  default = []
}

variable "blob_delete_retention_days" {
  description = "Retention days for deleted blobs"
  type        = number
  default     = 7

  validation {
    condition     = var.blob_delete_retention_days >= 1 && var.blob_delete_retention_days <= 365
    error_message = "Blob delete retention days must be between 1 and 365."
  }
}

variable "blob_restore_days" {
  description = "Point-in-time restore retention days"
  type        = number
  default     = 0

  validation {
    condition     = var.blob_restore_days >= 0 && var.blob_restore_days <= 365
    error_message = "Blob restore days must be between 0 and 365."
  }
}

variable "container_delete_retention_days" {
  description = "Retention days for deleted containers"
  type        = number
  default     = 7

  validation {
    condition     = var.container_delete_retention_days >= 1 && var.container_delete_retention_days <= 365
    error_message = "Container delete retention days must be between 1 and 365."
  }
}

# Queue properties
variable "enable_queue_properties" {
  description = "Enable queue properties configuration"
  type        = bool
  default     = false
}

variable "queue_cors_rules" {
  description = "CORS rules for queue service"
  type = list(object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  }))
  default = []
}

variable "enable_queue_logging" {
  description = "Enable queue logging"
  type        = bool
  default     = false
}

variable "queue_logging_delete" {
  description = "Log delete operations"
  type        = bool
  default     = false
}

variable "queue_logging_read" {
  description = "Log read operations"
  type        = bool
  default     = false
}

variable "queue_logging_write" {
  description = "Log write operations"
  type        = bool
  default     = false
}

variable "queue_logging_version" {
  description = "Queue logging version"
  type        = string
  default     = "1.0"
}

variable "queue_logging_retention_days" {
  description = "Queue logging retention days"
  type        = number
  default     = 7
}

variable "enable_queue_metrics" {
  description = "Enable queue metrics"
  type        = bool
  default     = false
}

variable "queue_metrics_version" {
  description = "Queue metrics version"
  type        = string
  default     = "1.0"
}

variable "queue_metrics_include_apis" {
  description = "Include API metrics in queue metrics"
  type        = bool
  default     = false
}

variable "queue_metrics_retention_days" {
  description = "Queue metrics retention days"
  type        = number
  default     = 7
}

# Share properties
variable "enable_share_properties" {
  description = "Enable file share properties configuration"
  type        = bool
  default     = false
}

variable "share_cors_rules" {
  description = "CORS rules for file share service"
  type = list(object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  }))
  default = []
}

variable "share_retention_days" {
  description = "Retention days for file shares"
  type        = number
  default     = 0

  validation {
    condition     = var.share_retention_days >= 0 && var.share_retention_days <= 365
    error_message = "Share retention days must be between 0 and 365."
  }
}

variable "enable_smb_settings" {
  description = "Enable SMB settings for file shares"
  type        = bool
  default     = false
}

variable "smb_versions" {
  description = "Supported SMB versions"
  type        = list(string)
  default     = ["SMB2.1", "SMB3.0", "SMB3.1.1"]
}

variable "smb_authentication_types" {
  description = "SMB authentication types"
  type        = list(string)
  default     = ["NTLMv2", "Kerberos"]
}

variable "smb_kerberos_ticket_encryption" {
  description = "Kerberos ticket encryption type"
  type        = list(string)
  default     = ["RC4-HMAC", "AES-256"]
}

variable "smb_channel_encryption" {
  description = "SMB channel encryption type"
  type        = list(string)
  default     = ["AES-128-CCM", "AES-128-GCM", "AES-256-GCM"]
}

# Static website
variable "enable_static_website" {
  description = "Enable static website hosting"
  type        = bool
  default     = false
}

variable "static_website_index_document" {
  description = "Index document for static website"
  type        = string
  default     = "index.html"
}

variable "static_website_error_document" {
  description = "Error document for static website"
  type        = string
  default     = "error.html"
}

# Customer managed key
variable "customer_managed_key_vault_key_id" {
  description = "Key Vault key ID for customer-managed encryption"
  type        = string
  default     = ""
}

variable "customer_managed_key_user_assigned_identity_id" {
  description = "User assigned identity ID for customer-managed key access"
  type        = string
  default     = ""
}

# Identity
variable "identity_type" {
  description = "Type of managed identity"
  type        = string
  default     = ""

  validation {
    condition     = var.identity_type == "" || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Identity type must be one of: SystemAssigned, UserAssigned, SystemAssigned UserAssigned."
  }
}

variable "identity_ids" {
  description = "List of user assigned identity IDs"
  type        = list(string)
  default     = []
}

# Lifecycle management
variable "enable_lifecycle_management" {
  description = "Enable lifecycle management policies"
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "Lifecycle management rules"
  type = list(object({
    name    = string
    enabled = optional(bool, true)
    filters = object({
      prefix_match = optional(list(string), [])
      blob_types   = optional(list(string), ["blockBlob"])
      match_blob_index_tag = optional(list(object({
        name      = string
        operation = optional(string, "==")
        value     = string
      })), [])
    })
    actions = object({
      base_blob = optional(object({
        tier_to_cool_after_days                = optional(number)
        tier_to_archive_after_days             = optional(number)
        delete_after_days                      = optional(number)
        tier_to_cool_after_last_access_days    = optional(number)
        tier_to_archive_after_last_access_days = optional(number)
        delete_after_last_access_days          = optional(number)
      }))
      snapshot = optional(object({
        tier_to_cool_after_days    = optional(number)
        tier_to_archive_after_days = optional(number)
        delete_after_days          = optional(number)
      }))
      version = optional(object({
        tier_to_cool_after_days    = optional(number)
        tier_to_archive_after_days = optional(number)
        delete_after_days          = optional(number)
      }))
    })
  }))
  default = []
}

# Storage containers, file shares, queues, and tables
variable "containers" {
  description = "List of storage containers to create"
  type = list(object({
    name        = string
    access_type = optional(string, "private")
    metadata    = optional(map(string), {})
  }))
  default = []

  validation {
    condition = alltrue([
      for container in var.containers :
      contains(["blob", "container", "private"], container.access_type)
    ])
    error_message = "Container access type must be one of: blob, container, private."
  }
}

variable "file_shares" {
  description = "List of file shares to create"
  type = list(object({
    name        = string
    quota_gb    = optional(number, 5120)
    protocol    = optional(string, "SMB")
    access_tier = optional(string, "TransactionOptimized")
    metadata    = optional(map(string), {})
    acl = optional(list(object({
      id = string
      access_policy = optional(list(object({
        permissions = string
        start       = optional(string)
        expiry      = optional(string)
      })), [])
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for share in var.file_shares :
      contains(["SMB", "NFS"], share.protocol)
    ])
    error_message = "File share protocol must be either SMB or NFS."
  }

  validation {
    condition = alltrue([
      for share in var.file_shares :
      contains(["Cool", "Hot", "TransactionOptimized", "Premium"], share.access_tier)
    ])
    error_message = "File share access tier must be one of: Cool, Hot, TransactionOptimized, Premium."
  }
}

variable "queues" {
  description = "List of storage queues to create"
  type = list(object({
    name     = string
    metadata = optional(map(string), {})
  }))
  default = []
}

variable "tables" {
  description = "List of storage tables to create"
  type = list(object({
    name = string
    acl = optional(list(object({
      id = string
      access_policy = optional(list(object({
        permissions = string
        start       = optional(string)
        expiry      = optional(string)
      })), [])
    })), [])
  }))
  default = []
}

# Naming convention
variable "use_naming_convention" {
  description = "Use standardized naming convention for storage account"
  type        = bool
  default     = true
}

variable "location_short" {
  description = "Short location code for naming convention"
  type        = string
  default     = "eus"

  validation {
    condition     = can(regex("^[a-z]{2,4}$", var.location_short))
    error_message = "Location short must be 2-4 lowercase letters."
  }
}

# Tagging
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "zrr"
    ManagedBy   = "Terraform"
  }

  validation {
    condition = alltrue([
      can(var.common_tags["Environment"]),
      can(var.common_tags["Project"])
    ])
    error_message = "Common tags must include Environment and Project."
  }
}

variable "storage_account_tags" {
  description = "Additional tags specific to the storage account"
  type        = map(string)
  default     = {}
}