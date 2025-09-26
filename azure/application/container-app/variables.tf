variable "name" {
  description = "The name of the Container App"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,30}[a-z0-9]$", var.name))
    error_message = "Container App name must be 2-32 characters, start with a letter, end with alphanumeric, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "container_app_environment_id" {
  description = "The ID of the Container App Environment"
  type        = string
}

variable "revision_mode" {
  description = "The revision mode of the Container App"
  type        = string
  default     = "Single"

  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "Revision mode must be Single or Multiple."
  }
}

variable "workload_profile_name" {
  description = "The name of the workload profile"
  type        = string
  default     = null
}

# Container configuration
variable "containers" {
  description = "List of containers"
  type = list(object({
    name    = string
    image   = string
    cpu     = number
    memory  = string
    args    = optional(list(string), [])
    command = optional(list(string), [])

    env = optional(list(object({
      name        = string
      value       = optional(string)
      secret_name = optional(string)
    })), [])

    volume_mounts = optional(list(object({
      name = string
      path = string
    })), [])

    liveness_probe = optional(object({
      transport                   = string
      port                       = number
      path                       = optional(string)
      host                       = optional(string)
      interval_seconds           = optional(number, 10)
      timeout                    = optional(number, 1)
      failure_count_threshold    = optional(number, 3)
      success_count_threshold    = optional(number, 1)
      initial_delay              = optional(number, 0)
      headers = optional(list(object({
        name  = string
        value = string
      })), [])
    }))

    readiness_probe = optional(object({
      transport                   = string
      port                       = number
      path                       = optional(string)
      host                       = optional(string)
      interval_seconds           = optional(number, 10)
      timeout                    = optional(number, 1)
      failure_count_threshold    = optional(number, 3)
      success_count_threshold    = optional(number, 1)
      headers = optional(list(object({
        name  = string
        value = string
      })), [])
    }))

    startup_probe = optional(object({
      transport                   = string
      port                       = number
      path                       = optional(string)
      host                       = optional(string)
      interval_seconds           = optional(number, 10)
      timeout                    = optional(number, 1)
      failure_count_threshold    = optional(number, 3)
      headers = optional(list(object({
        name  = string
        value = string
      })), [])
    }))
  }))
}

variable "init_containers" {
  description = "List of init containers"
  type = list(object({
    name    = string
    image   = string
    cpu     = optional(number, 0.25)
    memory  = optional(string, "0.5Gi")
    args    = optional(list(string), [])
    command = optional(list(string), [])

    env = optional(list(object({
      name        = string
      value       = optional(string)
      secret_name = optional(string)
    })), [])

    volume_mounts = optional(list(object({
      name = string
      path = string
    })), [])
  }))
  default = []
}

variable "volumes" {
  description = "List of volumes"
  type = list(object({
    name         = string
    storage_type = string
    storage_name = optional(string)
  }))
  default = []

  # Example:
  # [
  #   {
  #     name         = "cache-volume"
  #     storage_type = "EmptyDir"
  #   },
  #   {
  #     name         = "azure-files-volume"
  #     storage_type = "AzureFile"
  #     storage_name = "my-azure-files"
  #   }
  # ]
}

# Scaling configuration
variable "min_replicas" {
  description = "The minimum number of replicas"
  type        = number
  default     = 0

  validation {
    condition     = var.min_replicas >= 0 && var.min_replicas <= 1000
    error_message = "Min replicas must be between 0 and 1000."
  }
}

variable "max_replicas" {
  description = "The maximum number of replicas"
  type        = number
  default     = 10

  validation {
    condition     = var.max_replicas >= 1 && var.max_replicas <= 1000
    error_message = "Max replicas must be between 1 and 1000."
  }
}

variable "http_scale_rules" {
  description = "List of HTTP scaling rules"
  type = list(object({
    name                = string
    concurrent_requests = number
  }))
  default = []
}


variable "revision_suffix" {
  description = "The revision suffix"
  type        = string
  default     = null
}

# Ingress configuration
variable "ingress" {
  description = "Ingress configuration"
  type = object({
    allow_insecure_connections = optional(bool, false)
    external_enabled          = optional(bool, true)
    target_port               = number
    exposed_port              = optional(number)
    transport                 = optional(string, "auto")

    traffic_weight = list(object({
      percentage      = number
      latest_revision = optional(bool, true)
      revision_suffix = optional(string)
      label           = optional(string)
    }))

    custom_domains = optional(list(object({
      name           = string
      binding_type   = optional(string, "Disabled")
      certificate_id = optional(string)
    })), [])

    ip_security_restrictions = optional(list(object({
      name             = string
      ip_address_range = string
      action           = string
      description      = optional(string)
    })), [])
  })
  default = null
}

# Dapr configuration
variable "dapr" {
  description = "Dapr configuration"
  type = object({
    app_id       = string
    app_port     = optional(number)
    app_protocol = optional(string, "http")
  })
  default = null
}

# Secrets
variable "secrets" {
  description = "List of secrets"
  type = list(object({
    name                = string
    value               = optional(string)
    identity            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default   = []
  sensitive = true
}

# Container Registry configuration
variable "container_registry_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = null
}

variable "container_registry_resource_group" {
  description = "Resource group name of the Azure Container Registry"
  type        = string
  default     = null
}

variable "container_registry_username" {
  description = "Username for container registry authentication"
  type        = string
  default     = null
  sensitive   = true
}

variable "container_registry_password_secret_name" {
  description = "Name of the secret containing the container registry password"
  type        = string
  default     = "acr-password"
}

variable "container_registry_identity" {
  description = "Identity for container registry authentication"
  type        = string
  default     = null
}

variable "additional_registries" {
  description = "List of additional container registries"
  type = list(object({
    server               = string
    username             = string
    password_secret_name = string
    identity             = optional(string)
  }))
  default   = []
  sensitive = true
}

# Identity
variable "identity_type" {
  description = "The type of identity to use (SystemAssigned, UserAssigned)"
  type        = string
  default     = null

  validation {
    condition = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Identity type must be SystemAssigned, UserAssigned, or 'SystemAssigned, UserAssigned'."
  }
}

variable "identity_ids" {
  description = "List of user assigned identity IDs"
  type        = list(string)
  default     = null
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

variable "container_app_tags" {
  description = "Additional tags specific to the Container App"
  type        = map(string)
  default     = {}
}