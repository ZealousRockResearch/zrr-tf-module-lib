module "application_insights" {
  source = "../../"

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = var.application_type

  workspace_id = var.workspace_id

  environment = var.environment
  criticality = var.criticality

  # Data management
  retention_in_days                     = var.retention_in_days
  daily_data_cap_gb                     = var.daily_data_cap_gb
  daily_data_cap_notifications_disabled = var.daily_data_cap_notifications_disabled
  sampling_percentage                   = var.sampling_percentage

  # Security configuration
  disable_ip_masking                  = var.disable_ip_masking
  local_authentication_disabled       = var.local_authentication_disabled
  internet_ingestion_enabled          = var.internet_ingestion_enabled
  internet_query_enabled              = var.internet_query_enabled
  force_customer_storage_for_profiler = var.force_customer_storage_for_profiler

  # Monitoring and alerting
  enable_standard_alerts         = var.enable_standard_alerts
  alert_severity                 = var.alert_severity
  server_response_time_threshold = var.server_response_time_threshold
  failure_rate_threshold         = var.failure_rate_threshold
  exception_rate_threshold       = var.exception_rate_threshold
  action_group_ids               = var.action_group_ids

  # Web tests
  web_tests = var.web_tests

  # Custom alerts
  custom_alerts = var.custom_alerts

  # Smart detection
  smart_detection_rules = var.smart_detection_rules

  # Analytics items
  analytics_items = var.analytics_items

  # API keys
  api_keys = var.api_keys

  # Workbook templates
  workbook_templates = var.workbook_templates

  # Continuous export
  enable_continuous_export = var.enable_continuous_export
  continuous_export_config = var.continuous_export_config

  # Enterprise governance
  compliance_requirements = var.compliance_requirements
  data_governance         = var.data_governance

  # Tags
  common_tags               = var.common_tags
  application_insights_tags = var.application_insights_tags
}