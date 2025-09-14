# Required variables
variable "name" {
  description = "Name of the key vault secret"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,127}$", var.name))
    error_message = "Secret name must be 1-127 characters long and contain only alphanumeric characters and hyphens."
  }
}

variable "value" {
  description = "The value of the key vault secret"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.value) > 0 && length(var.value) <= 25000
    error_message = "Secret value must be between 1 and 25,000 characters."
  }
}

# Key Vault identification (one of these is required)
variable "key_vault_id" {
  description = "ID of the key vault to store the secret in"
  type        = string
  default     = null
}

variable "key_vault_name" {
  description = "Name of the key vault to store the secret in"
  type        = string
  default     = null
}

variable "key_vault_resource_group_name" {
  description = "Resource group name of the key vault (required when using key_vault_name)"
  type        = string
  default     = null

  validation {
    condition     = (var.key_vault_name != null && var.key_vault_resource_group_name != null) || (var.key_vault_name == null && var.key_vault_resource_group_name == null) || var.key_vault_id != null
    error_message = "key_vault_resource_group_name is required when key_vault_name is provided, unless key_vault_id is specified."
  }
}

# Optional variables
variable "content_type" {
  description = "Specifies the content type for the key vault secret"
  type        = string
  default     = null

  validation {
    condition     = var.content_type == null || length(var.content_type) <= 255
    error_message = "Content type must be 255 characters or less."
  }
}

variable "not_before_date" {
  description = "Key not usable before the provided UTC datetime (Y-m-d'T'H:M:S'Z')"
  type        = string
  default     = null

  validation {
    condition     = var.not_before_date == null || can(formatdate("2006-01-02T15:04:05Z", var.not_before_date))
    error_message = "not_before_date must be in RFC3339 format (YYYY-MM-DDTHH:MM:SSZ)."
  }
}

variable "expiration_date" {
  description = "Expiration UTC datetime (Y-m-d'T'H:M:S'Z')"
  type        = string
  default     = null

  validation {
    condition     = var.expiration_date == null || can(formatdate("2006-01-02T15:04:05Z", var.expiration_date))
    error_message = "expiration_date must be in RFC3339 format (YYYY-MM-DDTHH:MM:SSZ)."
  }
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
variable "key_vault_secret_tags" {
  description = "Additional tags specific to the key vault secret"
  type        = map(string)
  default     = {}
}