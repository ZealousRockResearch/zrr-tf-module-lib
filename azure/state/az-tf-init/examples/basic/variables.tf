# Variables for basic Terraform state example

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "example"

  validation {
    condition     = can(regex("^[a-z0-9]{3,12}$", var.project_name))
    error_message = "Project name must be 3-12 characters, lowercase letters and numbers only."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod", "dr"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod, dr."
  }
}

variable "location" {
  description = "Azure region for the Terraform state infrastructure"
  type        = string
  default     = "East US"
}

variable "location_short" {
  description = "Short location code for naming convention"
  type        = string
  default     = "eus"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "terraform-state-example"
    Owner       = "platform-team"
    CostCenter  = "engineering"
    ManagedBy   = "Terraform"
  }
}