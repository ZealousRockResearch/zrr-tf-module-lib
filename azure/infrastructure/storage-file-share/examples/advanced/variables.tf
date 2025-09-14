variable "file_share_name" {
  description = "Name of the file share to create"
  type        = string
  default     = "advanced-share"
}

variable "storage_account_name" {
  description = "Name of the existing storage account"
  type        = string
  # This should be set when running the example
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  # This should be set when running the example
}

variable "location" {
  description = "Azure region for the file share"
  type        = string
  default     = "East US"
}

variable "quota_gb" {
  description = "Quota for the file share in GB"
  type        = number
  default     = 1000
}

variable "access_tier" {
  description = "Access tier for the file share"
  type        = string
  default     = "Premium"
}

variable "enabled_protocol" {
  description = "Protocol enabled for the file share"
  type        = string
  default     = "SMB"
}

variable "metadata" {
  description = "Metadata for the file share"
  type        = map(string)
  default = {
    department = "engineering"
    purpose    = "production"
    compliance = "required"
  }
}

variable "directories" {
  description = "List of directories to create in the file share"
  type = list(object({
    name     = string
    metadata = optional(map(string), {})
  }))
  default = [
    {
      name = "documents"
      metadata = {
        purpose = "document-storage"
        access  = "read-write"
      }
    },
    {
      name = "backups"
      metadata = {
        purpose = "backup-storage"
        access  = "write-only"
      }
    },
    {
      name = "shared"
      metadata = {
        purpose = "shared-storage"
        access  = "read-write"
      }
    },
    {
      name = "archive"
      metadata = {
        purpose = "archive-storage"
        access  = "read-only"
      }
    }
  ]
}

variable "access_policies" {
  description = "Access policies for the file share"
  type = list(object({
    id = string
    access_policies = list(object({
      permissions = string
      start       = string
      expiry      = string
    }))
  }))
  default = [
    {
      id = "example-policy-1"
      access_policies = [
        {
          permissions = "rwdl"
          start       = "2024-01-01T00:00:00Z"
          expiry      = "2025-12-31T23:59:59Z"
        }
      ]
    }
  ]
}

variable "enable_backup" {
  description = "Enable backup for the file share"
  type        = bool
  default     = true
}

variable "backup_vault_name" {
  description = "Name of the backup vault"
  type        = string
  default     = "advanced-backup-vault"
}

variable "backup_vault_sku" {
  description = "SKU for the backup vault"
  type        = string
  default     = "Standard"
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
  description = "Advanced backup policy configuration"
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
    time      = "02:00"
    retention_daily = {
      count = 30
    }
    retention_weekly = {
      count    = 12
      weekdays = ["Sunday"]
    }
    retention_monthly = {
      count    = 12
      weekdays = ["Sunday"]
      weeks    = ["First"]
    }
    retention_yearly = {
      count    = 7
      weekdays = ["Sunday"]
      weeks    = ["First"]
      months   = ["January"]
    }
  }
}

variable "enable_monitoring" {
  description = "Enable monitoring and alerting for the file share"
  type        = bool
  default     = true
}

variable "alert_email_addresses" {
  description = "List of email addresses to receive alerts"
  type        = list(string)
  default     = ["admin@company.com", "devops@company.com"]
}

variable "quota_alert_threshold_percentage" {
  description = "Threshold percentage for quota usage alert"
  type        = number
  default     = 85
}

variable "quota_alert_severity" {
  description = "Severity level for quota alerts"
  type        = number
  default     = 1
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for the storage account"
  type        = bool
  default     = true
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint"
  type        = string
  default     = null
  # This should be set when running the example if private endpoint is enabled
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for the private endpoint"
  type        = string
  default     = null
  # This should be set when running the example if private endpoint is enabled
}

variable "common_tags" {
  description = "Common tags for the example"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "enterprise-storage"
    Owner       = "platform-team"
    CostCenter  = "engineering"
  }
}

variable "file_share_tags" {
  description = "Additional tags for the file share"
  type        = map(string)
  default = {
    Purpose       = "production"
    BackupEnabled = "true"
    Compliance    = "required"
    AccessTier    = "premium"
    Protocol      = "smb"
  }
}