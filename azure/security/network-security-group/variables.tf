# Required variables
variable "name" {
  description = "Name of the network security group"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{1,80}$", var.name))
    error_message = "Name must be 1-80 characters long and contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "location" {
  description = "Azure region where the network security group will be created"
  type        = string
  default     = "East US"

  validation {
    condition = contains([
      "East US", "East US 2", "West US", "West US 2", "West US 3",
      "Central US", "North Central US", "South Central US", "West Central US",
      "Canada Central", "Canada East", "Brazil South", "North Europe",
      "West Europe", "UK South", "UK West", "France Central", "France South",
      "Germany West Central", "Norway East", "Switzerland North", "Sweden Central",
      "UAE North", "South Africa North", "Australia East", "Australia Southeast",
      "East Asia", "Southeast Asia", "Japan East", "Japan West", "Korea Central",
      "Korea South", "India Central", "India South", "India West"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group. Required if create_resource_group is false"
  type        = string
  default     = null

  validation {
    condition     = var.resource_group_name == null || can(regex("^[a-zA-Z0-9-_\\.\\(\\)]{1,90}$", var.resource_group_name))
    error_message = "Resource group name must be 1-90 characters long and contain only alphanumeric characters, hyphens, underscores, periods, and parentheses."
  }
}

variable "create_resource_group" {
  description = "Whether to create a new resource group"
  type        = bool
  default     = false
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
variable "network_security_group_tags" {
  description = "Additional tags specific to the network security group"
  type        = map(string)
  default     = {}
}

# Security Rules
variable "security_rules" {
  description = "List of security rules to create"
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
    description                  = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.security_rules : rule.priority >= 100 && rule.priority <= 4096
    ])
    error_message = "Security rule priority must be between 100 and 4096."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules : contains(["Inbound", "Outbound"], rule.direction)
    ])
    error_message = "Security rule direction must be either 'Inbound' or 'Outbound'."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules : contains(["Allow", "Deny"], rule.access)
    ])
    error_message = "Security rule access must be either 'Allow' or 'Deny'."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules : contains(["Tcp", "Udp", "Icmp", "Esp", "Ah", "*"], rule.protocol)
    ])
    error_message = "Security rule protocol must be one of: Tcp, Udp, Icmp, Esp, Ah, or *."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules : can(regex("^[a-zA-Z0-9-_]{1,80}$", rule.name))
    ])
    error_message = "Security rule names must be 1-80 characters long and contain only alphanumeric characters, hyphens, and underscores."
  }
}

# Association variables
variable "subnet_id" {
  description = "ID of the subnet to associate with the network security group"
  type        = string
  default     = null
}

variable "network_interface_ids" {
  description = "List of network interface IDs to associate with the network security group"
  type        = list(string)
  default     = []
}

# Advanced configuration options
variable "enable_flow_logs" {
  description = "Enable flow logs for the network security group"
  type        = bool
  default     = false
}

variable "flow_log_storage_account_id" {
  description = "Storage account ID for flow logs (required if enable_flow_logs is true)"
  type        = string
  default     = null

  validation {
    condition     = var.enable_flow_logs == false || (var.enable_flow_logs == true && var.flow_log_storage_account_id != null)
    error_message = "Flow log storage account ID is required when flow logs are enabled."
  }
}

variable "flow_log_retention_days" {
  description = "Number of days to retain flow logs"
  type        = number
  default     = 30

  validation {
    condition     = var.flow_log_retention_days >= 1 && var.flow_log_retention_days <= 365
    error_message = "Flow log retention days must be between 1 and 365."
  }
}

variable "flow_log_format_type" {
  description = "Format type for flow logs"
  type        = string
  default     = "JSON"

  validation {
    condition     = contains(["JSON"], var.flow_log_format_type)
    error_message = "Flow log format type must be 'JSON'."
  }
}

variable "flow_log_format_version" {
  description = "Format version for flow logs"
  type        = number
  default     = 2

  validation {
    condition     = contains([1, 2], var.flow_log_format_version)
    error_message = "Flow log format version must be 1 or 2."
  }
}