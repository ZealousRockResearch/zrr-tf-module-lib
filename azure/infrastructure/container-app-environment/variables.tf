variable "name" {
  description = "The name of the Container App Environment"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,30}[a-z0-9]$", var.name))
    error_message = "Environment name must be 2-32 characters, start with a letter, end with alphanumeric, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where the Container App Environment should be created"
  type        = string
  default     = "eastus"
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for Container App Environment"
  type        = string
}

variable "infrastructure_subnet_id" {
  description = "The subnet ID for Container App Environment infrastructure (optional)"
  type        = string
  default     = null
}

variable "internal_load_balancer_enabled" {
  description = "Whether the Container App Environment should use an internal load balancer"
  type        = bool
  default     = false
}

variable "zone_redundancy_enabled" {
  description = "Whether zone redundancy is enabled for the Container App Environment"
  type        = bool
  default     = false
}

variable "workload_profiles" {
  description = "Map of workload profiles for dedicated environments"
  type = map(object({
    name                  = string
    workload_profile_type = string
    maximum_count         = number
    minimum_count         = number
  }))
  default = {}

  # Example:
  # {
  #   compute = {
  #     name                  = "Consumption"
  #     workload_profile_type = "Consumption"
  #     maximum_count         = 10
  #     minimum_count         = 0
  #   }
  # }
}

variable "storage_accounts" {
  description = "Map of Azure Files storage accounts to mount"
  type = map(object({
    account_name = string
    share_name   = string
    access_key   = string
    access_mode  = string
  }))
  default = {}
  sensitive = true

  # Example:
  # {
  #   shared_storage = {
  #     account_name = "mystorageaccount"
  #     share_name   = "myshare"
  #     access_key   = "storage-account-key"
  #     access_mode  = "ReadWrite"
  #   }
  # }
}

variable "certificates" {
  description = "Map of SSL certificates for custom domains"
  type = map(object({
    certificate_blob_base64 = string
    certificate_password    = string
  }))
  default   = {}
  sensitive = true

  # Example:
  # {
  #   example_com = {
  #     certificate_blob_base64 = "base64-encoded-pfx-cert"
  #     certificate_password    = "cert-password"
  #   }
  # }
}

variable "dapr_components" {
  description = "Map of Dapr components"
  type = map(object({
    component_type = string
    version        = string
    ignore_errors  = optional(bool, false)
    init_timeout   = optional(string, "5s")
    scopes         = optional(list(string), [])
    metadata = list(object({
      name  = string
      value = string
    }))
    secrets = list(object({
      name  = string
      value = string
    }))
  }))
  default   = {}
  sensitive = true

  # Example:
  # {
  #   statestore = {
  #     component_type = "state.azure.cosmosdb"
  #     version        = "v1"
  #     metadata = [
  #       {
  #         name  = "url"
  #         value = "https://mycosmosdb.documents.azure.com"
  #       }
  #     ]
  #     secrets = [
  #       {
  #         name  = "masterKey"
  #         value = "cosmos-db-key"
  #       }
  #     ]
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

variable "environment_tags" {
  description = "Additional tags specific to the Container App Environment"
  type        = map(string)
  default     = {}
}