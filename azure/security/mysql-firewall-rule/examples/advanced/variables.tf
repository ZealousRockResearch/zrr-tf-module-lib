variable "mysql_flexible_server_name" {
  description = "Name of the MySQL Flexible Server for the advanced example"
  type        = string
  default     = "example-mysql-flexible-server"
}

variable "mysql_flexible_server_resource_group_name" {
  description = "Resource group name of the MySQL Flexible Server"
  type        = string
  default     = "example-rg"
}

variable "firewall_rules" {
  description = "Custom firewall rules for the advanced example"
  type = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
  default = [
    {
      name             = "AllowDataCenter1"
      start_ip_address = "10.0.1.0"
      end_ip_address   = "10.0.1.255"
    },
    {
      name             = "AllowDataCenter2"
      start_ip_address = "10.0.2.0"
      end_ip_address   = "10.0.2.255"
    },
    {
      name             = "AllowPartnerNetwork"
      start_ip_address = "172.16.0.0"
      end_ip_address   = "172.16.255.255"
    }
  ]
}

variable "allow_office_ips" {
  description = "Office IP addresses and CIDR blocks"
  type        = list(string)
  default = [
    "203.0.113.0/24",
    "198.51.100.50"
  ]
}

variable "allow_developer_ips" {
  description = "Developer workstation IP addresses"
  type        = list(string)
  default = [
    "192.0.2.10",
    "192.0.2.20",
    "192.0.2.30"
  ]
}

variable "allow_application_subnets" {
  description = "Application subnet CIDR blocks"
  type        = list(string)
  default = [
    "10.1.0.0/24",
    "10.2.0.0/24",
    "10.3.0.0/24"
  ]
}

variable "allow_azure_services" {
  description = "Allow Azure services access"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment name for the advanced example"
  type        = string
  default     = "prod"
}

variable "enable_monitoring" {
  description = "Enable monitoring for the advanced example"
  type        = bool
  default     = true
}

variable "alert_on_rule_changes" {
  description = "Enable alerting on rule changes"
  type        = bool
  default     = true
}

variable "require_justification" {
  description = "Require justification for firewall rules"
  type        = bool
  default     = true
}

variable "max_firewall_rules" {
  description = "Maximum number of firewall rules"
  type        = number
  default     = 30
}

variable "enable_ip_range_validation" {
  description = "Enable IP range validation"
  type        = bool
  default     = true
}

variable "compliance_tags" {
  description = "Compliance tags for the advanced example"
  type        = map(string)
  default = {
    DataClassification = "Internal"
    ComplianceScope    = "SOX"
    ReviewDate         = "2024-12-31"
    SecurityReview     = "Approved"
  }
}

variable "common_tags" {
  description = "Common tags for the advanced example"
  type        = map(string)
  default = {
    Environment = "prod"
    Project     = "enterprise-app"
    Owner       = "security-team"
    CostCenter  = "IT"
  }
}

variable "mysql_firewall_rule_tags" {
  description = "MySQL firewall rule specific tags"
  type        = map(string)
  default = {
    Purpose           = "database-security"
    SecurityLevel     = "high"
    ReviewCycle       = "quarterly"
    MaintenanceWindow = "sunday-2am"
  }
}