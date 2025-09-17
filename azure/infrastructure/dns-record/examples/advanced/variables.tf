variable "record_name" {
  description = "Name of the DNS record for the advanced example"
  type        = string
  default     = "api"
}

variable "record_type" {
  description = "Type of DNS record for the advanced example"
  type        = string
  default     = "A"
}

variable "records" {
  description = "Record values for the advanced example"
  type        = list(string)
  default     = ["203.0.113.10", "203.0.113.11"]
}

variable "ttl" {
  description = "TTL for the DNS record"
  type        = number
  default     = 300
}

variable "dns_zone_name" {
  description = "Name of the public DNS zone for the advanced example"
  type        = string
  default     = null
}

variable "dns_zone_resource_group_name" {
  description = "Resource group name of the public DNS zone"
  type        = string
  default     = null
}

variable "private_dns_zone_name" {
  description = "Name of the private DNS zone for the advanced example"
  type        = string
  default     = "internal.company.local"
}

variable "private_dns_zone_resource_group_name" {
  description = "Resource group name of the private DNS zone"
  type        = string
  default     = "private-dns-rg"
}

variable "mx_records" {
  description = "MX records configuration for advanced example"
  type = list(object({
    preference = number
    exchange   = string
  }))
  default = []
}

variable "srv_records" {
  description = "SRV records configuration for advanced example"
  type = list(object({
    priority = number
    weight   = number
    port     = number
    target   = string
  }))
  default = []
}

variable "environment" {
  description = "Environment for the advanced example"
  type        = string
  default     = "prod"
}

variable "criticality" {
  description = "Criticality level for the advanced example"
  type        = string
  default     = "high"
}

variable "enable_monitoring" {
  description = "Enable monitoring for the DNS record"
  type        = bool
  default     = true
}

variable "health_check_enabled" {
  description = "Enable health checks for the DNS record"
  type        = bool
  default     = true
}

variable "alert_on_changes" {
  description = "Enable alerts on DNS record changes"
  type        = bool
  default     = true
}

variable "compliance_requirements" {
  description = "Compliance requirements for the DNS record"
  type        = list(string)
  default     = ["SOX", "PCI-DSS", "ISO27001"]
}

variable "security_config" {
  description = "Security configuration for the DNS record"
  type = object({
    access_restrictions   = list(string)
    change_protection     = bool
    audit_logging         = bool
    encryption_in_transit = bool
  })
  default = {
    access_restrictions   = ["10.0.0.0/8", "172.16.0.0/12"]
    change_protection     = true
    audit_logging         = true
    encryption_in_transit = true
  }
}

variable "record_lifecycle" {
  description = "Record lifecycle configuration"
  type = object({
    auto_delete_after_days   = number
    backup_enabled           = bool
    change_approval_required = bool
    scheduled_updates        = bool
  })
  default = {
    auto_delete_after_days   = null
    backup_enabled           = true
    change_approval_required = true
    scheduled_updates        = false
  }
}

variable "validation_rules" {
  description = "Validation rules for the DNS record"
  type = object({
    strict_format_checking = bool
    allow_wildcard_records = bool
    max_record_count       = number
    forbidden_values       = list(string)
  })
  default = {
    strict_format_checking = true
    allow_wildcard_records = false
    max_record_count       = 10
    forbidden_values       = ["127.0.0.1", "localhost"]
  }
}

variable "common_tags" {
  description = "Common tags for the advanced example"
  type        = map(string)
  default = {
    Environment  = "prod"
    Project      = "enterprise-infrastructure"
    Owner        = "platform-team"
    CostCenter   = "engineering"
    BusinessUnit = "technology"
    Application  = "core-services"
    DataClass    = "internal"
    Compliance   = "required"
  }
}

variable "dns_record_tags" {
  description = "DNS record specific tags"
  type        = map(string)
  default = {
    Purpose      = "api-endpoint"
    ServiceTier  = "critical"
    Monitoring   = "enabled"
    Backup       = "daily"
    LoadBalanced = "true"
    HealthCheck  = "enabled"
  }
}