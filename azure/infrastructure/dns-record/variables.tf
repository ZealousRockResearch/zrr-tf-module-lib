# DNS record configuration
variable "name" {
  description = "Name of the DNS record (use '@' for apex record)"
  type        = string

  validation {
    condition     = can(regex("^(@|[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?)$", var.name))
    error_message = "DNS record name must be a valid hostname or '@' for apex record. Must be 1-63 characters, start and end with alphanumeric characters."
  }
}

variable "record_type" {
  description = "Type of DNS record to create"
  type        = string

  validation {
    condition     = contains(["A", "AAAA", "CNAME", "MX", "NS", "PTR", "SOA", "SRV", "TXT", "CAA"], upper(var.record_type))
    error_message = "Record type must be one of: A, AAAA, CNAME, MX, NS, PTR, SOA, SRV, TXT, CAA."
  }
}

variable "records" {
  description = "List of record values (format depends on record type)"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.records) > 0
    error_message = "At least one record value must be provided."
  }
}

# DNS Zone identification (one of these is required)
variable "dns_zone_id" {
  description = "Resource ID of the public DNS zone"
  type        = string
  default     = null
}

variable "dns_zone_name" {
  description = "Name of the public DNS zone"
  type        = string
  default     = null
}

variable "dns_zone_resource_group_name" {
  description = "Resource group name of the public DNS zone (required when using dns_zone_name)"
  type        = string
  default     = null
}

variable "private_dns_zone_name" {
  description = "Name of the private DNS zone"
  type        = string
  default     = null
}

variable "private_dns_zone_resource_group_name" {
  description = "Resource group name of the private DNS zone (required when using private_dns_zone_name)"
  type        = string
  default     = null
}

# TTL configuration
variable "ttl" {
  description = "Time to Live (TTL) for the DNS record in seconds"
  type        = number
  default     = null

  validation {
    condition     = var.ttl == null || (var.ttl >= 1 && var.ttl <= 2147483647)
    error_message = "TTL must be between 1 and 2147483647 seconds when specified."
  }
}

variable "default_ttl" {
  description = "Default TTL to use when ttl is not specified"
  type        = number
  default     = 3600

  validation {
    condition     = var.default_ttl >= 1 && var.default_ttl <= 2147483647
    error_message = "Default TTL must be between 1 and 2147483647 seconds."
  }
}

# MX record specific configuration
variable "mx_records" {
  description = "List of MX record configurations (required for MX record type)"
  type = list(object({
    preference = number
    exchange   = string
  }))
  default = null

  validation {
    condition = var.mx_records == null || alltrue([
      for record in var.mx_records : record.preference >= 0 && record.preference <= 65535
    ])
    error_message = "MX record preference must be between 0 and 65535."
  }

  validation {
    condition = var.mx_records == null || alltrue([
      for record in var.mx_records : can(regex("^[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?(\\.([a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?))*\\.$", record.exchange))
    ])
    error_message = "MX record exchange must be a valid FQDN ending with a dot."
  }
}

# SRV record specific configuration
variable "srv_records" {
  description = "List of SRV record configurations (required for SRV record type)"
  type = list(object({
    priority = number
    weight   = number
    port     = number
    target   = string
  }))
  default = null

  validation {
    condition = var.srv_records == null || alltrue([
      for record in var.srv_records : record.priority >= 0 && record.priority <= 65535
    ])
    error_message = "SRV record priority must be between 0 and 65535."
  }

  validation {
    condition = var.srv_records == null || alltrue([
      for record in var.srv_records : record.weight >= 0 && record.weight <= 65535
    ])
    error_message = "SRV record weight must be between 0 and 65535."
  }

  validation {
    condition = var.srv_records == null || alltrue([
      for record in var.srv_records : record.port >= 0 && record.port <= 65535
    ])
    error_message = "SRV record port must be between 0 and 65535."
  }

  validation {
    condition = var.srv_records == null || alltrue([
      for record in var.srv_records : can(regex("^[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?(\\.([a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?))*\\.$", record.target))
    ])
    error_message = "SRV record target must be a valid FQDN ending with a dot."
  }
}

# Monitoring and governance
variable "enable_monitoring" {
  description = "Enable monitoring for DNS record changes and health"
  type        = bool
  default     = false
}

variable "health_check_enabled" {
  description = "Enable health monitoring for the DNS record"
  type        = bool
  default     = false
}

variable "alert_on_changes" {
  description = "Send alerts when DNS record is modified"
  type        = bool
  default     = false
}

# Environment and compliance
variable "environment" {
  description = "Environment name (used for validation and governance)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod", "sandbox"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod, sandbox."
  }
}

variable "criticality" {
  description = "Criticality level of the DNS record"
  type        = string
  default     = "low"

  validation {
    condition     = contains(["low", "medium", "high", "critical"], var.criticality)
    error_message = "Criticality must be one of: low, medium, high, critical."
  }
}

variable "compliance_requirements" {
  description = "List of compliance requirements for the DNS record"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for req in var.compliance_requirements : contains(["SOX", "PCI-DSS", "HIPAA", "GDPR", "SOC2"], req)
    ])
    error_message = "Compliance requirements must be from: SOX, PCI-DSS, HIPAA, GDPR, SOC2."
  }
}

# Record lifecycle management
variable "record_lifecycle" {
  description = "Lifecycle management configuration for the DNS record"
  type = object({
    auto_delete_after_days   = optional(number)
    backup_enabled           = optional(bool, false)
    change_approval_required = optional(bool, false)
    scheduled_updates        = optional(bool, false)
  })
  default = {}

  validation {
    condition     = var.record_lifecycle.auto_delete_after_days == null || var.record_lifecycle.auto_delete_after_days > 0
    error_message = "Auto delete days must be greater than 0 when specified."
  }
}

# Security configuration
variable "security_config" {
  description = "Security configuration for the DNS record"
  type = object({
    access_restrictions   = optional(list(string), [])
    change_protection     = optional(bool, false)
    audit_logging         = optional(bool, true)
    encryption_in_transit = optional(bool, true)
  })
  default = {}
}

# Validation rules
variable "validation_rules" {
  description = "Additional validation rules for record values"
  type = object({
    strict_format_checking = optional(bool, true)
    allow_wildcard_records = optional(bool, false)
    max_record_count       = optional(number, 100)
    forbidden_values       = optional(list(string), [])
  })
  default = {}

  validation {
    condition     = var.validation_rules.max_record_count == null || var.validation_rules.max_record_count > 0
    error_message = "Max record count must be greater than 0 when specified."
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
variable "dns_record_tags" {
  description = "Additional tags specific to the DNS record"
  type        = map(string)
  default     = {}
}