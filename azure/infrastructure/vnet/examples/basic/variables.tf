variable "resource_group_name" {
  description = "Name of the resource group for the VNet example"
  type        = string
  default     = "rg-dev-example-eus"
}

variable "environment" {
  description = "Environment for the example"
  type        = string
  default     = "dev"
}

variable "location_short" {
  description = "Short code for the Azure region"
  type        = string
  default     = "eus"
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