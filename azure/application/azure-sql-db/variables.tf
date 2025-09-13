# Required variables
variable "name" {
  description = "Name of the Azure SQL Database"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{1,128}$", var.name))
    error_message = "Database name must be 1-128 characters long and contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group containing the SQL Server"
  type        = string
}

# SQL Server configuration (either provide sql_server_id OR sql_server_name)
variable "sql_server_id" {
  description = "ID of the Azure SQL Server. If not provided, sql_server_name must be specified"
  type        = string
  default     = null
}

variable "sql_server_name" {
  description = "Name of the Azure SQL Server. Required if sql_server_id is not provided"
  type        = string
  default     = null

  validation {
    condition     = var.sql_server_id != null || var.sql_server_name != null
    error_message = "Either sql_server_id or sql_server_name must be provided."
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
variable "azure_sql_db_tags" {
  description = "Additional tags specific to the Azure SQL Database"
  type        = map(string)
  default     = {}
}

# Database performance and scaling
variable "sku_name" {
  description = "The SKU name of the database. Examples: GP_S_Gen5_1, GP_Gen5_2, HS_Gen5_4, BC_Gen5_8"
  type        = string
  default     = "GP_S_Gen5_1"

  validation {
    condition     = can(regex("^(GP_S_Gen5_[1-4]|GP_Gen5_[2-80]|HS_Gen5_[2-80]|BC_Gen5_[2-80])$", var.sku_name))
    error_message = "SKU name must be a valid Azure SQL Database SKU."
  }
}

variable "max_size_gb" {
  description = "Maximum size of the database in GB"
  type        = number
  default     = 2

  validation {
    condition     = var.max_size_gb >= 0.5 && var.max_size_gb <= 4096
    error_message = "Max size must be between 0.5 and 4096 GB."
  }
}

variable "zone_redundant" {
  description = "Whether the database is zone redundant"
  type        = bool
  default     = false
}

variable "read_scale" {
  description = "Enable read scale-out for the database"
  type        = bool
  default     = false
}

variable "auto_pause_delay_in_minutes" {
  description = "Time in minutes after which database is automatically paused (-1 to disable)"
  type        = number
  default     = -1

  validation {
    condition     = var.auto_pause_delay_in_minutes == -1 || (var.auto_pause_delay_in_minutes >= 60 && var.auto_pause_delay_in_minutes <= 10080)
    error_message = "Auto pause delay must be -1 (disabled) or between 60 and 10080 minutes."
  }
}

variable "min_capacity" {
  description = "Minimum capacity for serverless databases"
  type        = number
  default     = null

  validation {
    condition     = var.min_capacity == null || (var.min_capacity >= 0.5 && var.min_capacity <= 80)
    error_message = "Minimum capacity must be between 0.5 and 80 vCores."
  }
}

# Backup and retention settings
variable "short_term_retention_days" {
  description = "Point in time retention in days"
  type        = number
  default     = 7

  validation {
    condition     = var.short_term_retention_days >= 7 && var.short_term_retention_days <= 35
    error_message = "Short term retention must be between 7 and 35 days."
  }
}

variable "backup_interval_in_hours" {
  description = "Backup interval in hours (12 or 24)"
  type        = number
  default     = 12

  validation {
    condition     = contains([12, 24], var.backup_interval_in_hours)
    error_message = "Backup interval must be either 12 or 24 hours."
  }
}

variable "long_term_retention_policy" {
  description = "Long term retention policy configuration"
  type = object({
    weekly_retention  = optional(string, null)
    monthly_retention = optional(string, null)
    yearly_retention  = optional(string, null)
    week_of_year      = optional(number, null)
  })
  default = null
}

# Security settings
variable "enable_threat_detection" {
  description = "Enable threat detection for the database"
  type        = bool
  default     = true
}

variable "threat_detection_email_admins" {
  description = "Send threat detection alerts to subscription admins"
  type        = bool
  default     = true
}

variable "threat_detection_email_addresses" {
  description = "List of email addresses to send threat detection alerts to"
  type        = list(string)
  default     = []
}

variable "threat_detection_retention_days" {
  description = "Number of days to retain threat detection logs"
  type        = number
  default     = 30

  validation {
    condition     = var.threat_detection_retention_days >= 0 && var.threat_detection_retention_days <= 3285
    error_message = "Threat detection retention must be between 0 and 3285 days."
  }
}

variable "threat_detection_storage_account_access_key" {
  description = "Storage account access key for threat detection logs"
  type        = string
  default     = null
  sensitive   = true
}

variable "threat_detection_storage_endpoint" {
  description = "Storage endpoint for threat detection logs"
  type        = string
  default     = null
}

variable "transparent_data_encryption_enabled" {
  description = "Enable transparent data encryption"
  type        = bool
  default     = true
}

# Auditing settings
variable "enable_auditing" {
  description = "Enable database auditing"
  type        = bool
  default     = true
}

variable "auditing_storage_endpoint" {
  description = "Storage endpoint for audit logs"
  type        = string
  default     = null
}

variable "auditing_storage_account_access_key" {
  description = "Storage account access key for audit logs"
  type        = string
  default     = null
  sensitive   = true
}

variable "auditing_storage_account_access_key_is_secondary" {
  description = "Whether the storage account access key is secondary"
  type        = bool
  default     = false
}

variable "auditing_retention_days" {
  description = "Number of days to retain audit logs"
  type        = number
  default     = 90

  validation {
    condition     = var.auditing_retention_days >= 0 && var.auditing_retention_days <= 3285
    error_message = "Auditing retention must be between 0 and 3285 days."
  }
}

variable "auditing_log_monitoring_enabled" {
  description = "Enable log monitoring for audit logs"
  type        = bool
  default     = true
}

# Vulnerability assessment
variable "enable_vulnerability_assessment" {
  description = "Enable vulnerability assessment"
  type        = bool
  default     = false
}

variable "vulnerability_assessment_baseline_rules" {
  description = "Vulnerability assessment baseline rules"
  type = list(object({
    rule_id          = string
    baseline_results = list(string)
  }))
  default = []
}

# Database configuration
variable "collation" {
  description = "Database collation"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "license_type" {
  description = "License type for the database (LicenseIncluded or BasePrice)"
  type        = string
  default     = "LicenseIncluded"

  validation {
    condition     = contains(["LicenseIncluded", "BasePrice"], var.license_type)
    error_message = "License type must be either 'LicenseIncluded' or 'BasePrice'."
  }
}

variable "read_replica_count" {
  description = "Number of read replicas"
  type        = number
  default     = 0

  validation {
    condition     = var.read_replica_count >= 0 && var.read_replica_count <= 4
    error_message = "Read replica count must be between 0 and 4."
  }
}

# Database creation options
variable "create_mode" {
  description = "Database creation mode"
  type        = string
  default     = "Default"

  validation {
    condition = contains([
      "Default", "Copy", "OnlineSecondary", "PointInTimeRestore",
      "Recovery", "Restore", "RestoreLongTermRetentionBackup"
    ], var.create_mode)
    error_message = "Create mode must be a valid Azure SQL Database creation mode."
  }
}

variable "creation_source_database_id" {
  description = "ID of the source database for copy operations"
  type        = string
  default     = null
}

variable "restore_point_in_time" {
  description = "Point in time for restore operations (RFC3339 format)"
  type        = string
  default     = null
}

variable "recover_database_id" {
  description = "ID of the database to recover from"
  type        = string
  default     = null
}

variable "restore_dropped_database_id" {
  description = "ID of the dropped database to restore"
  type        = string
  default     = null
}

# Geo backup and replication
variable "geo_backup_enabled" {
  description = "Enable geo-redundant backup"
  type        = bool
  default     = true
}

variable "storage_account_type" {
  description = "Storage account type for backups (Local, Zone, Geo, GeoZone)"
  type        = string
  default     = "Geo"

  validation {
    condition     = contains(["Local", "Zone", "Geo", "GeoZone"], var.storage_account_type)
    error_message = "Storage account type must be Local, Zone, Geo, or GeoZone."
  }
}