# Required variables
variable "name" {
  description = "Name of the resource group"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{1,90}$", var.name))
    error_message = "Name must be 1-90 characters long and contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "location" {
  description = "Azure region where the resource group will be created"
  type        = string

  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2", "westus3",
      "centralus", "northcentralus", "southcentralus", "westcentralus",
      "canadacentral", "canadaeast",
      "northeurope", "westeurope", "uksouth", "ukwest",
      "francecentral", "francesouth", "germanywestcentral", "germanynorth",
      "norwayeast", "norwaywest", "switzerlandnorth", "switzerlandwest",
      "australiaeast", "australiasoutheast", "australiacentral",
      "brazilsouth", "brazilsoutheast",
      "centralindia", "southindia", "westindia",
      "japaneast", "japanwest", "koreacentral", "koreasouth",
      "southeastasia", "eastasia",
      "uaenorth", "uaecentral",
      "southafricanorth", "southafricawest"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod", "dr"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod, dr."
  }
}

# Optional variables
variable "location_short" {
  description = "Short abbreviation for the Azure region (e.g., eus for eastus)"
  type        = string
  default     = ""
}

variable "use_naming_convention" {
  description = "Use ZRR naming convention for resource group name"
  type        = bool
  default     = true
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
variable "resource_group_tags" {
  description = "Additional tags specific to the resource group"
  type        = map(string)
  default     = {}
}

# Resource lock variables
variable "enable_resource_lock" {
  description = "Enable resource lock on the resource group"
  type        = bool
  default     = false
}

variable "lock_level" {
  description = "Lock level for the resource group (CanNotDelete or ReadOnly)"
  type        = string
  default     = "CanNotDelete"

  validation {
    condition     = contains(["CanNotDelete", "ReadOnly"], var.lock_level)
    error_message = "Lock level must be either 'CanNotDelete' or 'ReadOnly'."
  }
}

variable "lock_notes" {
  description = "Notes for the resource lock"
  type        = string
  default     = "Resource locked by Terraform to prevent accidental deletion"
}

# Budget alert variables
variable "enable_budget_alert" {
  description = "Enable budget alert for the resource group"
  type        = bool
  default     = false
}

variable "budget_amount" {
  description = "Budget amount in USD"
  type        = number
  default     = 1000

  validation {
    condition     = var.budget_amount > 0
    error_message = "Budget amount must be greater than 0."
  }
}

variable "budget_time_grain" {
  description = "Time grain for the budget (Monthly, Quarterly, Annually)"
  type        = string
  default     = "Monthly"

  validation {
    condition     = contains(["Monthly", "Quarterly", "Annually"], var.budget_time_grain)
    error_message = "Budget time grain must be one of: Monthly, Quarterly, Annually."
  }
}

variable "budget_start_date" {
  description = "Start date for the budget in ISO 8601 format (YYYY-MM-DDTHH:MM:SSZ)"
  type        = string
  default     = ""
}

variable "budget_threshold_percentage" {
  description = "Threshold percentage for budget alert"
  type        = number
  default     = 80

  validation {
    condition     = var.budget_threshold_percentage > 0 && var.budget_threshold_percentage <= 100
    error_message = "Budget threshold percentage must be between 0 and 100."
  }
}

variable "budget_contact_emails" {
  description = "List of email addresses to notify when budget threshold is exceeded"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for email in var.budget_contact_emails : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All contact emails must be valid email addresses."
  }
}