variable "name" {
  description = "The name of the Log Analytics workspace"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{2,61}[a-zA-Z0-9]$", var.name))
    error_message = "Workspace name must be 4-63 characters, start and end with alphanumeric, and contain only alphanumeric and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where the Log Analytics workspace should be created"
  type        = string
  default     = "eastus"
}

variable "sku" {
  description = "The SKU of the Log Analytics workspace"
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = contains(["Free", "Standalone", "PerNode", "PerGB2018", "Premium", "Standard", "Unlimited", "CapacityReservation"], var.sku)
    error_message = "SKU must be one of: Free, Standalone, PerNode, PerGB2018, Premium, Standard, Unlimited, CapacityReservation."
  }
}

variable "retention_in_days" {
  description = "The workspace data retention in days (30-730)"
  type        = number
  default     = 30

  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "Retention must be between 30 and 730 days."
  }
}

variable "daily_quota_gb" {
  description = "The daily ingestion quota in GB. Set to -1 for no limit"
  type        = number
  default     = -1

  validation {
    condition     = var.daily_quota_gb == -1 || var.daily_quota_gb >= 0.023
    error_message = "Daily quota must be -1 (unlimited) or at least 0.023 GB."
  }
}

variable "internet_ingestion_enabled" {
  description = "Whether internet ingestion is enabled for the workspace"
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Whether internet query is enabled for the workspace"
  type        = bool
  default     = true
}

variable "local_authentication_disabled" {
  description = "Whether local authentication is disabled for the workspace"
  type        = bool
  default     = false
}

variable "reservation_capacity_in_gb_per_day" {
  description = "The capacity reservation level in GB per day (100, 200, 300, 400, 500, 1000, 2000, 5000)"
  type        = number
  default     = null

  validation {
    condition = var.reservation_capacity_in_gb_per_day == null || contains([100, 200, 300, 400, 500, 1000, 2000, 5000], var.reservation_capacity_in_gb_per_day)
    error_message = "Reservation capacity must be one of: 100, 200, 300, 400, 500, 1000, 2000, 5000 GB per day."
  }
}

variable "identity_type" {
  description = "The type of identity to use (SystemAssigned, UserAssigned)"
  type        = string
  default     = null

  validation {
    condition = var.identity_type == null || contains(["SystemAssigned", "UserAssigned"], var.identity_type)
    error_message = "Identity type must be SystemAssigned or UserAssigned."
  }
}

variable "identity_ids" {
  description = "List of user assigned identity IDs (required if identity_type is UserAssigned)"
  type        = list(string)
  default     = null
}

variable "solutions" {
  description = "Map of Log Analytics solutions to install"
  type = map(object({
    publisher = string
    product   = string
  }))
  default = {}

  # Example:
  # {
  #   ContainerInsights = {
  #     publisher = "Microsoft"
  #     product   = "OMSGallery/ContainerInsights"
  #   }
  # }
}

variable "data_collection_rules" {
  description = "Map of data collection rules"
  type = map(object({
    description = string
    data_flows = list(object({
      streams = list(string)
    }))
    performance_counters = list(object({
      streams                       = list(string)
      sampling_frequency_in_seconds = number
      counter_specifiers            = list(string)
      name                          = string
    }))
    windows_event_logs = list(object({
      streams        = list(string)
      x_path_queries = list(string)
      name           = string
    }))
  }))
  default = {}
}

variable "saved_searches" {
  description = "Map of saved searches"
  type = map(object({
    category            = string
    display_name        = string
    query               = string
    function_alias      = optional(string)
    function_parameters = optional(list(string))
  }))
  default = {}

  # Example:
  # {
  #   error_logs = {
  #     category     = "General"
  #     display_name = "Error Logs"
  #     query        = "search * | where Type == \"Error\""
  #   }
  # }
}

variable "environment" {
  description = "Environment name (dev, test, stage, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "stage", "prod"], var.environment)
    error_message = "Environment must be dev, test, stage, or prod."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "workspace_tags" {
  description = "Additional tags specific to the Log Analytics workspace"
  type        = map(string)
  default     = {}
}