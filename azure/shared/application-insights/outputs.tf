# Primary outputs
output "id" {
  description = "ID of the Application Insights component"
  value       = azurerm_application_insights.this.id
}

output "name" {
  description = "Name of the Application Insights component"
  value       = azurerm_application_insights.this.name
}

output "app_id" {
  description = "Application ID of the Application Insights component"
  value       = azurerm_application_insights.this.app_id
}

output "instrumentation_key" {
  description = "Instrumentation key of the Application Insights component"
  value       = azurerm_application_insights.this.instrumentation_key
  sensitive   = true
}

output "connection_string" {
  description = "Connection string for the Application Insights component"
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
}

# Configuration outputs
output "application_type" {
  description = "Application type of the Application Insights component"
  value       = azurerm_application_insights.this.application_type
}

output "workspace_id" {
  description = "Log Analytics workspace ID associated with Application Insights"
  value       = azurerm_application_insights.this.workspace_id
}

output "retention_in_days" {
  description = "Data retention period in days"
  value       = azurerm_application_insights.this.retention_in_days
}

output "daily_data_cap_in_gb" {
  description = "Daily data volume cap in GB"
  value       = azurerm_application_insights.this.daily_data_cap_in_gb
}

output "sampling_percentage" {
  description = "Sampling percentage for telemetry data"
  value       = azurerm_application_insights.this.sampling_percentage
}

# Web tests outputs
output "web_tests" {
  description = "Web tests configuration and status"
  value = {
    for key, test in azurerm_application_insights_web_test.this : key => {
      id                   = test.id
      name                 = test.name
      kind                 = test.kind
      frequency            = test.frequency
      timeout              = test.timeout
      enabled              = test.enabled
      geo_locations        = test.geo_locations
      synthetic_monitor_id = test.synthetic_monitor_id
    }
  }
}

# Alert rules outputs
output "standard_alerts" {
  description = "Standard alert rules information"
  value = var.enable_standard_alerts ? {
    server_response_time = {
      id      = try(azurerm_monitor_metric_alert.server_response_time[0].id, null)
      name    = try(azurerm_monitor_metric_alert.server_response_time[0].name, null)
      enabled = try(azurerm_monitor_metric_alert.server_response_time[0].enabled, null)
    }
    failure_rate = {
      id      = try(azurerm_monitor_metric_alert.failure_rate[0].id, null)
      name    = try(azurerm_monitor_metric_alert.failure_rate[0].name, null)
      enabled = try(azurerm_monitor_metric_alert.failure_rate[0].enabled, null)
    }
    exception_rate = {
      id      = try(azurerm_monitor_metric_alert.exception_rate[0].id, null)
      name    = try(azurerm_monitor_metric_alert.exception_rate[0].name, null)
      enabled = try(azurerm_monitor_metric_alert.exception_rate[0].enabled, null)
    }
  } : {}
}

output "custom_alerts" {
  description = "Custom alert rules information"
  value = {
    for key, alert in azurerm_monitor_metric_alert.custom : key => {
      id       = alert.id
      name     = alert.name
      enabled  = alert.enabled
      severity = alert.severity
    }
  }
}

# Smart detection outputs
output "smart_detection_rules" {
  description = "Smart detection rules configuration"
  value = {
    for key, rule in azurerm_application_insights_smart_detection_rule.this : key => {
      id      = rule.id
      name    = rule.name
      enabled = rule.enabled
    }
  }
}

# Analytics items outputs
output "analytics_items" {
  description = "Analytics items (queries and functions) information"
  value = {
    for key, item in azurerm_application_insights_analytics_item.this : key => {
      id             = item.id
      name           = item.name
      type           = item.type
      scope          = item.scope
      function_alias = item.function_alias
      version        = item.version
    }
  }
}

# API keys outputs
output "api_keys" {
  description = "API keys information (keys are sensitive and not exposed)"
  value = {
    for key, api_key in azurerm_application_insights_api_key.this : key => {
      id                = api_key.id
      name              = api_key.name
      read_permissions  = api_key.read_permissions
      write_permissions = api_key.write_permissions
    }
  }
}

output "api_key_values" {
  description = "API key values (sensitive)"
  value = {
    for key, api_key in azurerm_application_insights_api_key.this : key => api_key.api_key
  }
  sensitive = true
}

# Workbook templates outputs
output "workbook_templates" {
  description = "Workbook templates information"
  value = {
    for key, template in azurerm_application_insights_workbook_template.this : key => {
      id          = template.id
      name        = template.name
      author      = template.author
      description = template.description
    }
  }
}

# Monitoring and governance outputs
output "monitoring_config" {
  description = "Monitoring configuration summary"
  value = {
    alerts_enabled        = var.enable_standard_alerts
    web_tests_count       = length(var.web_tests)
    custom_alerts_count   = length(var.custom_alerts)
    smart_detection_count = length(var.smart_detection_rules)
    thresholds = {
      server_response_time = var.server_response_time_threshold
      failure_rate         = var.failure_rate_threshold
      exception_rate       = var.exception_rate_threshold
    }
  }
}

output "data_governance" {
  description = "Data governance and compliance information"
  value = {
    data_classification     = var.data_governance.data_classification
    data_retention_policy   = var.data_governance.data_retention_policy
    pii_detection_enabled   = var.data_governance.pii_detection_enabled
    data_masking_enabled    = var.data_governance.data_masking_enabled
    compliance_requirements = var.compliance_requirements
    retention_days          = azurerm_application_insights.this.retention_in_days
    daily_cap_gb            = azurerm_application_insights.this.daily_data_cap_in_gb
    ip_masking_disabled     = azurerm_application_insights.this.disable_ip_masking
  }
}

output "security_config" {
  description = "Security configuration summary"
  value = {
    local_auth_disabled        = azurerm_application_insights.this.local_authentication_disabled
    internet_ingestion_enabled = azurerm_application_insights.this.internet_ingestion_enabled
    internet_query_enabled     = azurerm_application_insights.this.internet_query_enabled
    force_customer_storage     = azurerm_application_insights.this.force_customer_storage_for_profiler
    ip_masking_disabled        = azurerm_application_insights.this.disable_ip_masking
    api_keys_count             = length(var.api_keys)
  }
}

output "resource_details" {
  description = "Resource management information"
  value = {
    resource_group_name = azurerm_application_insights.this.resource_group_name
    location            = azurerm_application_insights.this.location
    environment         = var.environment
    criticality         = var.criticality
    created_date        = timestamp()
    module_version      = "1.0.0"
  }
}

output "continuous_export_config" {
  description = "Continuous export configuration status"
  value = {
    enabled = var.enable_continuous_export
    config  = var.enable_continuous_export ? var.continuous_export_config : null
  }
}

output "tags" {
  description = "Tags applied to the Application Insights component"
  value       = azurerm_application_insights.this.tags
}

# Integration outputs for dependent resources
output "for_log_analytics_integration" {
  description = "Information for Log Analytics integration"
  value = {
    component_id        = azurerm_application_insights.this.id
    workspace_id        = azurerm_application_insights.this.workspace_id
    instrumentation_key = azurerm_application_insights.this.instrumentation_key
    connection_string   = azurerm_application_insights.this.connection_string
  }
  sensitive = true
}

output "for_app_service_integration" {
  description = "Configuration for App Service integration"
  value = {
    instrumentation_key = azurerm_application_insights.this.instrumentation_key
    connection_string   = azurerm_application_insights.this.connection_string
    app_id              = azurerm_application_insights.this.app_id
  }
  sensitive = true
}

output "for_function_app_integration" {
  description = "Configuration for Function App integration"
  value = {
    instrumentation_key = azurerm_application_insights.this.instrumentation_key
    connection_string   = azurerm_application_insights.this.connection_string
    app_id              = azurerm_application_insights.this.app_id
  }
  sensitive = true
}

output "for_kubernetes_integration" {
  description = "Configuration for Kubernetes/Container integration"
  value = {
    instrumentation_key = azurerm_application_insights.this.instrumentation_key
    connection_string   = azurerm_application_insights.this.connection_string
    app_id              = azurerm_application_insights.this.app_id
  }
  sensitive = true
}