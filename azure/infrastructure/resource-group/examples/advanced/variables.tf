# Primary location configuration
variable "location" {
  description = "Primary Azure region for production resources"
  type        = string
  default     = "eastus"
}

variable "location_short" {
  description = "Short code for the primary Azure region"
  type        = string
  default     = "eus"
}

# Disaster recovery location configuration
variable "dr_location" {
  description = "Disaster recovery Azure region"
  type        = string
  default     = "westus2"
}

variable "dr_location_short" {
  description = "Short code for the DR Azure region"
  type        = string
  default     = "wus2"
}

# Budget configuration
variable "budget_amount" {
  description = "Monthly budget amount for production resources (USD)"
  type        = number
  default     = 5000
}

variable "dr_budget_amount" {
  description = "Monthly budget amount for DR resources (USD)"
  type        = number
  default     = 2000
}

variable "budget_contact_emails" {
  description = "Email addresses for budget alert notifications"
  type        = list(string)
  default = [
    "devops@example.com",
    "finance@example.com",
    "platform-team@example.com"
  ]
}

# Tagging configuration
variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Environment   = "prod"
    Project       = "critical-app"
    Owner         = "platform-team"
    ManagedBy     = "Terraform"
    CostCenter    = "engineering"
    BusinessUnit  = "product"
    Contact       = "platform-team@example.com"
    Documentation = "https://wiki.example.com/critical-app"
  }
}

variable "additional_tags" {
  description = "Additional tags for specific requirements"
  type        = map(string)
  default = {
    BackupPolicy        = "daily"
    MonitoringLevel     = "enhanced"
    SLA                 = "99.99"
    ChangeWindow        = "Saturday 2-4am UTC"
    DisasterRecoveryRTO = "4 hours"
    DisasterRecoveryRPO = "1 hour"
  }
}