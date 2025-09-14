# Required variables
variable "name" {
  description = "Name of the Azure App Service Plan"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{1,60}$", var.name))
    error_message = "App Service Plan name must be 1-60 characters long and contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group where the App Service Plan will be created"
  type        = string
}

# Optional location (will use resource group location if not specified)
variable "location" {
  description = "Azure region where the App Service Plan will be created. If not specified, uses the resource group location"
  type        = string
  default     = null
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
variable "application_plan_tags" {
  description = "Additional tags specific to the App Service Plan"
  type        = map(string)
  default     = {}
}

# App Service Plan configuration
variable "os_type" {
  description = "The operating system type for the App Service Plan (Linux or Windows)"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "OS type must be either 'Linux' or 'Windows'."
  }
}

variable "sku_name" {
  description = "The SKU name for the App Service Plan. Examples: B1, B2, B3, S1, S2, S3, P1v2, P2v2, P3v2, P1v3, P2v3, P3v3"
  type        = string
  default     = "B1"

  validation {
    condition     = can(regex("^(F1|D1|B[1-3]|S[1-3]|P[1-3]v[2-3]|I[1-6]|EP[1-3]|WS[1-3]|PC[2-6]|SHARED)$", var.sku_name))
    error_message = "SKU name must be a valid Azure App Service Plan SKU."
  }
}

variable "worker_count" {
  description = "Number of workers (instances) for the App Service Plan"
  type        = number
  default     = null

  validation {
    condition     = var.worker_count == null || (var.worker_count >= 1 && var.worker_count <= 30)
    error_message = "Worker count must be between 1 and 30 when specified."
  }
}

variable "maximum_elastic_worker_count" {
  description = "Maximum number of elastic workers for the App Service Plan (Premium v3 and above)"
  type        = number
  default     = null

  validation {
    condition     = var.maximum_elastic_worker_count == null || (var.maximum_elastic_worker_count >= 1 && var.maximum_elastic_worker_count <= 100)
    error_message = "Maximum elastic worker count must be between 1 and 100 when specified."
  }
}

variable "zone_balancing_enabled" {
  description = "Enable zone balancing for the App Service Plan (requires Premium v2 or Premium v3)"
  type        = bool
  default     = false
}

variable "per_site_scaling_enabled" {
  description = "Enable per-site scaling for the App Service Plan"
  type        = bool
  default     = false
}

# Auto-scaling configuration
variable "enable_autoscaling" {
  description = "Enable auto-scaling for the App Service Plan"
  type        = bool
  default     = false
}

variable "autoscale_settings" {
  description = "Auto-scaling configuration settings"
  type = object({
    default_instances     = number
    minimum_instances     = number
    maximum_instances     = number
    cpu_threshold_out     = number
    cpu_threshold_in      = number
    memory_threshold_out  = optional(number, 80)
    memory_threshold_in   = optional(number, 60)
    enable_memory_scaling = optional(bool, false)
    scale_out_cooldown    = optional(number, 5)
    scale_in_cooldown     = optional(number, 10)
  })
  default = {
    default_instances     = 2
    minimum_instances     = 1
    maximum_instances     = 10
    cpu_threshold_out     = 70
    cpu_threshold_in      = 25
    memory_threshold_out  = 80
    memory_threshold_in   = 60
    enable_memory_scaling = false
    scale_out_cooldown    = 5
    scale_in_cooldown     = 10
  }

  validation {
    condition = (
      var.autoscale_settings.minimum_instances <= var.autoscale_settings.default_instances &&
      var.autoscale_settings.default_instances <= var.autoscale_settings.maximum_instances &&
      var.autoscale_settings.minimum_instances >= 1 &&
      var.autoscale_settings.maximum_instances <= 100
    )
    error_message = "Auto-scale instances must follow: 1 <= minimum <= default <= maximum <= 100."
  }

  validation {
    condition = (
      var.autoscale_settings.cpu_threshold_out > var.autoscale_settings.cpu_threshold_in &&
      var.autoscale_settings.cpu_threshold_out >= 10 &&
      var.autoscale_settings.cpu_threshold_out <= 100 &&
      var.autoscale_settings.cpu_threshold_in >= 5 &&
      var.autoscale_settings.cpu_threshold_in <= 95
    )
    error_message = "CPU thresholds must be valid percentages with scale_out > scale_in."
  }
}

variable "autoscale_notifications" {
  description = "Auto-scaling notification settings"
  type = object({
    send_to_subscription_administrator    = optional(bool, true)
    send_to_subscription_co_administrator = optional(bool, false)
    custom_emails                         = optional(list(string), [])
    webhooks = optional(list(object({
      service_uri = string
      properties  = optional(map(string), {})
    })), [])
  })
  default = {
    send_to_subscription_administrator    = true
    send_to_subscription_co_administrator = false
    custom_emails                         = []
    webhooks                              = []
  }
}

# Monitoring and Diagnostics
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for the App Service Plan"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic settings"
  type        = string
  default     = null
}

variable "diagnostic_log_categories" {
  description = "List of diagnostic log categories to enable"
  type        = list(string)
  default = [
    "AppServicePlatformLogs",
    "AppServiceHTTPLogs",
    "AppServiceConsoleLogs",
    "AppServiceAppLogs",
    "AppServiceFileAuditLogs",
    "AppServiceAuditLogs"
  ]
}

variable "diagnostic_metrics" {
  description = "List of diagnostic metrics to enable"
  type        = list(string)
  default = [
    "AllMetrics"
  ]
}

# Alerting
variable "enable_alerts" {
  description = "Enable monitoring alerts for the App Service Plan"
  type        = bool
  default     = false
}

variable "alert_action_group_name" {
  description = "Name of the action group to send alerts to"
  type        = string
  default     = null
}

variable "alert_action_group_resource_group" {
  description = "Resource group name where the action group is located (defaults to main resource group)"
  type        = string
  default     = null
}

variable "cpu_alert_settings" {
  description = "CPU utilization alert settings"
  type = object({
    enabled       = bool
    threshold     = number
    severity      = optional(number, 2)
    window_size   = optional(number, 5)
    frequency     = optional(number, 1)
    auto_mitigate = optional(bool, true)
  })
  default = {
    enabled       = true
    threshold     = 80
    severity      = 2
    window_size   = 5
    frequency     = 1
    auto_mitigate = true
  }

  validation {
    condition = (
      var.cpu_alert_settings.threshold >= 1 &&
      var.cpu_alert_settings.threshold <= 100 &&
      contains([0, 1, 2, 3, 4], var.cpu_alert_settings.severity)
    )
    error_message = "CPU threshold must be 1-100% and severity must be 0-4."
  }
}

variable "memory_alert_settings" {
  description = "Memory utilization alert settings"
  type = object({
    enabled       = bool
    threshold     = number
    severity      = optional(number, 2)
    window_size   = optional(number, 5)
    frequency     = optional(number, 1)
    auto_mitigate = optional(bool, true)
  })
  default = {
    enabled       = true
    threshold     = 85
    severity      = 2
    window_size   = 5
    frequency     = 1
    auto_mitigate = true
  }

  validation {
    condition = (
      var.memory_alert_settings.threshold >= 1 &&
      var.memory_alert_settings.threshold <= 100 &&
      contains([0, 1, 2, 3, 4], var.memory_alert_settings.severity)
    )
    error_message = "Memory threshold must be 1-100% and severity must be 0-4."
  }
}