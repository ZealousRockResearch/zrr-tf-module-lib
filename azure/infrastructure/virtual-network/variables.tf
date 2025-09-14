# Required variables
variable "name" {
  description = "Name of the virtual network"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{1,64}$", var.name))
    error_message = "Name must be 1-64 characters long and contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group where the VNet will be created"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network (CIDR notation)"
  type        = list(string)

  validation {
    condition = alltrue([
      for cidr in var.address_space : can(cidrhost(cidr, 0))
    ])
    error_message = "All address spaces must be valid CIDR blocks."
  }
}

variable "subnets" {
  description = "List of subnets to create within the VNet"
  type = list(object({
    name                                          = string
    address_prefixes                              = optional(list(string))
    newbits                                       = optional(number)
    private_endpoint_network_policies             = optional(string)
    private_link_service_network_policies_enabled = optional(bool)
    service_endpoints                             = optional(list(string))
    create_nsg                                    = optional(bool)
    create_route_table                            = optional(bool)
    disable_bgp_route_propagation                 = optional(bool)
    delegations = optional(list(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string))
      })
    })))
  }))
  default = []
}

# Optional variables
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod", "dr"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod, dr."
  }
}

variable "location_short" {
  description = "Short abbreviation for the Azure region (e.g., eus for eastus)"
  type        = string
  default     = ""
}

variable "use_naming_convention" {
  description = "Use ZRR naming convention for resources"
  type        = bool
  default     = true
}

variable "dns_servers" {
  description = "List of custom DNS servers for the VNet"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for ip in var.dns_servers : can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", ip))
    ])
    error_message = "All DNS servers must be valid IPv4 addresses."
  }
}

# Subnet calculation
variable "auto_calculate_subnets" {
  description = "Automatically calculate subnet addresses based on the VNet address space"
  type        = bool
  default     = false
}

# DDoS Protection
variable "enable_ddos_protection" {
  description = "Enable DDoS protection plan for the VNet"
  type        = bool
  default     = false
}

variable "ddos_protection_plan_id" {
  description = "ID of the DDoS protection plan to associate with the VNet"
  type        = string
  default     = ""
}

# NSG Configuration
variable "create_default_nsg_rules" {
  description = "Create default NSG rules for security baseline"
  type        = bool
  default     = true
}

# VNet Peering
variable "vnet_peerings" {
  description = "Map of VNet peering configurations"
  type = map(object({
    remote_vnet_id               = string
    allow_virtual_network_access = optional(bool)
    allow_forwarded_traffic      = optional(bool)
    allow_gateway_transit        = optional(bool)
    use_remote_gateways          = optional(bool)
  }))
  default = {}
}

# Flow Logs Configuration
variable "enable_flow_logs" {
  description = "Enable Network Watcher flow logs for NSGs"
  type        = bool
  default     = false
}

variable "network_watcher_name" {
  description = "Name of the Network Watcher instance"
  type        = string
  default     = ""
}

variable "network_watcher_resource_group_name" {
  description = "Resource group name of the Network Watcher"
  type        = string
  default     = ""
}

variable "flow_log_storage_account_id" {
  description = "Storage account ID for storing flow logs"
  type        = string
  default     = ""
}

variable "flow_log_retention_days" {
  description = "Number of days to retain flow logs"
  type        = number
  default     = 30

  validation {
    condition     = var.flow_log_retention_days >= 0 && var.flow_log_retention_days <= 365
    error_message = "Flow log retention days must be between 0 and 365."
  }
}

# Traffic Analytics
variable "enable_traffic_analytics" {
  description = "Enable traffic analytics for flow logs"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for traffic analytics"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_region" {
  description = "Region of the Log Analytics workspace"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_resource_id" {
  description = "Resource ID of the Log Analytics workspace"
  type        = string
  default     = ""
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
variable "vnet_tags" {
  description = "Additional tags specific to the virtual network"
  type        = map(string)
  default     = {}
}