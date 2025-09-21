output "application_insights_id" {
  description = "ID of the Application Insights component"
  value       = module.application_insights.id
}

output "application_insights_name" {
  description = "Name of the Application Insights component"
  value       = module.application_insights.name
}

output "app_id" {
  description = "Application ID of the Application Insights component"
  value       = module.application_insights.app_id
}

output "instrumentation_key" {
  description = "Instrumentation key for the Application Insights component"
  value       = module.application_insights.instrumentation_key
  sensitive   = true
}

output "connection_string" {
  description = "Connection string for the Application Insights component"
  value       = module.application_insights.connection_string
  sensitive   = true
}

output "workspace_id" {
  description = "Log Analytics workspace ID"
  value       = module.application_insights.workspace_id
}

# Advanced monitoring outputs
output "web_tests" {
  description = "Web tests configuration and status"
  value       = module.application_insights.web_tests
}

output "standard_alerts" {
  description = "Standard alert rules information"
  value       = module.application_insights.standard_alerts
}

output "custom_alerts" {
  description = "Custom alert rules information"
  value       = module.application_insights.custom_alerts
}

output "smart_detection_rules" {
  description = "Smart detection rules configuration"
  value       = module.application_insights.smart_detection_rules
}

output "analytics_items" {
  description = "Analytics items (queries and functions) information"
  value       = module.application_insights.analytics_items
}

output "api_keys" {
  description = "API keys information (keys are sensitive and not exposed)"
  value       = module.application_insights.api_keys
}

output "api_key_values" {
  description = "API key values (sensitive)"
  value       = module.application_insights.api_key_values
  sensitive   = true
}

output "workbook_templates" {
  description = "Workbook templates information"
  value       = module.application_insights.workbook_templates
}

# Enterprise governance outputs
output "monitoring_config" {
  description = "Comprehensive monitoring configuration summary"
  value       = module.application_insights.monitoring_config
}

output "data_governance" {
  description = "Data governance and compliance information"
  value       = module.application_insights.data_governance
}

output "security_config" {
  description = "Security configuration summary"
  value       = module.application_insights.security_config
}

output "continuous_export_config" {
  description = "Continuous export configuration status"
  value       = module.application_insights.continuous_export_config
}

output "resource_details" {
  description = "Resource management information"
  value       = module.application_insights.resource_details
}

# Integration outputs for other services
output "for_app_service_integration" {
  description = "Configuration values for App Service integration"
  value       = module.application_insights.for_app_service_integration
  sensitive   = true
}

output "for_function_app_integration" {
  description = "Configuration values for Function App integration"
  value       = module.application_insights.for_function_app_integration
  sensitive   = true
}

output "for_kubernetes_integration" {
  description = "Configuration values for Kubernetes/Container integration"
  value       = module.application_insights.for_kubernetes_integration
  sensitive   = true
}

output "for_log_analytics_integration" {
  description = "Information for Log Analytics integration"
  value       = module.application_insights.for_log_analytics_integration
  sensitive   = true
}

# Enterprise reporting outputs
output "enterprise_summary" {
  description = "Enterprise monitoring and governance summary"
  value = {
    component_name      = module.application_insights.name
    environment         = var.environment
    criticality         = var.criticality
    data_retention_days = var.retention_in_days
    daily_cap_gb        = var.daily_data_cap_gb
    sampling_percentage = var.sampling_percentage

    monitoring = {
      web_tests_count       = length(var.web_tests)
      standard_alerts       = var.enable_standard_alerts
      custom_alerts_count   = length(var.custom_alerts)
      smart_detection_count = length(var.smart_detection_rules)
      api_keys_count        = length(var.api_keys)
      workbooks_count       = length(var.workbook_templates)
      analytics_items_count = length(var.analytics_items)
    }

    compliance = {
      requirements        = var.compliance_requirements
      data_classification = var.data_governance.data_classification
      pii_detection       = var.data_governance.pii_detection_enabled
      data_masking        = var.data_governance.data_masking_enabled
      continuous_export   = var.enable_continuous_export
    }

    security = {
      local_auth_disabled        = var.local_authentication_disabled
      ip_masking_enabled         = !var.disable_ip_masking
      internet_access_controlled = !var.internet_ingestion_enabled || !var.internet_query_enabled
      customer_storage_forced    = var.force_customer_storage_for_profiler
    }
  }
}