variable "resource_group_name" {
  description = "Name of the resource group for the App Service Plan"
  type        = string
  default     = "example-rg"
}

variable "location" {
  description = "Azure region for the App Service Plan"
  type        = string
  default     = "East US"
}

variable "os_type" {
  description = "Operating system type for the App Service Plan"
  type        = string
  default     = "Linux"
}

variable "sku_name" {
  description = "SKU name for the App Service Plan"
  type        = string
  default     = "B1"
}

variable "worker_count" {
  description = "Number of workers (instances) for the App Service Plan"
  type        = number
  default     = null
}

variable "per_site_scaling_enabled" {
  description = "Enable per-site scaling for the App Service Plan"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags for the example"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "zrr-example"
    Owner       = "terraform"
    ManagedBy   = "Terraform"
  }
}

variable "application_plan_tags" {
  description = "Additional tags specific to the App Service Plan"
  type        = map(string)
  default = {
    Purpose = "example"
    Tier    = "basic"
  }
}