# azure-state-az-tf-init module variables
# Description: Variable definitions for Azure Terraform state initialization module

# Required variables
variable "project_name" {
  description = "Name of the project (used in resource naming)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,12}$", var.project_name))
    error_message = "Project name must be 3-12 characters, lowercase letters and numbers only."
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

variable "location" {
  description = "Azure region for the Terraform state infrastructure"
  type        = string
  default     = "East US"

  validation {
    condition = contains([
      "East US", "East US 2", "West US", "West US 2", "West US 3",
      "Central US", "North Central US", "South Central US", "West Central US",
      "Canada Central", "Canada East",
      "Brazil South",
      "North Europe", "West Europe", "UK South", "UK West",
      "France Central", "Germany West Central", "Switzerland North",
      "Norway East", "Sweden Central",
      "Australia East", "Australia Southeast",
      "Japan East", "Japan West",
      "Korea Central", "Korea South",
      "Southeast Asia", "East Asia",
      "Central India", "South India", "West India"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "location_short" {
  description = "Short location code for naming convention (e.g., 'eus' for East US)"
  type        = string
  default     = "eus"

  validation {
    condition     = can(regex("^[a-z]{2,4}$", var.location_short))
    error_message = "Location short must be 2-4 lowercase letters."
  }
}

# Naming convention
variable "use_naming_convention" {
  description = "Use ZRR standardized naming convention for resources"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Custom resource group name (only used if use_naming_convention is false)"
  type        = string
  default     = ""
}

variable "storage_account_name" {
  description = "Custom storage account name (only used if use_naming_convention is false)"
  type        = string
  default     = ""

  validation {
    condition     = var.storage_account_name == "" || can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 characters, lowercase letters and numbers only."
  }
}

variable "key_vault_name" {
  description = "Custom key vault name (only used if use_naming_convention is false)"
  type        = string
  default     = ""

  validation {
    condition     = var.key_vault_name == "" || can(regex("^[a-zA-Z0-9-]{3,24}$", var.key_vault_name))
    error_message = "Key vault name must be 3-24 characters, letters, numbers, and hyphens only."
  }
}

variable "container_name" {
  description = "Name of the container for storing Terraform state files"
  type        = string
  default     = "tfstate"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,63}$", var.container_name))
    error_message = "Container name must be 3-63 characters, lowercase letters, numbers, and hyphens only."
  }
}

# Storage Account configuration
variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage account tier must be either Standard or Premium."
  }
}

variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_replication_type)
    error_message = "Replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "enable_shared_access_key" {
  description = "Enable shared access keys for storage account (disable for enhanced security)"
  type        = bool
  default     = true
}

variable "enable_public_network_access" {
  description = "Enable public network access to storage account"
  type        = bool
  default     = true
}

variable "enable_blob_versioning" {
  description = "Enable blob versioning for state file protection"
  type        = bool
  default     = true
}

variable "blob_soft_delete_retention_days" {
  description = "Soft delete retention days for blobs"
  type        = number
  default     = 30

  validation {
    condition     = var.blob_soft_delete_retention_days >= 1 && var.blob_soft_delete_retention_days <= 365
    error_message = "Blob soft delete retention days must be between 1 and 365."
  }
}

variable "container_soft_delete_retention_days" {
  description = "Soft delete retention days for containers"
  type        = number
  default     = 30

  validation {
    condition     = var.container_soft_delete_retention_days >= 1 && var.container_soft_delete_retention_days <= 365
    error_message = "Container soft delete retention days must be between 1 and 365."
  }
}

# Network security
variable "enable_network_restrictions" {
  description = "Enable network access restrictions for storage account"
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

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for storage account access"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "List of allowed subnet IDs for storage account access"
  type        = list(string)
  default     = []
}

# State locking
variable "enable_state_locking" {
  description = "Enable Terraform state locking using Azure Storage"
  type        = bool
  default     = true
}

# Key Vault configuration
variable "enable_key_vault" {
  description = "Create Key Vault for state encryption and secrets management"
  type        = bool
  default     = false
}

variable "key_vault_sku" {
  description = "Key Vault SKU"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "Key Vault SKU must be either standard or premium."
  }
}

variable "enable_key_vault_rbac" {
  description = "Enable RBAC authorization for Key Vault (recommended over access policies)"
  type        = bool
  default     = true
}

variable "enable_key_vault_purge_protection" {
  description = "Enable purge protection for Key Vault"
  type        = bool
  default     = false
}

variable "key_vault_soft_delete_retention_days" {
  description = "Soft delete retention days for Key Vault"
  type        = number
  default     = 90

  validation {
    condition     = var.key_vault_soft_delete_retention_days >= 7 && var.key_vault_soft_delete_retention_days <= 90
    error_message = "Key Vault soft delete retention days must be between 7 and 90."
  }
}

variable "enable_key_vault_public_access" {
  description = "Enable public network access to Key Vault"
  type        = bool
  default     = true
}

variable "enable_key_vault_network_restrictions" {
  description = "Enable network access restrictions for Key Vault"
  type        = bool
  default     = false
}

variable "key_vault_network_default_action" {
  description = "Default action for Key Vault network rules"
  type        = string
  default     = "Allow"

  validation {
    condition     = contains(["Allow", "Deny"], var.key_vault_network_default_action)
    error_message = "Key Vault network default action must be either Allow or Deny."
  }
}

variable "key_vault_allowed_ip_ranges" {
  description = "List of allowed IP ranges for Key Vault access"
  type        = list(string)
  default     = []
}

variable "key_vault_allowed_subnet_ids" {
  description = "List of allowed subnet IDs for Key Vault access"
  type        = list(string)
  default     = []
}

# Access policies (only used if RBAC is disabled)
variable "additional_access_policies" {
  description = "Additional access policies for Key Vault"
  type = list(object({
    tenant_id               = string
    object_id               = string
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    certificate_permissions = optional(list(string), [])
  }))
  default = []
}

# RBAC assignments
variable "storage_contributors" {
  description = "List of principal IDs to grant Storage Blob Data Contributor role"
  type        = list(string)
  default     = []
}

variable "storage_readers" {
  description = "List of principal IDs to grant Storage Blob Data Reader role"
  type        = list(string)
  default     = []
}

variable "key_vault_administrators" {
  description = "List of principal IDs to grant Key Vault Administrator role"
  type        = list(string)
  default     = []
}

variable "key_vault_users" {
  description = "List of principal IDs to grant Key Vault Secrets User role"
  type        = list(string)
  default     = []
}

# Monitoring and diagnostics
variable "enable_monitoring" {
  description = "Enable monitoring and diagnostics for state infrastructure"
  type        = bool
  default     = false
}

variable "log_analytics_sku" {
  description = "Log Analytics workspace SKU"
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = contains(["Free", "Standalone", "PerNode", "PerGB2018"], var.log_analytics_sku)
    error_message = "Log Analytics SKU must be one of: Free, Standalone, PerNode, PerGB2018."
  }
}

variable "log_analytics_retention_days" {
  description = "Log Analytics workspace retention in days"
  type        = number
  default     = 30

  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "Log Analytics retention must be between 30 and 730 days."
  }
}

# Common tags (required for all ZRR modules)
variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "zrr"
    ManagedBy   = "Terraform"
    Purpose     = "terraform-state"
  }

  validation {
    condition = alltrue([
      can(var.common_tags["Environment"]),
      can(var.common_tags["Project"])
    ])
    error_message = "Common tags must include 'Environment' and 'Project' keys."
  }
}

# Resource-specific tags
variable "az_tf_init_tags" {
  description = "Additional tags specific to the Terraform state infrastructure"
  type        = map(string)
  default     = {}
}