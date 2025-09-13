# Required variables
variable "database_name" {
  description = "Name of the Azure SQL Database"
  type        = string
  default     = "enterprise-database"
}

variable "sql_server_name" {
  description = "Name of the existing Azure SQL Server"
  type        = string
  default     = "enterprise-sql-server"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "enterprise-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

# Performance and scaling variables
variable "sku_name" {
  description = "SKU name for the database"
  type        = string
  default     = "GP_Gen5_4"
}

variable "max_size_gb" {
  description = "Maximum size of the database in GB"
  type        = number
  default     = 500
}

variable "zone_redundant" {
  description = "Whether the database is zone redundant"
  type        = bool
  default     = true
}

variable "read_scale" {
  description = "Enable read scale-out for the database"
  type        = bool
  default     = true
}

variable "read_replica_count" {
  description = "Number of read replicas"
  type        = number
  default     = 2
}

variable "auto_pause_delay_in_minutes" {
  description = "Time in minutes after which database is automatically paused (-1 to disable)"
  type        = number
  default     = -1
}

variable "min_capacity" {
  description = "Minimum capacity for serverless databases"
  type        = number
  default     = null
}

# Backup and retention variables
variable "short_term_retention_days" {
  description = "Point in time retention in days"
  type        = number
  default     = 14
}

variable "backup_interval_in_hours" {
  description = "Backup interval in hours"
  type        = number
  default     = 12
}

variable "long_term_retention_policy" {
  description = "Long term retention policy configuration"
  type = object({
    weekly_retention  = optional(string, null)
    monthly_retention = optional(string, null)
    yearly_retention  = optional(string, null)
    week_of_year      = optional(number, null)
  })
  default = {
    weekly_retention  = "P4W"
    monthly_retention = "P12M"
    yearly_retention  = "P5Y"
    week_of_year      = 1
  }
}

variable "geo_backup_enabled" {
  description = "Enable geo-redundant backup"
  type        = bool
  default     = true
}

variable "storage_account_type" {
  description = "Storage account type for backups"
  type        = string
  default     = "GeoZone"
}

# Security variables
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
  default     = ["security@company.com", "dba@company.com"]
}

variable "threat_detection_retention_days" {
  description = "Number of days to retain threat detection logs"
  type        = number
  default     = 90
}

variable "threat_detection_storage_endpoint" {
  description = "Storage endpoint for threat detection logs"
  type        = string
  default     = null
}

variable "threat_detection_storage_account_access_key" {
  description = "Storage account access key for threat detection logs"
  type        = string
  default     = null
  sensitive   = true
}

variable "transparent_data_encryption_enabled" {
  description = "Enable transparent data encryption"
  type        = bool
  default     = true
}

# Auditing variables
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
  default     = 365
}

variable "auditing_log_monitoring_enabled" {
  description = "Enable log monitoring for audit logs"
  type        = bool
  default     = true
}

# Vulnerability assessment variables
variable "enable_vulnerability_assessment" {
  description = "Enable vulnerability assessment"
  type        = bool
  default     = true
}

variable "vulnerability_assessment_baseline_rules" {
  description = "Vulnerability assessment baseline rules"
  type = list(object({
    rule_id          = string
    baseline_results = list(string)
  }))
  default = []
}

# Database configuration variables
variable "collation" {
  description = "Database collation"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "license_type" {
  description = "License type for the database"
  type        = string
  default     = "LicenseIncluded"
}

# Creation mode variables
variable "create_mode" {
  description = "Database creation mode"
  type        = string
  default     = "Default"
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

# Advanced example specific variables
variable "create_audit_storage" {
  description = "Create a storage account for auditing and threat detection"
  type        = bool
  default     = true
}

variable "audit_storage_account_name" {
  description = "Name for the audit storage account (must be globally unique)"
  type        = string
  default     = "sqlauditlogs"
}

variable "create_log_analytics" {
  description = "Create a Log Analytics workspace for monitoring"
  type        = bool
  default     = true
}

variable "log_analytics_retention_days" {
  description = "Log Analytics workspace retention in days"
  type        = number
  default     = 365
}

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for the database"
  type        = bool
  default     = true
}

variable "existing_log_analytics_workspace_id" {
  description = "ID of existing Log Analytics workspace (if create_log_analytics is false)"
  type        = string
  default     = null
}

variable "diagnostic_log_categories" {
  description = "List of log categories to enable for diagnostics"
  type        = list(string)
  default = [
    "SQLInsights",
    "AutomaticTuning",
    "QueryStoreRuntimeStatistics",
    "QueryStoreWaitStatistics",
    "Errors",
    "DatabaseWaitStatistics",
    "Timeouts",
    "Blocks",
    "Deadlocks"
  ]
}

variable "diagnostic_metrics" {
  description = "List of metric categories to enable for diagnostics"
  type        = list(string)
  default = [
    "Basic",
    "InstanceAndAppAdvanced",
    "WorkloadManagement"
  ]
}

# Tags
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "enterprise-app"
    Owner       = "data-team"
    Compliance  = "required"
    ManagedBy   = "Terraform"
  }
}

variable "azure_sql_db_tags" {
  description = "Additional tags specific to the Azure SQL Database"
  type        = map(string)
  default = {
    Backup      = "critical"
    Monitoring  = "enhanced"
    Encryption  = "required"
    Tier        = "enterprise"
    Replication = "enabled"
  }
}