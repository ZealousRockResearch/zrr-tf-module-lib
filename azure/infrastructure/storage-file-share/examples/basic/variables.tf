variable "file_share_name" {
  description = "Name of the file share to create"
  type        = string
  default     = "example-share"
}

variable "storage_account_name" {
  description = "Name of the existing storage account"
  type        = string
  # This should be set when running the example
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  # This should be set when running the example
}

variable "location" {
  description = "Azure region for the file share"
  type        = string
  default     = "East US"
}

variable "quota_gb" {
  description = "Quota for the file share in GB"
  type        = number
  default     = 100
}

variable "access_tier" {
  description = "Access tier for the file share"
  type        = string
  default     = "Hot"
}

variable "enable_backup" {
  description = "Enable backup for the file share"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags for the example"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "zrr-example"
    Owner       = "terraform"
  }
}

variable "file_share_tags" {
  description = "Additional tags for the file share"
  type        = map(string)
  default = {
    Purpose = "example"
  }
}