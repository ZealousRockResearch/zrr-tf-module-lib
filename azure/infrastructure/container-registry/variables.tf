variable "name" {
  description = "The name of the container registry"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.name))
    error_message = "Container registry name must be 5-50 characters, alphanumeric only."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where the container registry should be created"
  type        = string
  default     = "eastus"
}

variable "sku" {
  description = "The SKU of the container registry (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium."
  }
}

variable "admin_enabled" {
  description = "Enable admin user for the container registry"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for the container registry"
  type        = bool
  default     = true
}

variable "network_rule_set" {
  description = "Network rule set configuration (Premium SKU only)"
  type = object({
    default_action = string
    ip_rules = optional(list(object({
      action   = string
      ip_range = string
    })))
  })
  default = null
}

variable "retention_policy" {
  description = "Retention policy configuration (Premium SKU only)"
  type = object({
    enabled = bool
    days    = number
  })
  default = null
}

variable "trust_policy" {
  description = "Trust policy configuration (Premium SKU only)"
  type = object({
    enabled = bool
  })
  default = null
}

variable "encryption" {
  description = "Encryption configuration (Premium SKU only)"
  type = object({
    enabled            = bool
    key_vault_key_id   = string
    identity_client_id = string
  })
  default = null
}

variable "identity_type" {
  description = "The type of identity to use (SystemAssigned, UserAssigned, SystemAssigned, UserAssigned)"
  type        = string
  default     = null
}

variable "identity_ids" {
  description = "List of user assigned identity IDs"
  type        = list(string)
  default     = null
}

variable "georeplications" {
  description = "List of geo-replication configurations (Premium SKU only)"
  type = list(object({
    location                = string
    tags                    = optional(map(string))
    zone_redundancy_enabled = optional(bool)
  }))
  default = []
}

variable "images_to_import" {
  description = "Map of images to import from Docker Hub or other registries"
  type = map(object({
    source = string
    target = optional(string)
  }))
  default = {}

  # Example:
  # {
  #   ghost = {
  #     source = "docker.io/library/ghost:5-alpine"
  #     target = "ghost:5-alpine"
  #   }
  # }
}

variable "scheduled_import_tasks" {
  description = "Map of scheduled tasks to import images"
  type = map(object({
    source   = string
    target   = string
    schedule = optional(string) # Cron expression
  }))
  default = {}

  # Example:
  # {
  #   ghost-daily = {
  #     source   = "docker.io/library/ghost:5-alpine"
  #     target   = "ghost:5-alpine"
  #     schedule = "0 2 * * *"  # Daily at 2 AM
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

variable "acr_tags" {
  description = "Additional tags specific to the container registry"
  type        = map(string)
  default     = {}
}