# Required variables
variable "name" {
  description = "Name of the file share"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.name))
    error_message = "File share name must be 3-63 characters long, start and end with alphanumeric characters, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "storage_account_name" {
  description = "Name of the storage account where the file share will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 characters long and contain only lowercase letters and numbers."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"

  validation {
    condition = contains([
      "East US", "East US 2", "Central US", "North Central US", "South Central US", "West Central US", "West US", "West US 2", "West US 3",
      "Canada Central", "Canada East", "Brazil South", "North Europe", "West Europe", "France Central", "Germany West Central",
      "Norway East", "Sweden Central", "Switzerland North", "UK South", "UK West", "Australia East", "Australia Southeast",
      "Central India", "South India", "West India", "Japan East", "Japan West", "Korea Central", "Southeast Asia", "East Asia"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

# File Share Configuration
variable "quota_gb" {
  description = "Maximum size of the file share in GB"
  type        = number
  default     = 100

  validation {
    condition     = var.quota_gb >= 1 && var.quota_gb <= 102400
    error_message = "Quota must be between 1 GB and 102400 GB (100 TB)."
  }
}

variable "access_tier" {
  description = "Access tier for the file share"
  type        = string
  default     = "Hot"

  validation {
    condition     = contains(["Hot", "Cool", "TransactionOptimized", "Premium"], var.access_tier)
    error_message = "Access tier must be one of: Hot, Cool, TransactionOptimized, Premium."
  }
}

variable "enabled_protocol" {
  description = "Protocol enabled for the file share"
  type        = string
  default     = "SMB"

  validation {
    condition     = contains(["SMB", "NFS"], var.enabled_protocol)
    error_message = "Enabled protocol must be either SMB or NFS."
  }
}

variable "metadata" {
  description = "Metadata for the file share"
  type        = map(string)
  default     = {}
}

# Access Control
variable "access_policies" {
  description = "List of access policies for the file share"
  type = list(object({
    id = string
    access_policies = list(object({
      permissions = string
      start       = string
      expiry      = string
    }))
  }))
  default = []
}

# Directories
variable "directories" {
  description = "List of directories to create in the file share"
  type = list(object({
    name     = string
    metadata = optional(map(string), {})
  }))
  default = []
}

# Backup Configuration
variable "enable_backup" {
  description = "Enable backup for the file share"
  type        = bool
  default     = true
}

variable "backup_vault_name" {
  description = "Name of the backup vault (if null, will be auto-generated)"
  type        = string
  default     = null
}

variable "backup_vault_sku" {
  description = "SKU for the backup vault"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "RS0"], var.backup_vault_sku)
    error_message = "Backup vault SKU must be either Standard or RS0."
  }
}

variable "backup_soft_delete_enabled" {
  description = "Enable soft delete for backup vault"
  type        = bool
  default     = true
}

variable "backup_public_access_enabled" {
  description = "Enable public network access to backup vault"
  type        = bool
  default     = false
}

variable "backup_policy" {
  description = "Backup policy configuration"
  type = object({
    frequency = string
    time      = string
    retention_daily = optional(object({
      count = number
    }))
    retention_weekly = optional(object({
      count    = number
      weekdays = list(string)
    }))
    retention_monthly = optional(object({
      count    = number
      weekdays = list(string)
      weeks    = list(string)
    }))
    retention_yearly = optional(object({
      count    = number
      weekdays = list(string)
      weeks    = list(string)
      months   = list(string)
    }))
  })
  default = {
    frequency = "Daily"
    time      = "23:00"
    retention_daily = {
      count = 30
    }
  }

  validation {
    condition     = contains(["Daily"], var.backup_policy.frequency)
    error_message = "Backup frequency must be Daily."
  }

  validation {
    condition     = can(regex("^([0-1][0-9]|2[0-3]):[0-5][0-9]$", var.backup_policy.time))
    error_message = "Backup time must be in HH:MM format (24-hour)."
  }
}

# Monitoring
variable "enable_monitoring" {
  description = "Enable monitoring and alerting for the file share"
  type        = bool
  default     = false
}

variable "alert_email_addresses" {
  description = "List of email addresses to receive alerts"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for email in var.alert_email_addresses : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))])
    error_message = "All email addresses must be valid."
  }
}

variable "quota_alert_threshold_percentage" {
  description = "Threshold percentage for quota usage alert (0 to disable)"
  type        = number
  default     = 80

  validation {
    condition     = var.quota_alert_threshold_percentage >= 0 && var.quota_alert_threshold_percentage <= 100
    error_message = "Quota alert threshold percentage must be between 0 and 100."
  }
}

variable "quota_alert_severity" {
  description = "Severity level for quota alerts"
  type        = number
  default     = 2

  validation {
    condition     = var.quota_alert_severity >= 0 && var.quota_alert_severity <= 4
    error_message = "Alert severity must be between 0 (Critical) and 4 (Verbose)."
  }
}

# Private Endpoint
variable "enable_private_endpoint" {
  description = "Enable private endpoint for the storage account"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for the private endpoint"
  type        = string
  default     = null
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

# File share specific tags
variable "file_share_tags" {
  description = "Additional tags specific to the file share"
  type        = map(string)
  default     = {}
}