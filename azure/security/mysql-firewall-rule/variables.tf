# MySQL Server identification (one of these is required)
variable "mysql_server_id" {
  description = "Resource ID of the MySQL server (supports both Single Server and Flexible Server)"
  type        = string
  default     = null
}

variable "mysql_server_name" {
  description = "Name of the MySQL Single Server"
  type        = string
  default     = null
}

variable "mysql_server_resource_group_name" {
  description = "Resource group name of the MySQL Single Server (required when using mysql_server_name)"
  type        = string
  default     = null
}

variable "mysql_flexible_server_name" {
  description = "Name of the MySQL Flexible Server"
  type        = string
  default     = null
}

variable "mysql_flexible_server_resource_group_name" {
  description = "Resource group name of the MySQL Flexible Server (required when using mysql_flexible_server_name)"
  type        = string
  default     = null
}

# Firewall rules configuration
variable "firewall_rules" {
  description = "List of firewall rules to create for the MySQL server"
  type = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.firewall_rules : can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,127}$", rule.name))
    ])
    error_message = "Firewall rule names must start with alphanumeric character and be 1-128 characters long, containing only alphanumeric characters, hyphens, and underscores."
  }

  validation {
    condition = alltrue([
      for rule in var.firewall_rules : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", rule.start_ip_address))
    ])
    error_message = "Start IP addresses must be valid IPv4 addresses."
  }

  validation {
    condition = alltrue([
      for rule in var.firewall_rules : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", rule.end_ip_address))
    ])
    error_message = "End IP addresses must be valid IPv4 addresses."
  }
}

# Azure Services access
variable "allow_azure_services" {
  description = "Whether to allow access from Azure services and resources"
  type        = bool
  default     = false
}

# Predefined IP ranges for common scenarios
variable "allow_office_ips" {
  description = "List of office IP addresses or ranges to allow access"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for ip in var.allow_office_ips : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}(?:/[0-9]{1,2})?$", ip))
    ])
    error_message = "Office IPs must be valid IPv4 addresses or CIDR blocks."
  }
}

variable "allow_developer_ips" {
  description = "List of developer IP addresses to allow access (for development environments)"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for ip in var.allow_developer_ips : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))
    ])
    error_message = "Developer IPs must be valid IPv4 addresses."
  }
}

variable "allow_application_subnets" {
  description = "List of application subnet CIDR blocks to allow access"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.allow_application_subnets : can(cidrhost(cidr, 0))
    ])
    error_message = "Application subnets must be valid CIDR blocks."
  }
}

# Security configuration
variable "enable_ip_range_validation" {
  description = "Enable strict IP range validation (start_ip <= end_ip)"
  type        = bool
  default     = true
}

variable "max_firewall_rules" {
  description = "Maximum number of firewall rules allowed (Azure limit is 128)"
  type        = number
  default     = 50

  validation {
    condition     = var.max_firewall_rules > 0 && var.max_firewall_rules <= 128
    error_message = "Maximum firewall rules must be between 1 and 128."
  }
}

# Environment-specific settings
variable "environment" {
  description = "Environment name (used for rule naming and validation)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod", "sandbox"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod, sandbox."
  }
}

# Monitoring and alerting
variable "enable_monitoring" {
  description = "Enable monitoring and alerting for firewall rule changes"
  type        = bool
  default     = false
}

variable "alert_on_rule_changes" {
  description = "Send alerts when firewall rules are modified"
  type        = bool
  default     = false
}

# Compliance and governance
variable "require_justification" {
  description = "Require justification tags for firewall rules in production environments"
  type        = bool
  default     = false
}

variable "compliance_tags" {
  description = "Additional compliance tags to apply to firewall rules"
  type        = map(string)
  default     = {}
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
variable "mysql_firewall_rule_tags" {
  description = "Additional tags specific to the MySQL firewall rules"
  type        = map(string)
  default     = {}
}