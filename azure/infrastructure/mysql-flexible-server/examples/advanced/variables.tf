variable "mysql_server_name" {
  description = "Name of the MySQL server to create"
  type        = string
  default     = "advanced-mysql"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  # This should be set when running the example
}

variable "location" {
  description = "Azure region for the MySQL server"
  type        = string
  default     = "East US"
}

variable "administrator_login" {
  description = "Administrator login for the MySQL server"
  type        = string
  default     = "mysqladmin"
}

variable "administrator_password" {
  description = "Administrator password for the MySQL server"
  type        = string
  sensitive   = true
  # This should be set when running the example
}

# Server configuration
variable "sku_name" {
  description = "SKU name for the MySQL server"
  type        = string
  default     = "MO_Standard_E4ds_v4"
}

variable "mysql_version" {
  description = "Version of MySQL server"
  type        = string
  default     = "8.0.21"
}

variable "storage_size_gb" {
  description = "Storage size in GB"
  type        = number
  default     = 1000
}

variable "storage_iops" {
  description = "Storage IOPS"
  type        = number
  default     = 3000
}

variable "availability_zone" {
  description = "Primary availability zone"
  type        = string
  default     = "1"
}

# High availability
variable "high_availability_mode" {
  description = "High availability mode"
  type        = string
  default     = "ZoneRedundant"
}

variable "standby_availability_zone" {
  description = "Standby availability zone"
  type        = string
  default     = "2"
}

# Backup configuration
variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 35
}

variable "geo_redundant_backup_enabled" {
  description = "Enable geo-redundant backup"
  type        = bool
  default     = true
}

# Networking
variable "delegated_subnet_id" {
  description = "ID of the delegated subnet"
  type        = string
  default     = null
  # This should be set when running the example if using private networking
}

variable "private_dns_zone_id" {
  description = "ID of the private DNS zone"
  type        = string
  default     = null
  # This should be set when running the example if using private networking
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = false
}

# Security
variable "identity_type" {
  description = "Type of managed identity"
  type        = string
  default     = "UserAssigned"
}

variable "identity_ids" {
  description = "List of user assigned identity IDs"
  type        = list(string)
  default     = []
  # This should be set when running the example if using user-assigned identities
}

variable "customer_managed_key_id" {
  description = "Customer managed key ID for encryption"
  type        = string
  default     = null
}

variable "primary_user_assigned_identity_id" {
  description = "Primary user assigned identity ID"
  type        = string
  default     = null
}

# Databases
variable "databases" {
  description = "List of databases to create"
  type = list(object({
    name      = string
    charset   = optional(string, "utf8mb4")
    collation = optional(string, "utf8mb4_unicode_ci")
  }))
  default = [
    {
      name      = "app_db"
      charset   = "utf8mb4"
      collation = "utf8mb4_unicode_ci"
    },
    {
      name      = "analytics_db"
      charset   = "utf8mb4"
      collation = "utf8mb4_unicode_ci"
    },
    {
      name      = "logging_db"
      charset   = "utf8mb4"
      collation = "utf8mb4_unicode_ci"
    }
  ]
}

# Server configurations
variable "server_configurations" {
  description = "Map of server configuration parameters"
  type        = map(string)
  default = {
    "innodb_buffer_pool_size"  = "75"
    "max_connections"          = "200"
    "slow_query_log"           = "ON"
    "long_query_time"          = "2"
    "innodb_lock_wait_timeout" = "50"
    "wait_timeout"             = "28800"
    "interactive_timeout"      = "28800"
  }
}

# Firewall rules
variable "firewall_rules" {
  description = "List of firewall rules"
  type = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
  default = [
    {
      name             = "AllowAzureServices"
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    }
  ]
}

# Azure AD administrator
variable "aad_administrator" {
  description = "Azure AD administrator configuration"
  type = object({
    identity_id = string
    login       = string
    object_id   = string
    tenant_id   = string
  })
  default = null
  # This should be set when running the example if using Azure AD authentication
}

# Maintenance window
variable "maintenance_window" {
  description = "Maintenance window configuration"
  type = object({
    day_of_week  = number
    start_hour   = number
    start_minute = number
  })
  default = {
    day_of_week  = 0 # Sunday
    start_hour   = 2
    start_minute = 0
  }
}

# Private endpoint
variable "enable_private_endpoint" {
  description = "Enable private endpoint"
  type        = bool
  default     = true
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = null
  # This should be set when running the example if enabling private endpoint
}

variable "private_endpoint_dns_zone_id" {
  description = "Private DNS zone ID for private endpoint"
  type        = string
  default     = null
  # This should be set when running the example if enabling private endpoint
}

# Monitoring and alerting
variable "enable_monitoring" {
  description = "Enable monitoring and alerting"
  type        = bool
  default     = true
}

variable "alert_email_addresses" {
  description = "List of email addresses for alerts"
  type        = list(string)
  default     = ["admin@company.com", "dba@company.com"]
}

variable "cpu_alert_threshold" {
  description = "CPU utilization alert threshold percentage"
  type        = number
  default     = 85
}

variable "memory_alert_threshold" {
  description = "Memory utilization alert threshold percentage"
  type        = number
  default     = 90
}

variable "connection_alert_threshold" {
  description = "Active connections alert threshold"
  type        = number
  default     = 150
}

# Diagnostic settings
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
  default     = null
  # This should be set when running the example if enabling diagnostics
}

variable "diagnostic_storage_account_id" {
  description = "Storage account ID for diagnostic logs"
  type        = string
  default     = null
}

# Tags
variable "common_tags" {
  description = "Common tags for the example"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "enterprise-mysql"
    Owner       = "platform-team"
    CostCenter  = "engineering"
  }
}

variable "mysql_tags" {
  description = "Additional tags for the MySQL server"
  type        = map(string)
  default = {
    Purpose         = "production"
    DatabaseType    = "mysql"
    BackupEnabled   = "true"
    HAEnabled       = "true"
    MonitoringLevel = "enhanced"
    Compliance      = "required"
  }
}