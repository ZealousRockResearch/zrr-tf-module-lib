# Required variables
variable "name" {
  description = "Name of the storage container"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.name)) && !can(regex("--", var.name))
    error_message = "Container name must be 3-63 characters long, start and end with alphanumeric characters, contain only lowercase letters, numbers, and hyphens, and cannot contain consecutive hyphens."
  }
}

# Storage Account identification (one of these is required)
variable "storage_account_id" {
  description = "Resource ID of the storage account"
  type        = string
  default     = null
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
  default     = null
}

variable "storage_account_resource_group_name" {
  description = "Resource group name of the storage account (required when using storage_account_name)"
  type        = string
  default     = null

  validation {
    condition     = (var.storage_account_name != null && var.storage_account_resource_group_name != null) || (var.storage_account_name == null && var.storage_account_resource_group_name == null) || var.storage_account_id != null
    error_message = "storage_account_resource_group_name is required when storage_account_name is provided, unless storage_account_id is specified."
  }
}

# Container configuration
variable "container_access_type" {
  description = "The access level configured for this container"
  type        = string
  default     = "private"

  validation {
    condition     = contains(["private", "blob", "container"], var.container_access_type)
    error_message = "Container access type must be one of: private, blob, container."
  }
}

# Metadata configuration
variable "metadata" {
  description = "A map of custom metadata to assign to the storage container"
  type = object({
    environment = optional(string)
    project     = optional(string)
    owner       = optional(string)
    purpose     = optional(string)
  })
  default = null
}

# Lifecycle management
variable "lifecycle_rules" {
  description = "List of lifecycle management rules for the container"
  type = list(object({
    name                       = string
    enabled                    = bool
    prefix_match               = list(string)
    blob_types                 = list(string)
    tier_to_cool_after_days    = optional(number)
    tier_to_archive_after_days = optional(number)
    delete_after_days          = optional(number)
    snapshot_delete_after_days = optional(number)
    version_delete_after_days  = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules : rule.tier_to_cool_after_days == null || rule.tier_to_cool_after_days >= 1
    ])
    error_message = "tier_to_cool_after_days must be at least 1 day when specified."
  }

  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules : rule.tier_to_archive_after_days == null || rule.tier_to_archive_after_days >= 1
    ])
    error_message = "tier_to_archive_after_days must be at least 1 day when specified."
  }

  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules : rule.delete_after_days == null || rule.delete_after_days >= 1
    ])
    error_message = "delete_after_days must be at least 1 day when specified."
  }
}

# Legal hold configuration
variable "legal_hold" {
  description = "Configuration for legal hold on the container"
  type = object({
    tags = list(string)
  })
  default = null

  validation {
    condition = var.legal_hold == null || (
      var.legal_hold != null && length(var.legal_hold.tags) > 0 && length(var.legal_hold.tags) <= 10
    )
    error_message = "Legal hold must have between 1 and 10 tags when specified."
  }
}

# Immutability policy configuration
variable "immutability_policy" {
  description = "Configuration for immutability policy on the container"
  type = object({
    period_in_days = number
    locked         = bool
  })
  default = null

  validation {
    condition = var.immutability_policy == null || (
      var.immutability_policy.period_in_days >= 1 && var.immutability_policy.period_in_days <= 146000
    )
    error_message = "Immutability period must be between 1 and 146000 days when specified."
  }
}

# Common tags (required for all modules)
variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "zrr"
    ManagedBy   = "Terraform"
  }

  validation {
    condition     = can(var.common_tags["Environment"]) && can(var.common_tags["Project"])
    error_message = "Common tags must include 'Environment' and 'Project' keys."
  }
}

# Resource-specific tags
variable "storage_container_tags" {
  description = "Additional tags specific to the storage container"
  type        = map(string)
  default     = {}
}