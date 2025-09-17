variable "record_name" {
  description = "Name of the DNS record for the example"
  type        = string
  default     = "www"
}

variable "record_type" {
  description = "Type of DNS record for the example"
  type        = string
  default     = "A"
}

variable "records" {
  description = "Record values for the example"
  type        = list(string)
  default     = ["203.0.113.1", "203.0.113.2"]
}

variable "ttl" {
  description = "TTL for the DNS record"
  type        = number
  default     = 3600
}

variable "dns_zone_name" {
  description = "Name of the DNS zone for the example"
  type        = string
  default     = "example.com"
}

variable "dns_zone_resource_group_name" {
  description = "Resource group name of the DNS zone"
  type        = string
  default     = "dns-rg"
}

variable "environment" {
  description = "Environment for the example"
  type        = string
  default     = "dev"
}

variable "criticality" {
  description = "Criticality level for the example"
  type        = string
  default     = "low"
}

variable "common_tags" {
  description = "Common tags for the example"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "zrr-example"
    Owner       = "terraform"
  }
}