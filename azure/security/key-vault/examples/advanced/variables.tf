# Key Vault Configuration
variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = "advanced-kv-001"
}

variable "location" {
  description = "Azure region for the Key Vault"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group for the Key Vault"
  type        = string
  default     = "advanced-keyvault-rg"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# Network Configuration
variable "vnet_name" {
  description = "Name of the virtual network for private endpoint"
  type        = string
  default     = "example-vnet"
}

variable "vnet_resource_group_name" {
  description = "Resource group containing the virtual network"
  type        = string
  default     = "network-rg"
}

variable "private_endpoint_subnet_name" {
  description = "Name of the subnet for private endpoint"
  type        = string
  default     = "private-endpoints-subnet"
}

variable "private_dns_zone_resource_group_name" {
  description = "Resource group containing the private DNS zone"
  type        = string
  default     = "dns-rg"
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access the Key Vault"
  type        = list(string)
  default     = ["203.0.113.0/24", "198.51.100.0/24"]
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access the Key Vault"
  type        = list(string)
  default     = []
}

# Access Policy Configuration
variable "application_object_id" {
  description = "Object ID of the application that needs access to the Key Vault"
  type        = string
  default     = "00000000-0000-0000-0000-000000000001"
}

variable "backup_service_object_id" {
  description = "Object ID of the backup service that needs access to the Key Vault"
  type        = string
  default     = "00000000-0000-0000-0000-000000000002"
}

# Secrets Configuration
variable "secrets" {
  description = "Map of secrets to create in the Key Vault"
  type = map(object({
    value           = string
    content_type    = optional(string)
    expiration_date = optional(string)
    not_before_date = optional(string)
    tags            = optional(map(string))
  }))
  default = {
    database-connection-string = {
      value        = "Server=prod-sql.database.windows.net;Database=AppDB;Trusted_Connection=True;"
      content_type = "Database Connection String"
      tags = {
        Application = "MainApp"
        Rotation    = "Quarterly"
      }
    }
    api-key-external-service = {
      value           = "sk-1234567890abcdef1234567890abcdef"
      content_type    = "API Key"
      expiration_date = "2025-12-31T23:59:59Z"
      tags = {
        Service  = "ExternalAPI"
        Rotation = "Annual"
      }
    }
    storage-account-key = {
      value        = "DefaultEndpointsProtocol=https;AccountName=storage;AccountKey=key;EndpointSuffix=core.windows.net"
      content_type = "Storage Account Connection String"
      tags = {
        Purpose  = "Application Storage"
        Rotation = "Semi-Annual"
      }
    }
  }
  sensitive = true
}

# Monitoring Configuration
variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace for diagnostics"
  type        = string
  default     = "security-logs-workspace"
}

variable "log_analytics_resource_group_name" {
  description = "Resource group containing the Log Analytics workspace"
  type        = string
  default     = "monitoring-rg"
}

variable "storage_account_name" {
  description = "Name of the storage account for diagnostic logs"
  type        = string
  default     = "securitylogsstorage"
}

variable "storage_account_resource_group_name" {
  description = "Resource group containing the storage account"
  type        = string
  default     = "monitoring-rg"
}

# Contact Information
variable "primary_admin_email" {
  description = "Email address of the primary security administrator"
  type        = string
  default     = "security-admin@company.com"
}

variable "primary_admin_phone" {
  description = "Phone number of the primary security administrator"
  type        = string
  default     = "+1-555-0123"
}

variable "secondary_admin_email" {
  description = "Email address of the secondary security administrator"
  type        = string
  default     = "security-admin-backup@company.com"
}

variable "secondary_admin_phone" {
  description = "Phone number of the secondary security administrator"
  type        = string
  default     = "+1-555-0124"
}

variable "security_team_email" {
  description = "Email address of the security team"
  type        = string
  default     = "security-team@company.com"
}

# Organizational Information
variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "Security"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "Enterprise Security Platform"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment   = "prod"
    Project       = "enterprise-security"
    Owner         = "security-team"
    ManagedBy     = "Terraform"
    BusinessUnit  = "IT Security"
    CriticalLevel = "High"
  }
}