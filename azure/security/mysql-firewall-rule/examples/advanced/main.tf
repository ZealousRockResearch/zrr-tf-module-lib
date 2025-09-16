module "mysql_firewall_rules_advanced" {
  source = "../../"

  # MySQL Flexible Server configuration
  mysql_flexible_server_name                = var.mysql_flexible_server_name
  mysql_flexible_server_resource_group_name = var.mysql_flexible_server_resource_group_name

  # Custom firewall rules
  firewall_rules = var.firewall_rules

  # Predefined access patterns
  allow_office_ips          = var.allow_office_ips
  allow_developer_ips       = var.allow_developer_ips
  allow_application_subnets = var.allow_application_subnets

  # Azure services access
  allow_azure_services = var.allow_azure_services

  # Enterprise features
  environment                = var.environment
  enable_monitoring          = var.enable_monitoring
  alert_on_rule_changes      = var.alert_on_rule_changes
  require_justification      = var.require_justification
  max_firewall_rules         = var.max_firewall_rules
  enable_ip_range_validation = var.enable_ip_range_validation

  # Compliance and governance
  compliance_tags = var.compliance_tags

  # Tags
  common_tags              = var.common_tags
  mysql_firewall_rule_tags = var.mysql_firewall_rule_tags
}