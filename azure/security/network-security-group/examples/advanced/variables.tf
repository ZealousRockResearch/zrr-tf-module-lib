variable "location" {
  description = "Azure region for the advanced example"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
  default     = "advanced-example-rg"
}

variable "management_subnets" {
  description = "List of management subnet CIDR blocks allowed for SSH"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "application_subnets" {
  description = "List of application subnet CIDR blocks allowed for database access"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "enable_flow_logs" {
  description = "Enable flow logs for the NSG"
  type        = bool
  default     = true
}

variable "flow_log_storage_account_id" {
  description = "Storage account ID for flow logs"
  type        = string
  default     = null
}

variable "flow_log_retention_days" {
  description = "Number of days to retain flow logs"
  type        = number
  default     = 90
}

variable "subnet_id" {
  description = "Subnet ID to associate with the NSG"
  type        = string
  default     = null
}

variable "network_interface_ids" {
  description = "List of network interface IDs to associate with the NSG"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Common tags for the advanced example"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "zrr-advanced"
    Owner       = "security-team"
    CostCenter  = "security"
  }
}