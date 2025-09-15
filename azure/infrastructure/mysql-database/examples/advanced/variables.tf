variable "database_name" {
  description = "Name of the primary MySQL database"
  type        = string
  default     = "primary_db"
}

variable "resource_group_name" {
  description = "Name of the resource group containing the MySQL server"
  type        = string
  default     = "production-rg"
}

variable "mysql_server_name" {
  description = "Name of the MySQL server"
  type        = string
  default     = "production-mysql-server"
}

variable "mysql_server_id" {
  description = "Resource ID of an existing MySQL Server"
  type        = string
  default     = null
}

variable "use_flexible_server" {
  description = "Whether to use MySQL Flexible Server (true) or Single Server (false)"
  type        = bool
  default     = false
}

# Database configuration
variable "charset" {
  description = "Character set for the primary database"
  type        = string
  default     = "utf8mb4"
}

variable "collation" {
  description = "Collation for the primary database"
  type        = string
  default     = "utf8mb4_unicode_ci"
}

# Additional databases
variable "additional_databases" {
  description = "List of additional databases to create"
  type = list(object({
    name      = string
    charset   = optional(string, "utf8mb4")
    collation = optional(string, "utf8mb4_unicode_ci")
  }))
  default = [
    {
      name      = "analytics_db"
      charset   = "utf8mb4"
      collation = "utf8mb4_unicode_ci"
    },
    {
      name      = "logging_db"
      charset   = "utf8mb4"
      collation = "utf8mb4_unicode_ci"
    },
    {
      name      = "reporting_db"
      charset   = "utf8mb4"
      collation = "utf8mb4_unicode_ci"
    }
  ]
}

# Database users and privileges (Single Server only)
variable "database_users" {
  description = "List of database users to create with their privileges"
  type = list(object({
    username = string
    password = string
    privileges = list(object({
      type     = string
      database = string
      table    = optional(string, "*")
    }))
  }))
  default   = []
  sensitive = true
}

# Performance configurations
variable "performance_configurations" {
  description = "Performance-related MySQL server configurations"
  type        = map(string)
  default = {
    innodb_buffer_pool_size  = "75"
    max_connections          = "200"
    slow_query_log           = "ON"
    long_query_time          = "2"
    innodb_lock_wait_timeout = "50"
    wait_timeout             = "28800"
    interactive_timeout      = "28800"
    query_cache_type         = "OFF"
    query_cache_size         = "0"
  }
}

# Monitoring and alerting
variable "enable_monitoring" {
  description = "Enable database monitoring and alerting"
  type        = bool
  default     = true
}

variable "action_group_id" {
  description = "Azure Monitor Action Group ID for alerts"
  type        = string
  default     = null
}

variable "connection_alert_threshold" {
  description = "Threshold for database connection alerts"
  type        = number
  default     = 150
}

variable "storage_alert_threshold" {
  description = "Threshold for database storage usage alerts (percentage)"
  type        = number
  default     = 85
}

# Network security
variable "subnet_id" {
  description = "Subnet ID for VNet integration"
  type        = string
  default     = null
}

# Audit and logging
variable "enable_audit_logging" {
  description = "Enable audit logging for the database"
  type        = bool
  default     = true
}

variable "audit_log_events" {
  description = "Audit log events to capture"
  type        = string
  default     = "CONNECTION,DML,DDL"
}

variable "enable_slow_query_log" {
  description = "Enable slow query logging"
  type        = bool
  default     = true
}

variable "slow_query_threshold" {
  description = "Threshold in seconds for slow query logging"
  type        = number
  default     = 2
}

# Naming convention
variable "use_naming_convention" {
  description = "Use ZRR naming convention for database name"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment name for naming convention"
  type        = string
  default     = "prod"
}

variable "location_short" {
  description = "Short location code for naming convention"
  type        = string
  default     = "eus"
}

# Tags
variable "common_tags" {
  description = "Common tags for the advanced example"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "enterprise-mysql"
    Owner       = "platform-team"
    CostCenter  = "engineering"
    Compliance  = "SOX"
    ManagedBy   = "Terraform"
  }
}

variable "mysql_database_tags" {
  description = "Additional tags for the MySQL databases"
  type        = map(string)
  default = {
    DatabaseType    = "mysql"
    Purpose         = "production"
    BackupEnabled   = "true"
    MonitoringLevel = "enhanced"
    Compliance      = "required"
    DataClass       = "confidential"
    AuditEnabled    = "true"
  }
}