module "dns_record" {
  source = "../../"

  name        = var.record_name
  record_type = var.record_type
  records     = var.records
  ttl         = var.ttl

  dns_zone_name                = var.dns_zone_name
  dns_zone_resource_group_name = var.dns_zone_resource_group_name

  environment = var.environment
  criticality = var.criticality

  common_tags = var.common_tags
}