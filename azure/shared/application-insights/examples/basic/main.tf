module "application_insights" {
  source = "../../"

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = var.application_type

  workspace_name                = var.workspace_name
  workspace_resource_group_name = var.workspace_resource_group_name

  environment = var.environment
  criticality = var.criticality

  retention_in_days = var.retention_in_days

  enable_standard_alerts = var.enable_standard_alerts

  common_tags = var.common_tags
}