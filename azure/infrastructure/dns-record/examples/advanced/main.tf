module "dns_record" {
  source = "../../"

  name        = var.record_name
  record_type = var.record_type
  records     = var.records
  ttl         = var.ttl

  dns_zone_name                = var.dns_zone_name
  dns_zone_resource_group_name = var.dns_zone_resource_group_name

  private_dns_zone_name                = var.private_dns_zone_name
  private_dns_zone_resource_group_name = var.private_dns_zone_resource_group_name

  mx_records  = var.mx_records
  srv_records = var.srv_records

  environment = var.environment
  criticality = var.criticality

  enable_monitoring    = var.enable_monitoring
  health_check_enabled = var.health_check_enabled
  alert_on_changes     = var.alert_on_changes

  compliance_requirements = var.compliance_requirements

  security_config = var.security_config

  record_lifecycle = var.record_lifecycle

  validation_rules = var.validation_rules

  common_tags     = var.common_tags
  dns_record_tags = var.dns_record_tags
}