# Database identification
variable "name" {
  description = "Name of the MySQL database"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9]$", var.name)) && length(var.name) >= 2 && length(var.name) <= 64
    error_message = "Database name must start with a letter, contain only letters, numbers, and underscores, end with alphanumeric character, and be 2-64 characters long."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group containing the MySQL server"
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be 1-90 characters long."
  }
}

# Server configuration
variable "mysql_server_name" {
  description = "Name of the MySQL server (used when server IDs are not provided)"
  type        = string
  default     = null

  validation {
    condition = var.mysql_server_name == null || (
      can(regex("^[a-z0-9-]+$", var.mysql_server_name)) &&
      length(var.mysql_server_name) >= 3 &&
      length(var.mysql_server_name) <= 63 &&
      !startswith(var.mysql_server_name, "-") &&
      !endswith(var.mysql_server_name, "-")
    )
    error_message = "MySQL server name must be 3-63 characters long, contain only lowercase letters, numbers, and hyphens, and cannot start or end with a hyphen."
  }
}

variable "mysql_server_id" {
  description = "Resource ID of an existing MySQL Single Server"
  type        = string
  default     = null

  validation {
    condition     = var.mysql_server_id == null || can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/.+/providers/Microsoft\\.DBforMySQL/servers/.+$", var.mysql_server_id))
    error_message = "MySQL server ID must be a valid Azure resource ID for a MySQL server."
  }
}

variable "mysql_flexible_server_id" {
  description = "Resource ID of an existing MySQL Flexible Server"
  type        = string
  default     = null

  validation {
    condition     = var.mysql_flexible_server_id == null || can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/.+/providers/Microsoft\\.DBforMySQL/flexibleServers/.+$", var.mysql_flexible_server_id))
    error_message = "MySQL Flexible Server ID must be a valid Azure resource ID for a MySQL Flexible Server."
  }
}

variable "use_flexible_server" {
  description = "Whether to use MySQL Flexible Server (true) or Single Server (false)"
  type        = bool
  default     = true
}

# Database configuration
variable "charset" {
  description = "Character set for the database"
  type        = string
  default     = "utf8mb4"

  validation {
    condition = contains([
      "armscii8", "ascii", "big5", "binary", "cp1250", "cp1251", "cp1256", "cp1257",
      "cp850", "cp852", "cp866", "cp932", "dec8", "eucjpms", "euckr", "gb18030",
      "gb2312", "gbk", "geostd8", "greek", "hebrew", "hp8", "keybcs2", "koi8r",
      "koi8u", "latin1", "latin2", "latin5", "latin7", "macce", "macroman",
      "sjis", "swe7", "tis620", "ucs2", "ujis", "utf16", "utf16le", "utf32",
      "utf8", "utf8mb3", "utf8mb4"
    ], var.charset)
    error_message = "Character set must be a valid MySQL character set."
  }
}

variable "collation" {
  description = "Collation for the database"
  type        = string
  default     = "utf8mb4_unicode_ci"

  validation {
    condition     = can(regex("^[a-z0-9_]+$", var.collation))
    error_message = "Collation must be a valid MySQL collation name."
  }
}

# Additional databases
variable "additional_databases" {
  description = "List of additional databases to create on the same server"
  type = list(object({
    name      = string
    charset   = optional(string, "utf8mb4")
    collation = optional(string, "utf8mb4_unicode_ci")
  }))
  default = []

  validation {
    condition = alltrue([
      for db in var.additional_databases :
      can(regex("^[a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9]$", db.name)) &&
      length(db.name) >= 2 && length(db.name) <= 64
    ])
    error_message = "All additional database names must follow MySQL naming conventions: start with letter, 2-64 characters, letters/numbers/underscores only."
  }
}

# Database users and privileges
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

  validation {
    condition = alltrue([
      for user in var.database_users :
      can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", user.username)) &&
      length(user.username) >= 1 && length(user.username) <= 32
    ])
    error_message = "All usernames must be 1-32 characters, start with a letter, and contain only letters, numbers, and underscores."
  }

  validation {
    condition = alltrue([
      for user in var.database_users :
      length(user.password) >= 8 && length(user.password) <= 128
    ])
    error_message = "All passwords must be 8-128 characters long."
  }

  validation {
    condition = alltrue([
      for user in var.database_users :
      alltrue([
        for priv in user.privileges :
        contains(["SELECT", "INSERT", "UPDATE", "DELETE", "CREATE", "DROP", "RELOAD", "SHUTDOWN", "PROCESS", "FILE", "REFERENCES", "INDEX", "ALTER", "SHOW DATABASES", "SUPER", "CREATE TEMPORARY TABLES", "LOCK TABLES", "EXECUTE", "REPLICATION SLAVE", "REPLICATION CLIENT", "CREATE VIEW", "SHOW VIEW", "CREATE ROUTINE", "ALTER ROUTINE", "CREATE USER", "EVENT", "TRIGGER"], priv.type)
      ])
    ])
    error_message = "All privilege types must be valid MySQL privileges."
  }
}

# Performance and configuration
variable "performance_configurations" {
  description = "Performance-related MySQL server configurations (Single Server only)"
  type        = map(string)
  default = {
    innodb_buffer_pool_size = "70"
    max_connections         = "100"
    query_cache_size        = "0"
    query_cache_type        = "OFF"
    slow_query_log          = "ON"
    long_query_time         = "2"
  }

  validation {
    condition = alltrue([
      for key, value in var.performance_configurations :
      can(regex("^[a-zA-Z_][a-zA-Z0-9_]*$", key))
    ])
    error_message = "All configuration parameter names must be valid MySQL parameter names."
  }
}

# Monitoring and alerting
variable "enable_monitoring" {
  description = "Enable database monitoring and alerting"
  type        = bool
  default     = false
}

variable "action_group_id" {
  description = "Azure Monitor Action Group ID for alerts"
  type        = string
  default     = null

  validation {
    condition     = var.action_group_id == null || can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/.+/providers/microsoft\\.insights/actionGroups/.+$", var.action_group_id))
    error_message = "Action Group ID must be a valid Azure resource ID for an Action Group."
  }
}

variable "connection_alert_threshold" {
  description = "Threshold for database connection alerts"
  type        = number
  default     = 80

  validation {
    condition     = var.connection_alert_threshold >= 1 && var.connection_alert_threshold <= 1000
    error_message = "Connection alert threshold must be between 1 and 1000."
  }
}

variable "storage_alert_threshold" {
  description = "Threshold for database storage usage alerts (percentage)"
  type        = number
  default     = 85

  validation {
    condition     = var.storage_alert_threshold >= 0 && var.storage_alert_threshold <= 100
    error_message = "Storage alert threshold must be between 0 and 100 percent."
  }
}

# Network security
variable "subnet_id" {
  description = "Subnet ID for VNet integration (Single Server only)"
  type        = string
  default     = null

  validation {
    condition     = var.subnet_id == null || can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", var.subnet_id))
    error_message = "Subnet ID must be a valid Azure resource ID for a subnet."
  }
}

# Audit and logging
variable "enable_audit_logging" {
  description = "Enable audit logging for the database (Single Server only)"
  type        = bool
  default     = false
}

variable "audit_log_events" {
  description = "Audit log events to capture"
  type        = string
  default     = "CONNECTION,DML,DDL"

  validation {
    condition     = can(regex("^(CONNECTION|DML|DDL|DCL|ADMIN)(,(CONNECTION|DML|DDL|DCL|ADMIN))*$", var.audit_log_events))
    error_message = "Audit log events must be a comma-separated list of: CONNECTION, DML, DDL, DCL, ADMIN."
  }
}

variable "enable_slow_query_log" {
  description = "Enable slow query logging"
  type        = bool
  default     = false
}

variable "slow_query_threshold" {
  description = "Threshold in seconds for slow query logging"
  type        = number
  default     = 2

  validation {
    condition     = var.slow_query_threshold >= 0 && var.slow_query_threshold <= 86400
    error_message = "Slow query threshold must be between 0 and 86400 seconds."
  }
}

# Naming convention
variable "use_naming_convention" {
  description = "Use ZRR naming convention for database name"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name for naming convention"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod", "sandbox"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod, sandbox."
  }
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

# Tags
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

variable "mysql_database_tags" {
  description = "Additional tags specific to the MySQL database"
  type        = map(string)
  default = {
    DatabaseType = "mysql"
    Purpose      = "application"
  }
}