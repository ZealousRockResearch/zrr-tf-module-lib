# Required variables
variable "name" {
  description = "Name of the DNS zone (domain name or subdomain)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\\.([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?))*$", var.name))
    error_message = "DNS zone name must be a valid domain name format (e.g., example.com, subdomain.example.com)."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group where the DNS zone will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]{1,90}$", var.resource_group_name))
    error_message = "Resource group name must be 1-90 characters long and contain only alphanumeric characters, periods, underscores, and hyphens."
  }
}

# Optional resource group ID (takes precedence over resource_group_name)
variable "resource_group_id" {
  description = "Resource ID of an existing resource group (takes precedence over resource_group_name)"
  type        = string
  default     = null

  validation {
    condition     = var.resource_group_id == null || can(regex("^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+$", var.resource_group_id))
    error_message = "Resource group ID must be a valid Azure resource ID format."
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

# DNS zone specific tags
variable "dns_zone_tags" {
  description = "Additional tags specific to the DNS zone"
  type        = map(string)
  default     = {}
}

# DNS Records Configuration
variable "a_records" {
  description = "List of A records to create in the DNS zone"
  type = list(object({
    name    = string
    ttl     = number
    records = list(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for record in var.a_records : can(regex("^[a-zA-Z0-9._*-]{1,63}$", record.name))
    ])
    error_message = "A record names must be valid DNS names (1-63 characters, alphanumeric, dots, underscores, asterisks, and hyphens)."
  }

  validation {
    condition = alltrue([
      for record in var.a_records : record.ttl >= 1 && record.ttl <= 2147483647
    ])
    error_message = "TTL must be between 1 and 2147483647 seconds."
  }
}

variable "aaaa_records" {
  description = "List of AAAA records to create in the DNS zone"
  type = list(object({
    name    = string
    ttl     = number
    records = list(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for record in var.aaaa_records : can(regex("^[a-zA-Z0-9._*-]{1,63}$", record.name))
    ])
    error_message = "AAAA record names must be valid DNS names."
  }
}

variable "cname_records" {
  description = "List of CNAME records to create in the DNS zone"
  type = list(object({
    name   = string
    ttl    = number
    record = string
  }))
  default = []

  validation {
    condition = alltrue([
      for record in var.cname_records : can(regex("^[a-zA-Z0-9._*-]{1,63}$", record.name))
    ])
    error_message = "CNAME record names must be valid DNS names."
  }
}

variable "mx_records" {
  description = "List of MX records to create in the DNS zone"
  type = list(object({
    name = string
    ttl  = number
    records = list(object({
      preference = number
      exchange   = string
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for record in var.mx_records : can(regex("^[a-zA-Z0-9._*-]{1,63}$", record.name))
    ])
    error_message = "MX record names must be valid DNS names."
  }

  validation {
    condition = alltrue([
      for record in var.mx_records : alltrue([
        for mx in record.records : mx.preference >= 0 && mx.preference <= 65535
      ])
    ])
    error_message = "MX preference values must be between 0 and 65535."
  }
}

variable "txt_records" {
  description = "List of TXT records to create in the DNS zone"
  type = list(object({
    name    = string
    ttl     = number
    records = list(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for record in var.txt_records : can(regex("^[a-zA-Z0-9._*-]{1,63}$", record.name))
    ])
    error_message = "TXT record names must be valid DNS names."
  }
}

variable "srv_records" {
  description = "List of SRV records to create in the DNS zone"
  type = list(object({
    name = string
    ttl  = number
    records = list(object({
      priority = number
      weight   = number
      port     = number
      target   = string
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for record in var.srv_records : can(regex("^[a-zA-Z0-9._*-]{1,63}$", record.name))
    ])
    error_message = "SRV record names must be valid DNS names."
  }
}

variable "ptr_records" {
  description = "List of PTR records to create in the DNS zone"
  type = list(object({
    name    = string
    ttl     = number
    records = list(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for record in var.ptr_records : can(regex("^[a-zA-Z0-9._*-]{1,63}$", record.name))
    ])
    error_message = "PTR record names must be valid DNS names."
  }
}

# Delegation configuration
variable "enable_delegation" {
  description = "Enable DNS delegation by creating NS records in parent zone"
  type        = bool
  default     = false
}

variable "parent_zone_name" {
  description = "Name of the parent DNS zone for delegation"
  type        = string
  default     = null

  validation {
    condition     = var.parent_zone_name == null || can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\\.([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?))*$", var.parent_zone_name))
    error_message = "Parent zone name must be a valid domain name format."
  }
}

variable "parent_zone_resource_group_name" {
  description = "Resource group name of the parent DNS zone (if different from current zone)"
  type        = string
  default     = null
}

variable "delegation_ttl" {
  description = "TTL for delegation NS records"
  type        = number
  default     = 172800

  validation {
    condition     = var.delegation_ttl >= 1 && var.delegation_ttl <= 2147483647
    error_message = "Delegation TTL must be between 1 and 2147483647 seconds."
  }
}

variable "verify_delegation" {
  description = "Verify that parent zone exists before creating delegation"
  type        = bool
  default     = true
}

# Virtual Network Integration
variable "virtual_network_id" {
  description = "Virtual Network ID to link with the private DNS zone"
  type        = string
  default     = null

  validation {
    condition     = var.virtual_network_id == null || can(regex("^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Microsoft.Network/virtualNetworks/[^/]+$", var.virtual_network_id))
    error_message = "Virtual network ID must be a valid Azure resource ID format."
  }
}

variable "enable_auto_registration" {
  description = "Enable auto-registration of virtual machine records in the private DNS zone"
  type        = bool
  default     = false
}

# Monitoring and alerting
variable "enable_monitoring" {
  description = "Enable DNS zone monitoring and alerting"
  type        = bool
  default     = false
}

variable "action_group_id" {
  description = "Azure Monitor Action Group ID for DNS alerts"
  type        = string
  default     = null

  validation {
    condition     = var.action_group_id == null || can(regex("^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/microsoft.insights/actionGroups/[^/]+$", var.action_group_id))
    error_message = "Action group ID must be a valid Azure resource ID format."
  }
}

variable "query_volume_threshold" {
  description = "Threshold for DNS query volume alerts"
  type        = number
  default     = 1000

  validation {
    condition     = var.query_volume_threshold >= 1
    error_message = "Query volume threshold must be at least 1."
  }
}

variable "record_set_count_threshold" {
  description = "Threshold for DNS record set count alerts"
  type        = number
  default     = 10000

  validation {
    condition     = var.record_set_count_threshold >= 0
    error_message = "Record set count threshold must be non-negative."
  }
}

# Naming convention
variable "use_naming_convention" {
  description = "Use ZRR naming convention for DNS zone name"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name for naming convention"
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,10}$", var.environment))
    error_message = "Environment must be 1-10 characters long and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "domain_suffix" {
  description = "Domain suffix for naming convention"
  type        = string
  default     = "local"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\\.([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?))*$", var.domain_suffix))
    error_message = "Domain suffix must be a valid domain name format."
  }
}

# Advanced configuration
variable "soa_record" {
  description = "Custom SOA record configuration"
  type = object({
    email         = optional(string, "admin")
    expire_time   = optional(number, 2419200)
    minimum_ttl   = optional(number, 300)
    refresh_time  = optional(number, 3600)
    retry_time    = optional(number, 300)
    serial_number = optional(number, 1)
    ttl           = optional(number, 3600)
  })
  default = null
}

# Security and compliance
variable "enable_zone_signing" {
  description = "Enable DNSSEC zone signing (requires Azure DNS premium)"
  type        = bool
  default     = false
}

variable "zone_signing_key_rollover_frequency" {
  description = "Frequency of zone signing key rollover in days"
  type        = number
  default     = 30

  validation {
    condition     = var.zone_signing_key_rollover_frequency >= 1 && var.zone_signing_key_rollover_frequency <= 365
    error_message = "Zone signing key rollover frequency must be between 1 and 365 days."
  }
}