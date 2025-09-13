variable "location" {
  description = "Azure region for the example"
  type        = string
  default     = "eastus"
}

variable "location_short" {
  description = "Short code for the Azure region"
  type        = string
  default     = "eus"
}

variable "environment" {
  description = "Environment for the example"
  type        = string
  default     = "dev"
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