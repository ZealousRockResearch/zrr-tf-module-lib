variable "zone_name" {
  description = "Name of the DNS zone (domain name)"
  type        = string
  default     = "example-basic.com"
}

variable "resource_group_name" {
  description = "Name of the resource group where the DNS zone will be created"
  type        = string
  default     = "dns-basic-rg"
}

# DNS Records
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
      records = ["1.2.3.4"]
    },
    {
      name    = "api"
      ttl     = 300
      records = ["5.6.7.8"]
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
      record = "www.example-basic.com"
    }
  ]
}

# Tags
variable "common_tags" {
  description = "Common tags for the basic example"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "dns-basic-example"
    Owner       = "platform-team"
    ManagedBy   = "Terraform"
  }
}

variable "dns_zone_tags" {
  description = "Additional tags for the DNS zone"
  type        = map(string)
  default = {
    DNSType    = "public"
    Purpose    = "basic-example"
    Monitoring = "disabled"
    Records    = "minimal"
  }
}