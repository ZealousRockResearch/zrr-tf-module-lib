# Variables for advanced enterprise Terraform state example

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "enterprise"

  validation {
    condition     = can(regex("^[a-z0-9]{3,12}$", var.project_name))
    error_message = "Project name must be 3-12 characters, lowercase letters and numbers only."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"

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

# Network security variables
variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for accessing state infrastructure"
  type        = list(string)
  default     = ["203.0.113.0/24"] # Example IP range - replace with your organization's IPs
}

# RBAC assignment variables
variable "terraform_contributors" {
  description = "List of user/service principal object IDs that should have contributor access to Terraform state"
  type        = list(string)
  default     = []
  # Example: ["12345678-1234-1234-1234-123456789012"]
}

variable "terraform_readers" {
  description = "List of user/service principal object IDs that should have read access to Terraform state"
  type        = list(string)
  default     = []
  # Example: ["87654321-4321-4321-4321-210987654321"]
}

variable "terraform_admins" {
  description = "List of user/service principal object IDs that should have admin access to Key Vault"
  type        = list(string)
  default     = []
  # Example: ["11111111-1111-1111-1111-111111111111"]
}

variable "terraform_users" {
  description = "List of user/service principal object IDs that should have user access to Key Vault"
  type        = list(string)
  default     = []
  # Example: ["22222222-2222-2222-2222-222222222222"]
}

# Automation configuration
variable "create_automation_identity" {
  description = "Create a managed identity for CI/CD automation"
  type        = bool
  default     = true
}

# Tagging strategy
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment     = "prod"
    Project         = "enterprise-terraform-state"
    Owner           = "platform-team"
    CostCenter      = "platform"
    BusinessUnit    = "engineering"
    ManagedBy       = "Terraform"
    Compliance      = "required"
    DataClass       = "confidential"
    BackupRequired  = "yes"
    MonitoringLevel = "enhanced"
    SecurityLevel   = "high"
  }
}