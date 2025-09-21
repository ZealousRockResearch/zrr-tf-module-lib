# Required variables
variable "name" {
  description = "Name of the Application Insights component"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,258}[a-zA-Z0-9]$", var.name)) && length(var.name) >= 1 && length(var.name) <= 260
    error_message = "Name must be 1-260 characters long, start and end with alphanumeric characters, and contain only letters, numbers, hyphens, and underscores."
  }
}

variable "location" {
  description = "Azure region where the Application Insights component will be created"
  type        = string

  validation {
    condition = contains([
      "eastus", "eastus2", "southcentralus", "westus2", "westus3", "australiaeast",
      "southeastasia", "northeurope", "swedencentral", "uksouth", "westeurope",
      "centralus", "southafricanorth", "centralindia", "eastasia", "japaneast",
      "koreacentral", "canadacentral", "francecentral", "germanywestcentral",
      "norwayeast", "switzerlandnorth", "uaenorth", "brazilsouth", "eastus2euap",
      "qatarcentral", "centralusstage", "eastusstage", "eastus2stage", "northcentralusstage",
      "southcentralusstage", "westusstage", "westus2stage", "asia", "asiapacific",
      "australia", "brazil", "canada", "europe", "france", "germany", "global",
      "india", "japan", "korea", "norway", "singapore", "southafrica",
      "switzerland", "uae", "uk", "unitedstates", "eastasiastage", "southeastasiastage",
      "northcentralus", "westus", "westcentralus"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group where the Application Insights component will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_.()]{0,88}[a-zA-Z0-9_]$", var.resource_group_name))
    error_message = "Resource group name must be 1-90 characters long and can contain alphanumeric characters, periods, underscores, hyphens, and parentheses."
  }
}

variable "application_type" {
  description = "Type of application being monitored"
  type        = string
  default     = "web"

  validation {
    condition     = contains(["web", "other", "java", "ios", "android", "mobile", "desktop"], var.application_type)
    error_message = "Application type must be one of: web, other, java, ios, android, mobile, desktop."
  }
}

# Workspace configuration
variable "workspace_id" {
  description = "ID of the Log Analytics workspace to associate with Application Insights"
  type        = string
  default     = null

  validation {
    condition     = var.workspace_id == null || can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[^/]+/providers/Microsoft.OperationalInsights/workspaces/[^/]+$", var.workspace_id))
    error_message = "Workspace ID must be a valid Log Analytics workspace resource ID or null."
  }
}

variable "workspace_name" {
  description = "Name of the Log Analytics workspace (alternative to workspace_id)"
  type        = string
  default     = null

  validation {
    condition     = var.workspace_name == null || can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{2,61}[a-zA-Z0-9]$", var.workspace_name))
    error_message = "Workspace name must be 4-63 characters long and contain only letters, numbers, and hyphens."
  }
}

variable "workspace_resource_group_name" {
  description = "Resource group name of the Log Analytics workspace (required if workspace_name is specified)"
  type        = string
  default     = null

  validation {
    condition     = (var.workspace_name == null && var.workspace_resource_group_name == null) || (var.workspace_name != null && var.workspace_resource_group_name != null)
    error_message = "workspace_resource_group_name is required when workspace_name is specified."
  }
}

# Environment and criticality
variable "environment" {
  description = "Environment where the Application Insights component is deployed"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

variable "criticality" {
  description = "Criticality level of the Application Insights component"
  type        = string
  default     = "medium"

  validation {
    condition     = contains(["low", "medium", "high", "critical"], var.criticality)
    error_message = "Criticality must be one of: low, medium, high, critical."
  }
}

# Data management
variable "retention_in_days" {
  description = "Retention period in days for Application Insights data"
  type        = number
  default     = 90

  validation {
    condition     = contains([30, 60, 90, 120, 180, 270, 365, 550, 730], var.retention_in_days)
    error_message = "Retention period must be one of: 30, 60, 90, 120, 180, 270, 365, 550, 730 days."
  }
}

variable "daily_data_cap_gb" {
  description = "Daily data volume cap in GB (null for automatic based on criticality)"
  type        = number
  default     = null

  validation {
    condition     = var.daily_data_cap_gb == null || (var.daily_data_cap_gb >= 0.023 && var.daily_data_cap_gb <= 1000)
    error_message = "Daily data cap must be between 0.023 GB and 1000 GB or null for automatic calculation."
  }
}

variable "daily_data_cap_notifications_disabled" {
  description = "Disable notifications when daily data cap is reached"
  type        = bool
  default     = false
}

variable "sampling_percentage" {
  description = "Percentage of telemetry to sample (null for automatic based on criticality)"
  type        = number
  default     = null

  validation {
    condition     = var.sampling_percentage == null || (var.sampling_percentage >= 0.1 && var.sampling_percentage <= 100)
    error_message = "Sampling percentage must be between 0.1 and 100 or null for automatic calculation."
  }
}

# Security and access
variable "disable_ip_masking" {
  description = "Disable IP address masking in telemetry"
  type        = bool
  default     = false
}

variable "local_authentication_disabled" {
  description = "Disable local authentication for Application Insights access"
  type        = bool
  default     = true
}

variable "internet_ingestion_enabled" {
  description = "Enable internet ingestion for Application Insights"
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Enable internet query for Application Insights"
  type        = bool
  default     = true
}

variable "force_customer_storage_for_profiler" {
  description = "Force customer storage for Application Insights Profiler"
  type        = bool
  default     = false
}

# Web tests for availability monitoring
variable "web_tests" {
  description = "Configuration for Application Insights web tests"
  type = map(object({
    kind          = string
    frequency     = number
    timeout       = number
    enabled       = bool
    retry_enabled = bool
    geo_locations = list(string)
    description   = string
    configuration = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for test in var.web_tests : contains(["ping", "multistep"], test.kind)
    ])
    error_message = "Web test kind must be either 'ping' or 'multistep'."
  }

  validation {
    condition = alltrue([
      for test in var.web_tests : contains([300, 600, 900], test.frequency)
    ])
    error_message = "Web test frequency must be 300, 600, or 900 seconds."
  }

  validation {
    condition = alltrue([
      for test in var.web_tests : test.timeout >= 30 && test.timeout <= 120
    ])
    error_message = "Web test timeout must be between 30 and 120 seconds."
  }
}

# Alert configuration
variable "enable_standard_alerts" {
  description = "Enable standard Application Insights alert rules"
  type        = bool
  default     = true
}

variable "alert_severity" {
  description = "Severity level for standard alerts"
  type        = number
  default     = 2

  validation {
    condition     = var.alert_severity >= 0 && var.alert_severity <= 4
    error_message = "Alert severity must be between 0 (Critical) and 4 (Verbose)."
  }
}

variable "server_response_time_threshold" {
  description = "Threshold for server response time alert (in milliseconds)"
  type        = number
  default     = 5000

  validation {
    condition     = var.server_response_time_threshold > 0
    error_message = "Server response time threshold must be greater than 0."
  }
}

variable "failure_rate_threshold" {
  description = "Threshold for failure rate alert (count)"
  type        = number
  default     = 10

  validation {
    condition     = var.failure_rate_threshold > 0
    error_message = "Failure rate threshold must be greater than 0."
  }
}

variable "exception_rate_threshold" {
  description = "Threshold for exception rate alert (count)"
  type        = number
  default     = 5

  validation {
    condition     = var.exception_rate_threshold > 0
    error_message = "Exception rate threshold must be greater than 0."
  }
}

variable "action_group_ids" {
  description = "List of action group IDs for alert notifications"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for id in var.action_group_ids : can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[^/]+/providers/Microsoft.Insights/actionGroups/[^/]+$", id))
    ])
    error_message = "All action group IDs must be valid Azure resource IDs."
  }
}

# Custom alerts
variable "custom_alerts" {
  description = "Configuration for custom Application Insights alerts"
  type = map(object({
    description      = string
    severity         = number
    frequency        = string
    window_size      = string
    enabled          = bool
    metric_namespace = string
    metric_name      = string
    aggregation      = string
    operator         = string
    threshold        = number
    dimensions = list(object({
      name     = string
      operator = string
      values   = list(string)
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for alert in var.custom_alerts : alert.severity >= 0 && alert.severity <= 4
    ])
    error_message = "Alert severity must be between 0 (Critical) and 4 (Verbose)."
  }

  validation {
    condition = alltrue([
      for alert in var.custom_alerts : contains(["Average", "Count", "Maximum", "Minimum", "Total"], alert.aggregation)
    ])
    error_message = "Alert aggregation must be one of: Average, Count, Maximum, Minimum, Total."
  }

  validation {
    condition = alltrue([
      for alert in var.custom_alerts : contains(["Equals", "NotEquals", "GreaterThan", "GreaterThanOrEqual", "LessThan", "LessThanOrEqual"], alert.operator)
    ])
    error_message = "Alert operator must be one of: Equals, NotEquals, GreaterThan, GreaterThanOrEqual, LessThan, LessThanOrEqual."
  }
}

# Smart detection rules
variable "smart_detection_rules" {
  description = "Configuration for Application Insights smart detection rules"
  type = map(object({
    enabled                            = bool
    send_emails_to_subscription_owners = bool
    additional_email_recipients        = list(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for rule in var.smart_detection_rules : alltrue([
        for email in rule.additional_email_recipients : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
      ])
    ])
    error_message = "All additional email recipients must be valid email addresses."
  }
}

# Analytics items
variable "analytics_items" {
  description = "Configuration for Application Insights analytics items (queries, functions)"
  type = map(object({
    type           = string
    scope          = string
    content        = string
    function_alias = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for item in var.analytics_items : contains(["query", "function"], item.type)
    ])
    error_message = "Analytics item type must be either 'query' or 'function'."
  }

  validation {
    condition = alltrue([
      for item in var.analytics_items : contains(["shared", "user"], item.scope)
    ])
    error_message = "Analytics item scope must be either 'shared' or 'user'."
  }
}

# API keys
variable "api_keys" {
  description = "Configuration for Application Insights API keys"
  type = map(object({
    read_permissions  = list(string)
    write_permissions = list(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for key in var.api_keys : alltrue([
        for perm in key.read_permissions : contains(["aggregate", "api", "draft", "extendqueries", "search"], perm)
      ])
    ])
    error_message = "Read permissions must be from: aggregate, api, draft, extendqueries, search."
  }

  validation {
    condition = alltrue([
      for key in var.api_keys : alltrue([
        for perm in key.write_permissions : contains(["annotations"], perm)
      ])
    ])
    error_message = "Write permissions must be from: annotations."
  }
}

# Workbook templates
variable "workbook_templates" {
  description = "Configuration for Application Insights workbook templates"
  type = map(object({
    author           = string
    priority         = number
    template_items   = list(any)
    gallery_category = string
    gallery_name     = string
    gallery_order    = number
  }))
  default = {}

  validation {
    condition = alltrue([
      for template in var.workbook_templates : template.priority >= 1 && template.priority <= 10
    ])
    error_message = "Workbook template priority must be between 1 and 10."
  }
}

# Continuous export
variable "enable_continuous_export" {
  description = "Enable continuous export of Application Insights data"
  type        = bool
  default     = false
}

variable "continuous_export_config" {
  description = "Configuration for continuous export"
  type = object({
    destination_type   = string
    destination_config = map(string)
    export_types       = list(string)
  })
  default = {
    destination_type   = "storage"
    destination_config = {}
    export_types       = ["Request", "Exception", "CustomEvent"]
  }
}

# Enterprise governance
variable "compliance_requirements" {
  description = "List of compliance frameworks that apply to this Application Insights component"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for req in var.compliance_requirements : contains([
        "SOX", "PCI-DSS", "HIPAA", "ISO27001", "SOC2", "GDPR", "CCPA", "FedRAMP"
      ], req)
    ])
    error_message = "Compliance requirements must be from the supported list: SOX, PCI-DSS, HIPAA, ISO27001, SOC2, GDPR, CCPA, FedRAMP."
  }
}

variable "data_governance" {
  description = "Data governance configuration for Application Insights"
  type = object({
    data_classification   = string
    data_retention_policy = string
    pii_detection_enabled = bool
    data_masking_enabled  = bool
  })
  default = {
    data_classification   = "internal"
    data_retention_policy = "standard"
    pii_detection_enabled = true
    data_masking_enabled  = true
  }

  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.data_governance.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }

  validation {
    condition     = contains(["minimal", "standard", "extended", "maximum"], var.data_governance.data_retention_policy)
    error_message = "Data retention policy must be one of: minimal, standard, extended, maximum."
  }
}

# Tags
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

variable "application_insights_tags" {
  description = "Additional tags specific to the Application Insights component"
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for key, value in var.application_insights_tags :
      length(key) <= 512 && length(value) <= 256
    ])
    error_message = "Tag keys must be 512 characters or less, and tag values must be 256 characters or less."
  }
}