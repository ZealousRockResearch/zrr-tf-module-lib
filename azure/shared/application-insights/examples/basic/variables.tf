variable "name" {
  description = "Name of the Application Insights component for the basic example"
  type        = string
  default     = "basic-insights"
}

variable "location" {
  description = "Azure region for the basic example"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Resource group name for the basic example"
  type        = string
  default     = "rg-basic-insights"
}

variable "application_type" {
  description = "Type of application being monitored"
  type        = string
  default     = "web"
}

variable "workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  default     = "law-basic-insights"
}

variable "workspace_resource_group_name" {
  description = "Resource group name of the Log Analytics workspace"
  type        = string
  default     = "rg-basic-insights"
}

variable "environment" {
  description = "Environment for the basic example"
  type        = string
  default     = "dev"
}

variable "criticality" {
  description = "Criticality level for the basic example"
  type        = string
  default     = "medium"
}

variable "retention_in_days" {
  description = "Retention period for Application Insights data"
  type        = number
  default     = 90
}

variable "enable_standard_alerts" {
  description = "Enable standard alert rules"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags for the basic example"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "zrr-example"
    Owner       = "platform-team"
    Purpose     = "monitoring"
  }
}