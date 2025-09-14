# Required variables
variable "name" {
  description = "Name of the MySQL Flexible Server"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.name))
    error_message = "Server name must be 3-63 characters long, start and end with alphanumeric characters, and contain only lowercase letters, numbers, and hyphens."
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

variable "administrator_login" {
  description = "Administrator login for the MySQL server"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,15}$", var.administrator_login))
    error_message = "Administrator login must be 1-16 characters long, start with a letter, and contain only letters, numbers, and underscores."
  }
}

variable "administrator_password" {
  description = "Administrator password for the MySQL server"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.administrator_password) >= 8 && length(var.administrator_password) <= 128
    error_message = "Administrator password must be between 8 and 128 characters long."
  }
}

# Server configuration
variable "sku_name" {
  description = "SKU name for the MySQL server"
  type        = string
  default     = "GP_Standard_D2ds_v4"

  validation {
    condition = contains([
      "B_Standard_B1s", "B_Standard_B1ms", "B_Standard_B2s",
      "GP_Standard_D2ds_v4", "GP_Standard_D4ds_v4", "GP_Standard_D8ds_v4", "GP_Standard_D16ds_v4", "GP_Standard_D32ds_v4", "GP_Standard_D48ds_v4", "GP_Standard_D64ds_v4",
      "MO_Standard_E2ds_v4", "MO_Standard_E4ds_v4", "MO_Standard_E8ds_v4", "MO_Standard_E16ds_v4", "MO_Standard_E32ds_v4", "MO_Standard_E48ds_v4", "MO_Standard_E64ds_v4"
    ], var.sku_name)
    error_message = "SKU name must be a valid MySQL Flexible Server SKU."
  }
}

variable "mysql_version" {
  description = "Version of MySQL server"
  type        = string
  default     = "8.0.21"

  validation {
    condition     = contains(["5.7", "8.0.21"], var.mysql_version)
    error_message = "MySQL version must be either 5.7 or 8.0.21."
  }
}

variable "storage_size_gb" {
  description = "Storage size in GB"
  type        = number
  default     = 100

  validation {
    condition     = var.storage_size_gb >= 20 && var.storage_size_gb <= 16384
    error_message = "Storage size must be between 20 GB and 16384 GB (16 TB)."
  }
}

variable "storage_iops" {
  description = "Storage IOPS (Input/Output Operations Per Second)"
  type        = number
  default     = null

  validation {
    condition     = var.storage_iops == null || (var.storage_iops >= 360 && var.storage_iops <= 20000)
    error_message = "Storage IOPS must be between 360 and 20000, or null for auto-scaling."
  }
}

variable "storage_auto_grow_enabled" {
  description = "Enable storage auto-grow"
  type        = bool
  default     = true
}

# Backup configuration
variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "Backup retention days must be between 1 and 35."
  }
}

variable "geo_redundant_backup_enabled" {
  description = "Enable geo-redundant backup"
  type        = bool
  default     = false
}

# High availability configuration
variable "high_availability_mode" {
  description = "High availability mode for the server"
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["Disabled", "ZoneRedundant", "SameZone"], var.high_availability_mode)
    error_message = "High availability mode must be Disabled, ZoneRedundant, or SameZone."
  }
}

variable "standby_availability_zone" {
  description = "Standby availability zone for high availability"
  type        = string
  default     = null

  validation {
    condition     = var.standby_availability_zone == null || contains(["1", "2", "3"], var.standby_availability_zone)
    error_message = "Standby availability zone must be 1, 2, or 3."
  }
}

variable "availability_zone" {
  description = "Primary availability zone for the server"
  type        = string
  default     = null

  validation {
    condition     = var.availability_zone == null || contains(["1", "2", "3"], var.availability_zone)
    error_message = "Availability zone must be 1, 2, or 3."
  }
}

# Maintenance window
variable "maintenance_window" {
  description = "Maintenance window configuration"
  type = object({
    day_of_week  = number
    start_hour   = number
    start_minute = number
  })
  default = null

  validation {
    condition = var.maintenance_window == null || (
      var.maintenance_window.day_of_week >= 0 && var.maintenance_window.day_of_week <= 6 &&
      var.maintenance_window.start_hour >= 0 && var.maintenance_window.start_hour <= 23 &&
      var.maintenance_window.start_minute >= 0 && var.maintenance_window.start_minute <= 59
    )
    error_message = "Maintenance window day_of_week must be 0-6, start_hour must be 0-23, and start_minute must be 0-59."
  }
}

# Networking configuration
variable "delegated_subnet_id" {
  description = "ID of the delegated subnet for private access"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "ID of the private DNS zone"
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = false
}

# Security configuration
variable "customer_managed_key_id" {
  description = "Customer managed key ID for data encryption"
  type        = string
  default     = null
}

variable "primary_user_assigned_identity_id" {
  description = "Primary user assigned identity ID for customer managed key"
  type        = string
  default     = null
}

variable "geo_backup_key_vault_key_id" {
  description = "Geo backup key vault key ID"
  type        = string
  default     = null
}

variable "geo_backup_user_assigned_identity_id" {
  description = "Geo backup user assigned identity ID"
  type        = string
  default     = null
}

variable "identity_type" {
  description = "Type of managed identity"
  type        = string
  default     = null

  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned"], var.identity_type)
    error_message = "Identity type must be SystemAssigned or UserAssigned."
  }
}

variable "identity_ids" {
  description = "List of user assigned identity IDs"
  type        = list(string)
  default     = []
}

# Database configuration
variable "databases" {
  description = "List of databases to create"
  type = list(object({
    name      = string
    charset   = optional(string, "utf8mb3")
    collation = optional(string, "utf8mb3_general_ci")
  }))
  default = []
}

variable "server_configurations" {
  description = "Map of server configuration parameters"
  type        = map(string)
  default     = {}
}

# Firewall rules
variable "firewall_rules" {
  description = "List of firewall rules"
  type = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
  default = []
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
}

# Private endpoint configuration
variable "enable_private_endpoint" {
  description = "Enable private endpoint"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = null
}

variable "private_endpoint_dns_zone_id" {
  description = "Private DNS zone ID for private endpoint"
  type        = string
  default     = null
}

# Monitoring and diagnostics
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
  default     = null
}

variable "diagnostic_storage_account_id" {
  description = "Storage account ID for diagnostic logs"
  type        = string
  default     = null
}

variable "diagnostic_metrics" {
  description = "List of diagnostic metrics"
  type = list(object({
    category = string
    enabled  = bool
    retention_policy = object({
      enabled = bool
      days    = number
    })
  }))
  default = [
    {
      category = "AllMetrics"
      enabled  = true
      retention_policy = {
        enabled = true
        days    = 30
      }
    }
  ]
}

variable "diagnostic_logs" {
  description = "List of diagnostic logs"
  type = list(object({
    category = string
    retention_policy = object({
      enabled = bool
      days    = number
    })
  }))
  default = [
    {
      category = "MySqlSlowLogs"
      retention_policy = {
        enabled = true
        days    = 30
      }
    },
    {
      category = "MySqlAuditLogs"
      retention_policy = {
        enabled = true
        days    = 30
      }
    }
  ]
}

# Alerting configuration
variable "enable_monitoring" {
  description = "Enable monitoring and alerting"
  type        = bool
  default     = false
}

variable "alert_email_addresses" {
  description = "List of email addresses for alerts"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for email in var.alert_email_addresses : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))])
    error_message = "All email addresses must be valid."
  }
}

variable "cpu_alert_threshold" {
  description = "CPU utilization alert threshold percentage"
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_alert_threshold >= 0 && var.cpu_alert_threshold <= 100
    error_message = "CPU alert threshold must be between 0 and 100."
  }
}

variable "cpu_alert_severity" {
  description = "CPU alert severity"
  type        = number
  default     = 2

  validation {
    condition     = var.cpu_alert_severity >= 0 && var.cpu_alert_severity <= 4
    error_message = "Alert severity must be between 0 (Critical) and 4 (Verbose)."
  }
}

variable "memory_alert_threshold" {
  description = "Memory utilization alert threshold percentage"
  type        = number
  default     = 80

  validation {
    condition     = var.memory_alert_threshold >= 0 && var.memory_alert_threshold <= 100
    error_message = "Memory alert threshold must be between 0 and 100."
  }
}

variable "memory_alert_severity" {
  description = "Memory alert severity"
  type        = number
  default     = 2

  validation {
    condition     = var.memory_alert_severity >= 0 && var.memory_alert_severity <= 4
    error_message = "Alert severity must be between 0 (Critical) and 4 (Verbose)."
  }
}

variable "connection_alert_threshold" {
  description = "Active connections alert threshold"
  type        = number
  default     = 80

  validation {
    condition     = var.connection_alert_threshold >= 0
    error_message = "Connection alert threshold must be greater than or equal to 0."
  }
}

variable "connection_alert_severity" {
  description = "Connection alert severity"
  type        = number
  default     = 2

  validation {
    condition     = var.connection_alert_severity >= 0 && var.connection_alert_severity <= 4
    error_message = "Alert severity must be between 0 (Critical) and 4 (Verbose)."
  }
}

# Naming convention
variable "use_naming_convention" {
  description = "Use standardized naming convention"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name (used in naming convention)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

variable "location_short" {
  description = "Short location code for naming convention"
  type        = string
  default     = "eus"

  validation {
    condition     = length(var.location_short) >= 2 && length(var.location_short) <= 5
    error_message = "Location short code must be between 2 and 5 characters."
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

# MySQL specific tags
variable "mysql_tags" {
  description = "Additional tags specific to the MySQL server"
  type        = map(string)
  default     = {}
}