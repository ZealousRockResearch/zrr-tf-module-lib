module "dns_zone_advanced" {
  source = "../../"

  name                = var.zone_name
  resource_group_name = var.resource_group_name

  # Complete DNS record configuration
  a_records     = var.a_records
  aaaa_records  = var.aaaa_records
  cname_records = var.cname_records
  mx_records    = var.mx_records
  txt_records   = var.txt_records
  srv_records   = var.srv_records
  ptr_records   = var.ptr_records

  # Delegation configuration
  enable_delegation = var.enable_delegation
  parent_zone_name  = var.parent_zone_name
  delegation_ttl    = var.delegation_ttl
  verify_delegation = var.verify_delegation

  # Virtual network integration
  virtual_network_id       = var.virtual_network_id
  enable_auto_registration = var.enable_auto_registration

  # Monitoring and alerting
  enable_monitoring          = var.enable_monitoring
  action_group_id            = var.action_group_id
  query_volume_threshold     = var.query_volume_threshold
  record_set_count_threshold = var.record_set_count_threshold

  # Naming convention
  use_naming_convention = var.use_naming_convention
  environment           = var.environment
  domain_suffix         = var.domain_suffix

  # Security features
  enable_zone_signing                 = var.enable_zone_signing
  zone_signing_key_rollover_frequency = var.zone_signing_key_rollover_frequency

  # Advanced SOA configuration
  soa_record = var.soa_record

  # Tags
  common_tags   = var.common_tags
  dns_zone_tags = var.dns_zone_tags
}

# Output all key values for reference
output "dns_zone_id" {
  description = "ID of the DNS zone"
  value       = module.dns_zone_advanced.id
}

output "dns_zone_name" {
  description = "Name of the DNS zone"
  value       = module.dns_zone_advanced.name
}

output "fqdn" {
  description = "Fully qualified domain name"
  value       = module.dns_zone_advanced.fqdn
}

output "name_servers" {
  description = "Name servers for the DNS zone"
  value       = module.dns_zone_advanced.name_servers
}

output "primary_name_server" {
  description = "Primary name server"
  value       = module.dns_zone_advanced.primary_name_server
}

output "a_records" {
  description = "Created A records"
  value       = module.dns_zone_advanced.a_records
}

output "aaaa_records" {
  description = "Created AAAA records"
  value       = module.dns_zone_advanced.aaaa_records
}

output "cname_records" {
  description = "Created CNAME records"
  value       = module.dns_zone_advanced.cname_records
}

output "mx_records" {
  description = "Created MX records"
  value       = module.dns_zone_advanced.mx_records
}

output "txt_records" {
  description = "Created TXT records"
  value       = module.dns_zone_advanced.txt_records
}

output "srv_records" {
  description = "Created SRV records"
  value       = module.dns_zone_advanced.srv_records
}

output "ptr_records" {
  description = "Created PTR records"
  value       = module.dns_zone_advanced.ptr_records
}

output "record_count" {
  description = "Total number of DNS records"
  value       = module.dns_zone_advanced.record_count
}

output "record_types_summary" {
  description = "Summary of record types and counts"
  value       = module.dns_zone_advanced.record_types_summary
}

output "delegation_enabled" {
  description = "Whether DNS delegation is enabled"
  value       = module.dns_zone_advanced.delegation_enabled
}

output "delegation_ns_record_id" {
  description = "ID of delegation NS record"
  value       = module.dns_zone_advanced.delegation_ns_record_id
}

output "vnet_link_id" {
  description = "ID of virtual network link"
  value       = module.dns_zone_advanced.vnet_link_id
}

output "vnet_link_enabled" {
  description = "Whether VNet link is enabled"
  value       = module.dns_zone_advanced.vnet_link_enabled
}

output "monitoring_enabled" {
  description = "Whether monitoring is enabled"
  value       = module.dns_zone_advanced.monitoring_enabled
}

output "query_volume_alert_id" {
  description = "ID of query volume alert"
  value       = module.dns_zone_advanced.query_volume_alert_id
}

output "record_count_alert_id" {
  description = "ID of record count alert"
  value       = module.dns_zone_advanced.record_count_alert_id
}

output "alert_thresholds" {
  description = "Configured alert thresholds"
  value       = module.dns_zone_advanced.alert_thresholds
}

output "zone_signing_enabled" {
  description = "Whether DNSSEC is enabled"
  value       = module.dns_zone_advanced.zone_signing_enabled
}

output "zone_name_details" {
  description = "Zone naming details"
  value       = module.dns_zone_advanced.zone_name_details
}

output "zone_summary" {
  description = "Comprehensive zone summary"
  value       = module.dns_zone_advanced.zone_summary
}

output "tags" {
  description = "Tags applied to resources"
  value       = module.dns_zone_advanced.tags
}