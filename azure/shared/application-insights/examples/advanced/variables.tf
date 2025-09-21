variable "name" {
  description = "Name of the Application Insights component for the advanced example"
  type        = string
  default     = "enterprise-insights"
}

variable "location" {
  description = "Azure region for the advanced example"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Resource group name for the advanced example"
  type        = string
  default     = "rg-enterprise-insights"
}

variable "application_type" {
  description = "Type of application being monitored"
  type        = string
  default     = "web"
}

variable "workspace_id" {
  description = "ID of the Log Analytics workspace"
  type        = string
  default     = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-enterprise-insights/providers/Microsoft.OperationalInsights/workspaces/law-enterprise"
}

variable "environment" {
  description = "Environment for the advanced example"
  type        = string
  default     = "prod"
}

variable "criticality" {
  description = "Criticality level for the advanced example"
  type        = string
  default     = "critical"
}

# Data management variables
variable "retention_in_days" {
  description = "Retention period for Application Insights data"
  type        = number
  default     = 730
}

variable "daily_data_cap_gb" {
  description = "Daily data volume cap in GB"
  type        = number
  default     = 10
}

variable "daily_data_cap_notifications_disabled" {
  description = "Disable notifications when daily data cap is reached"
  type        = bool
  default     = false
}

variable "sampling_percentage" {
  description = "Percentage of telemetry to sample"
  type        = number
  default     = 100
}

# Security variables
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

# Alert configuration variables
variable "enable_standard_alerts" {
  description = "Enable standard Application Insights alert rules"
  type        = bool
  default     = true
}

variable "alert_severity" {
  description = "Severity level for standard alerts"
  type        = number
  default     = 1
}

variable "server_response_time_threshold" {
  description = "Threshold for server response time alert (in milliseconds)"
  type        = number
  default     = 3000
}

variable "failure_rate_threshold" {
  description = "Threshold for failure rate alert (count)"
  type        = number
  default     = 5
}

variable "exception_rate_threshold" {
  description = "Threshold for exception rate alert (count)"
  type        = number
  default     = 3
}

variable "action_group_ids" {
  description = "List of action group IDs for alert notifications"
  type        = list(string)
  default = [
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-monitoring/providers/Microsoft.Insights/actionGroups/ag-enterprise-alerts"
  ]
}

# Web tests configuration
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
  default = {
    homepage = {
      kind          = "ping"
      frequency     = 300
      timeout       = 30
      enabled       = true
      retry_enabled = true
      geo_locations = ["us-il-ch1-azr", "us-ca-sjc-azr", "us-va-ash-azr"]
      description   = "Homepage availability test"
      configuration = <<-EOT
        <WebTest Name="Homepage Test" Id="12345678-1234-1234-1234-123456789012" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="30" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="Test homepage availability" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="">
          <Items>
            <Request Method="GET" Guid="a5f10126-e4cd-570d-961c-cea43999a200" Version="1.1" Url="https://example.com" ThinkTime="0" Timeout="30" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
          </Items>
        </WebTest>
      EOT
    }
    api_health = {
      kind          = "ping"
      frequency     = 300
      timeout       = 30
      enabled       = true
      retry_enabled = true
      geo_locations = ["us-il-ch1-azr", "us-ca-sjc-azr"]
      description   = "API health check"
      configuration = <<-EOT
        <WebTest Name="API Health Test" Id="87654321-4321-4321-4321-210987654321" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="30" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="Test API health endpoint" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="">
          <Items>
            <Request Method="GET" Guid="b6f20237-f5de-681e-072e-dfb54aaa311" Version="1.1" Url="https://api.example.com/health" ThinkTime="0" Timeout="30" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
          </Items>
        </WebTest>
      EOT
    }
  }
}

# Custom alerts configuration
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
  default = {
    high_cpu_usage = {
      description      = "High CPU usage alert for application performance"
      severity         = 1
      frequency        = "PT1M"
      window_size      = "PT5M"
      enabled          = true
      metric_namespace = "Microsoft.Insights/components"
      metric_name      = "performanceCounters/processCpuPercentage"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 80
      dimensions       = []
    }
    memory_usage = {
      description      = "High memory usage alert"
      severity         = 2
      frequency        = "PT5M"
      window_size      = "PT10M"
      enabled          = true
      metric_namespace = "Microsoft.Insights/components"
      metric_name      = "performanceCounters/memoryAvailableBytes"
      aggregation      = "Average"
      operator         = "LessThan"
      threshold        = 1073741824 # 1GB in bytes
      dimensions       = []
    }
  }
}

# Smart detection configuration
variable "smart_detection_rules" {
  description = "Configuration for Application Insights smart detection rules"
  type = map(object({
    enabled                            = bool
    send_emails_to_subscription_owners = bool
    additional_email_recipients        = list(string)
  }))
  default = {
    "Slow page load time" = {
      enabled                            = true
      send_emails_to_subscription_owners = false
      additional_email_recipients        = ["ops-team@company.com", "dev-team@company.com"]
    }
    "Slow server response time" = {
      enabled                            = true
      send_emails_to_subscription_owners = false
      additional_email_recipients        = ["platform-team@company.com"]
    }
    "Degradation in server response time" = {
      enabled                            = true
      send_emails_to_subscription_owners = false
      additional_email_recipients        = ["sre-team@company.com"]
    }
  }
}

# Analytics items configuration
variable "analytics_items" {
  description = "Configuration for Application Insights analytics items"
  type = map(object({
    type           = string
    scope          = string
    content        = string
    function_alias = string
  }))
  default = {
    error_analysis = {
      type           = "query"
      scope          = "shared"
      content        = "exceptions | where timestamp > ago(24h) | summarize count() by type, outerMessage | order by count_ desc"
      function_alias = ""
    }
    performance_overview = {
      type           = "query"
      scope          = "shared"
      content        = "requests | where timestamp > ago(1h) | summarize avg(duration), percentile(duration, 95) by bin(timestamp, 5m) | render timechart"
      function_alias = ""
    }
    get_error_rate = {
      type           = "function"
      scope          = "shared"
      content        = "requests | where timestamp > ago(timespan) | summarize total = count(), errors = countif(success == false) | extend error_rate = todouble(errors) / todouble(total) * 100"
      function_alias = "GetErrorRate"
    }
  }
}

# API keys configuration
variable "api_keys" {
  description = "Configuration for Application Insights API keys"
  type = map(object({
    read_permissions  = list(string)
    write_permissions = list(string)
  }))
  default = {
    monitoring_service = {
      read_permissions  = ["aggregate", "api", "search"]
      write_permissions = ["annotations"]
    }
    external_dashboard = {
      read_permissions  = ["api", "search"]
      write_permissions = []
    }
  }
}

# Workbook templates configuration
variable "workbook_templates" {
  description = "Configuration for Application Insights workbook templates"
  type = map(object({
    author           = string
    description      = string
    priority         = number
    template_items   = list(any)
    gallery_category = string
    gallery_name     = string
    gallery_order    = number
  }))
  default = {
    performance_dashboard = {
      author           = "Platform Team"
      description      = "Enterprise performance monitoring dashboard"
      priority         = 1
      gallery_category = "Application Insights"
      gallery_name     = "Performance Monitoring"
      gallery_order    = 1
      template_items = [
        {
          type = "1"
          content = {
            json = "{\"version\":\"KqlItem/1.0\",\"query\":\"requests | summarize count() by bin(timestamp, 5m) | render timechart\",\"size\":0,\"title\":\"Request Volume Over Time\"}"
          }
        }
      ]
    }
  }
}

# Continuous export configuration
variable "enable_continuous_export" {
  description = "Enable continuous export of Application Insights data"
  type        = bool
  default     = true
}

variable "continuous_export_config" {
  description = "Configuration for continuous export"
  type = object({
    destination_type   = string
    destination_config = map(string)
    export_types       = list(string)
  })
  default = {
    destination_type = "storage"
    destination_config = {
      storage_account_name = "enterpriseexportstorage"
      container_name       = "applicationinsights"
    }
    export_types = ["Request", "Exception", "CustomEvent", "Trace", "Dependency"]
  }
}

# Enterprise governance
variable "compliance_requirements" {
  description = "List of compliance frameworks that apply to this Application Insights component"
  type        = list(string)
  default     = ["SOX", "PCI-DSS", "ISO27001", "GDPR", "HIPAA"]
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
    data_classification   = "confidential"
    data_retention_policy = "extended"
    pii_detection_enabled = true
    data_masking_enabled  = true
  }
}

# Tags
variable "common_tags" {
  description = "Common tags for the advanced example"
  type        = map(string)
  default = {
    Environment  = "prod"
    Project      = "enterprise-platform"
    Owner        = "platform-team"
    CostCenter   = "engineering"
    BusinessUnit = "technology"
    DataClass    = "confidential"
    Compliance   = "required"
    Backup       = "enabled"
    Monitoring   = "comprehensive"
    SLA          = "99.9"
  }
}

variable "application_insights_tags" {
  description = "Application Insights specific tags"
  type        = map(string)
  default = {
    Component      = "monitoring"
    Service        = "application-insights"
    MonitoringTier = "enterprise"
    AlertLevel     = "critical"
    DataRetention  = "long-term"
    ExportEnabled  = "true"
    AnalyticsReady = "true"
    DashboardReady = "true"
  }
}