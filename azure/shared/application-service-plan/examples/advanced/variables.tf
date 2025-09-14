# Required variables
variable "service_plan_name" {
  description = "Name of the Azure App Service Plan"
  type        = string
  default     = "enterprise-service-plan"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "enterprise-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

# App Service Plan configuration
variable "os_type" {
  description = "Operating system type for the App Service Plan"
  type        = string
  default     = "Linux"
}

variable "sku_name" {
  description = "SKU name for the App Service Plan"
  type        = string
  default     = "P1v3"
}

variable "worker_count" {
  description = "Number of workers (instances) for the App Service Plan"
  type        = number
  default     = 3
}

variable "maximum_elastic_worker_count" {
  description = "Maximum number of elastic workers for the App Service Plan"
  type        = number
  default     = 10
}

variable "zone_balancing_enabled" {
  description = "Enable zone balancing for the App Service Plan"
  type        = bool
  default     = true
}

variable "per_site_scaling_enabled" {
  description = "Enable per-site scaling for the App Service Plan"
  type        = bool
  default     = true
}

# Auto-scaling configuration
variable "enable_autoscaling" {
  description = "Enable auto-scaling for the App Service Plan"
  type        = bool
  default     = true
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
    enable_memory_scaling = optional(bool, true)
    scale_out_cooldown    = optional(number, 5)
    scale_in_cooldown     = optional(number, 10)
  })
  default = {
    default_instances     = 3
    minimum_instances     = 2
    maximum_instances     = 10
    cpu_threshold_out     = 70
    cpu_threshold_in      = 25
    memory_threshold_out  = 80
    memory_threshold_in   = 60
    enable_memory_scaling = true
    scale_out_cooldown    = 5
    scale_in_cooldown     = 10
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
    custom_emails                         = ["ops@company.com"]
    webhooks = [{
      service_uri = "https://alerts.company.com/webhook"
      properties  = { "severity" : "warning" }
    }]
  }
}

# Monitoring and diagnostics
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for the App Service Plan"
  type        = bool
  default     = true
}

variable "create_log_analytics" {
  description = "Create a Log Analytics workspace for monitoring"
  type        = bool
  default     = true
}

variable "existing_log_analytics_workspace_id" {
  description = "ID of existing Log Analytics workspace (if create_log_analytics is false)"
  type        = string
  default     = null
}

variable "log_analytics_retention_days" {
  description = "Log Analytics workspace retention in days"
  type        = number
  default     = 365
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

# Alerting configuration
variable "enable_alerts" {
  description = "Enable monitoring alerts for the App Service Plan"
  type        = bool
  default     = true
}

variable "create_action_group" {
  description = "Create an action group for alerts"
  type        = bool
  default     = true
}

variable "existing_action_group_name" {
  description = "Name of existing action group (if create_action_group is false)"
  type        = string
  default     = null
}

variable "alert_email_receivers" {
  description = "Email receivers for alerts"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = [
    {
      name          = "ops-team"
      email_address = "ops@company.com"
    }
  ]
}

variable "alert_sms_receivers" {
  description = "SMS receivers for alerts"
  type = list(object({
    name         = string
    country_code = string
    phone_number = string
  }))
  default = []
}

variable "alert_webhook_receivers" {
  description = "Webhook receivers for alerts"
  type = list(object({
    name        = string
    service_uri = string
  }))
  default = []
}

variable "alert_function_receivers" {
  description = "Azure Function receivers for alerts"
  type = list(object({
    name                     = string
    function_app_resource_id = string
    function_name            = string
    http_trigger_url         = string
  }))
  default = []
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
}

# Advanced features
variable "create_application_insights" {
  description = "Create Application Insights for the App Service Plan"
  type        = bool
  default     = true
}

variable "application_insights_retention_days" {
  description = "Application Insights data retention in days"
  type        = number
  default     = 90
}

variable "create_diagnostics_storage" {
  description = "Create a storage account for diagnostic logs"
  type        = bool
  default     = true
}

variable "diagnostics_storage_retention_days" {
  description = "Diagnostic storage retention in days"
  type        = number
  default     = 30
}

variable "create_app_service_nsg" {
  description = "Create a Network Security Group for App Service subnet"
  type        = bool
  default     = false
}

# Tags
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "enterprise-app"
    Owner       = "platform-team"
    Criticality = "high"
    ManagedBy   = "Terraform"
  }
}

variable "application_plan_tags" {
  description = "Additional tags specific to the App Service Plan"
  type        = map(string)
  default = {
    Scaling        = "auto"
    Monitoring     = "enhanced"
    Alerts         = "enabled"
    Tier           = "premium"
    ZoneRedundant  = "enabled"
    PerSiteScaling = "enabled"
  }
}