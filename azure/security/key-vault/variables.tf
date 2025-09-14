# Required variables
variable "name" {
  description = "Name of the Key Vault"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.name))
    error_message = "Key Vault name must be 3-24 characters long and contain only alphanumeric characters and hyphens."
  }
}

variable "location" {
  description = "Azure region where the Key Vault will be created"
  type        = string
  default     = "East US"

  validation {
    condition = contains([
      "East US", "East US 2", "West US", "West US 2", "West US 3",
      "Central US", "North Central US", "South Central US", "West Central US",
      "Canada Central", "Canada East", "Brazil South", "North Europe", "West Europe",
      "UK South", "UK West", "France Central", "Germany West Central",
      "Switzerland North", "Norway East", "Sweden Central", "Poland Central",
      "Italy North", "Spain Central", "Australia East", "Australia Southeast",
      "Australia Central", "Japan East", "Japan West", "Korea Central", "Korea South",
      "Southeast Asia", "East Asia", "Central India", "South India", "West India",
      "UAE North", "South Africa North"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

# Resource Group
variable "resource_group_name" {
  description = "Name of the resource group. If not provided, a new resource group will be created"
  type        = string
  default     = null
}

# Key Vault Configuration
variable "sku_name" {
  description = "The Name of the SKU used for this Key Vault. Possible values are standard and premium"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU name must be either 'standard' or 'premium'."
  }
}

variable "enabled_for_disk_encryption" {
  description = "Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys"
  type        = bool
  default     = false
}

variable "enabled_for_deployment" {
  description = "Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault"
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions"
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = "Is Purge Protection enabled for this Key Vault?"
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 days"
  type        = number
  default     = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Soft delete retention days must be between 7 and 90."
  }
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for this Key Vault"
  type        = bool
  default     = true
}

# Network ACLs
variable "network_acls" {
  description = "Network ACLs configuration for the Key Vault"
  type = object({
    default_action             = string
    bypass                     = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = null

  validation {
    condition = var.network_acls == null || (
      var.network_acls != null &&
      contains(["Allow", "Deny"], var.network_acls.default_action) &&
      contains(["AzureServices", "None"], var.network_acls.bypass)
    )
    error_message = "Network ACLs default_action must be 'Allow' or 'Deny', and bypass must be 'AzureServices' or 'None'."
  }
}

# Access Policies
variable "access_policies" {
  description = "Map of access policies for the Key Vault"
  type = map(object({
    object_id               = string
    key_permissions         = list(string)
    secret_permissions      = list(string)
    certificate_permissions = list(string)
  }))
  default = {}
}

# Secrets
variable "secrets" {
  description = "Map of secrets to create in the Key Vault"
  type = map(object({
    value           = string
    content_type    = optional(string)
    expiration_date = optional(string)
    not_before_date = optional(string)
    tags            = optional(map(string))
  }))
  default = {}
}

# Keys
variable "keys" {
  description = "Map of keys to create in the Key Vault"
  type = map(object({
    key_type        = string
    key_size        = optional(number)
    curve           = optional(string)
    key_opts        = list(string)
    expiration_date = optional(string)
    not_before_date = optional(string)
    tags            = optional(map(string))
  }))
  default = {}
}

# Certificate Contacts
variable "certificate_contacts" {
  description = "List of certificate contacts for the Key Vault"
  type = list(object({
    email = string
    name  = optional(string)
    phone = optional(string)
  }))
  default = []
}

# Private Endpoint
variable "private_endpoint" {
  description = "Private endpoint configuration for the Key Vault"
  type = object({
    subnet_id            = string
    private_dns_zone_ids = optional(list(string))
  })
  default = null
}

# Diagnostic Settings
variable "diagnostic_setting" {
  description = "Diagnostic setting configuration for the Key Vault"
  type = object({
    log_analytics_workspace_id = optional(string)
    storage_account_id         = optional(string)
    log_categories             = list(string)
    metric_categories          = list(string)
  })
  default = null
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
variable "key_vault_tags" {
  description = "Additional tags specific to the Key Vault"
  type        = map(string)
  default     = {}
}