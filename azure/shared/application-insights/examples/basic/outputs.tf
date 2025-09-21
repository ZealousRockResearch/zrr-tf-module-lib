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

output "monitoring_config" {
  description = "Monitoring configuration summary"
  value       = module.application_insights.monitoring_config
}

output "data_governance" {
  description = "Data governance configuration"
  value       = module.application_insights.data_governance
}

output "security_config" {
  description = "Security configuration summary"
  value       = module.application_insights.security_config
}