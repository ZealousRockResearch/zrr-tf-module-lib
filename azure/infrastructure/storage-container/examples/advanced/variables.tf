variable "storage_account_name" {
  description = "Name of the storage account for the advanced example"
  type        = string
  default     = "advancedstorageacct"
}

variable "storage_account_resource_group_name" {
  description = "Resource group name of the storage account"
  type        = string
  default     = "advanced-storage-rg"
}

variable "environment" {
  description = "Environment name for the deployment"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "test", "stage", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, stage, prod."
  }
}

variable "common_tags" {
  description = "Common tags for the advanced example"
  type        = map(string)
  default = {
    Environment = "prod"
    Project     = "enterprise-storage"
    Owner       = "platform-team"
    CostCenter  = "infrastructure"
    Department  = "engineering"
  }
}

# Legal hold configuration
variable "enable_legal_hold" {
  description = "Whether to enable legal hold on the compliance container"
  type        = bool
  default     = false
}

variable "legal_hold_tags" {
  description = "Tags for legal hold (required if enable_legal_hold is true)"
  type        = list(string)
  default     = ["compliance-2024", "regulatory-audit"]

  validation {
    condition     = length(var.legal_hold_tags) <= 10
    error_message = "Legal hold can have maximum 10 tags."
  }
}

# Immutability policy configuration
variable "enable_immutability_policy" {
  description = "Whether to enable immutability policy on the compliance container"
  type        = bool
  default     = false
}

variable "immutability_period_days" {
  description = "Immutability period in days (required if enable_immutability_policy is true)"
  type        = number
  default     = 2555 # 7 years

  validation {
    condition     = var.immutability_period_days >= 1 && var.immutability_period_days <= 146000
    error_message = "Immutability period must be between 1 and 146000 days."
  }
}

variable "immutability_policy_locked" {
  description = "Whether to lock the immutability policy (cannot be changed once locked)"
  type        = bool
  default     = false
}

# Application container configuration
variable "app_container_access_type" {
  description = "Access type for the application data container"
  type        = string
  default     = "private"

  validation {
    condition     = contains(["private", "blob", "container"], var.app_container_access_type)
    error_message = "Container access type must be one of: private, blob, container."
  }
}

variable "enable_app_lifecycle" {
  description = "Whether to enable lifecycle management for application data container"
  type        = bool
  default     = true
}