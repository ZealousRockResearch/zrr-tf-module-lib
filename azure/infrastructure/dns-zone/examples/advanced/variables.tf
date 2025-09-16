variable "zone_name" {
  description = "Name of the DNS zone (domain name)"
  type        = string
  default     = "advanced-example.com"
}

variable "resource_group_name" {
  description = "Name of the resource group where the DNS zone will be created"
  type        = string
  default     = "dns-advanced-rg"
}

# Complete DNS Records Configuration
variable "a_records" {
  description = "List of A records to create"
  type = list(object({
    name    = string
    ttl     = number
    records = list(string)
  }))
  default = [
    {
      name    = "www"
      ttl     = 3600
      records = ["1.2.3.4", "5.6.7.8"]
    },
    {
      name    = "api"
      ttl     = 300
      records = ["10.0.1.100"]
    },
    {
      name    = "app"
      ttl     = 600
      records = ["192.168.1.10", "192.168.1.11"]
    }
  ]
}

variable "aaaa_records" {
  description = "List of AAAA records to create"
  type = list(object({
    name    = string
    ttl     = number
    records = list(string)
  }))
  default = [
    {
      name    = "www"
      ttl     = 3600
      records = ["2001:db8::1", "2001:db8::2"]
    },
    {
      name    = "api"
      ttl     = 300
      records = ["2001:db8:100::1"]
    }
  ]
}

variable "cname_records" {
  description = "List of CNAME records to create"
  type = list(object({
    name   = string
    ttl    = number
    record = string
  }))
  default = [
    {
      name   = "blog"
      ttl    = 3600
      record = "www.advanced-example.com"
    },
    {
      name   = "docs"
      ttl    = 1800
      record = "app.advanced-example.com"
    },
    {
      name   = "cdn"
      ttl    = 86400
      record = "cloudfront.amazonaws.com"
    }
  ]
}

variable "mx_records" {
  description = "List of MX records to create"
  type = list(object({
    name = string
    ttl  = number
    records = list(object({
      preference = number
      exchange   = string
    }))
  }))
  default = [
    {
      name = "@"
      ttl  = 3600
      records = [
        {
          preference = 10
          exchange   = "mail1.advanced-example.com"
        },
        {
          preference = 20
          exchange   = "mail2.advanced-example.com"
        }
      ]
    }
  ]
}

variable "txt_records" {
  description = "List of TXT records to create"
  type = list(object({
    name    = string
    ttl     = number
    records = list(string)
  }))
  default = [
    {
      name = "@"
      ttl  = 3600
      records = [
        "v=spf1 include:_spf.google.com include:mailgun.org ~all",
        "google-site-verification=ABC123DEF456"
      ]
    },
    {
      name    = "_dmarc"
      ttl     = 3600
      records = ["v=DMARC1; p=quarantine; rua=mailto:dmarc@advanced-example.com"]
    },
    {
      name    = "selector1._domainkey"
      ttl     = 3600
      records = ["k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC..."]
    }
  ]
}

variable "srv_records" {
  description = "List of SRV records to create"
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
  default = [
    {
      name = "_sip._tcp"
      ttl  = 3600
      records = [
        {
          priority = 10
          weight   = 5
          port     = 5060
          target   = "sip1.advanced-example.com"
        },
        {
          priority = 10
          weight   = 5
          port     = 5060
          target   = "sip2.advanced-example.com"
        }
      ]
    },
    {
      name = "_xmpp-server._tcp"
      ttl  = 3600
      records = [
        {
          priority = 5
          weight   = 0
          port     = 5269
          target   = "xmpp.advanced-example.com"
        }
      ]
    }
  ]
}

variable "ptr_records" {
  description = "List of PTR records to create"
  type = list(object({
    name    = string
    ttl     = number
    records = list(string)
  }))
  default = [
    {
      name    = "4.3.2.1"
      ttl     = 3600
      records = ["www.advanced-example.com"]
    }
  ]
}

# Delegation Configuration
variable "enable_delegation" {
  description = "Enable DNS delegation"
  type        = bool
  default     = true
}

variable "parent_zone_name" {
  description = "Parent zone name for delegation"
  type        = string
  default     = "example.com"
}

variable "delegation_ttl" {
  description = "TTL for delegation records"
  type        = number
  default     = 172800
}

variable "verify_delegation" {
  description = "Verify parent zone exists"
  type        = bool
  default     = true
}

# Virtual Network Integration
variable "virtual_network_id" {
  description = "Virtual Network ID for private DNS"
  type        = string
  default     = null
}

variable "enable_auto_registration" {
  description = "Enable auto-registration"
  type        = bool
  default     = false
}

# Monitoring and Alerting
variable "enable_monitoring" {
  description = "Enable monitoring and alerting"
  type        = bool
  default     = true
}

variable "action_group_id" {
  description = "Action Group ID for alerts"
  type        = string
  default     = null
}

variable "query_volume_threshold" {
  description = "Query volume alert threshold"
  type        = number
  default     = 10000
}

variable "record_set_count_threshold" {
  description = "Record set count alert threshold"
  type        = number
  default     = 5000
}

# Naming Convention
variable "use_naming_convention" {
  description = "Use ZRR naming convention"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "domain_suffix" {
  description = "Domain suffix for naming"
  type        = string
  default     = "internal"
}

# Security Features
variable "enable_zone_signing" {
  description = "Enable DNSSEC zone signing"
  type        = bool
  default     = true
}

variable "zone_signing_key_rollover_frequency" {
  description = "Key rollover frequency in days"
  type        = number
  default     = 30
}

# Advanced SOA Configuration
variable "soa_record" {
  description = "Custom SOA record configuration"
  type = object({
    email         = optional(string, "admin.advanced-example.com")
    expire_time   = optional(number, 2419200)
    minimum_ttl   = optional(number, 300)
    refresh_time  = optional(number, 3600)
    retry_time    = optional(number, 300)
    serial_number = optional(number, 1)
    ttl           = optional(number, 3600)
  })
  default = {
    email         = "admin.advanced-example.com"
    expire_time   = 2419200
    minimum_ttl   = 300
    refresh_time  = 3600
    retry_time    = 300
    serial_number = 1
    ttl           = 3600
  }
}

# Tags
variable "common_tags" {
  description = "Common tags for the advanced example"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "enterprise-dns"
    Owner       = "platform-team"
    CostCenter  = "engineering"
    Compliance  = "SOX"
    ManagedBy   = "Terraform"
  }
}

variable "dns_zone_tags" {
  description = "Additional tags for the DNS zone"
  type        = map(string)
  default = {
    DNSType       = "public"
    Purpose       = "production"
    Monitoring    = "enabled"
    DNSSEC        = "enabled"
    Delegation    = "enabled"
    RecordTypes   = "comprehensive"
    AlertsEnabled = "true"
    BackupEnabled = "true"
  }
}