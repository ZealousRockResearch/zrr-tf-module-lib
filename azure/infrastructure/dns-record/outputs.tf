# Primary outputs
output "id" {
  description = "ID of the DNS record"
  value = coalesce(
    try(azurerm_dns_a_record.main[0].id, ""),
    try(azurerm_dns_aaaa_record.main[0].id, ""),
    try(azurerm_dns_cname_record.main[0].id, ""),
    try(azurerm_dns_mx_record.main[0].id, ""),
    try(azurerm_dns_ns_record.main[0].id, ""),
    try(azurerm_dns_txt_record.main[0].id, ""),
    try(azurerm_dns_srv_record.main[0].id, ""),
    try(azurerm_private_dns_a_record.main[0].id, ""),
    try(azurerm_private_dns_aaaa_record.main[0].id, ""),
    try(azurerm_private_dns_cname_record.main[0].id, ""),
    try(azurerm_private_dns_mx_record.main[0].id, ""),
    try(azurerm_private_dns_txt_record.main[0].id, ""),
    try(azurerm_private_dns_srv_record.main[0].id, "")
  )
}

output "name" {
  description = "Name of the DNS record"
  value       = var.name
}

output "fqdn" {
  description = "Fully qualified domain name of the DNS record"
  value       = local.record_fqdn
}

output "record_type" {
  description = "Type of the DNS record"
  value       = local.record_type_upper
}

output "ttl" {
  description = "TTL (Time to Live) of the DNS record"
  value       = local.ttl_value
}

output "records" {
  description = "Values of the DNS record"
  value       = var.records
}

# Zone information
output "dns_zone_name" {
  description = "Name of the DNS zone containing the record"
  value       = local.dns_zone_name
}

output "dns_zone_type" {
  description = "Type of DNS zone (public or private)"
  value       = local.is_private_zone ? "private" : "public"
}

output "resource_group_name" {
  description = "Resource group name of the DNS zone"
  value       = local.dns_zone_resource_group
}

# Record-specific outputs
output "mx_records" {
  description = "MX record configurations (if applicable)"
  value       = var.mx_records
}

output "srv_records" {
  description = "SRV record configurations (if applicable)"
  value       = var.srv_records
}

# Monitoring and governance outputs
output "monitoring_enabled" {
  description = "Whether monitoring is enabled for the DNS record"
  value       = var.enable_monitoring
}

output "health_check_enabled" {
  description = "Whether health monitoring is enabled"
  value       = var.health_check_enabled
}

output "alert_on_changes" {
  description = "Whether alerts are enabled for record changes"
  value       = var.alert_on_changes
}

output "environment" {
  description = "Environment of the DNS record"
  value       = var.environment
}

output "criticality" {
  description = "Criticality level of the DNS record"
  value       = var.criticality
}

output "compliance_requirements" {
  description = "Compliance requirements for the DNS record"
  value       = var.compliance_requirements
}

# Security and governance summary
output "security_configuration" {
  description = "Summary of security configuration"
  value = {
    access_restrictions   = var.security_config.access_restrictions
    change_protection     = var.security_config.change_protection
    audit_logging         = var.security_config.audit_logging
    encryption_in_transit = var.security_config.encryption_in_transit
  }
}

output "lifecycle_configuration" {
  description = "Summary of lifecycle configuration"
  value = {
    auto_delete_after_days   = var.record_lifecycle.auto_delete_after_days
    backup_enabled           = var.record_lifecycle.backup_enabled
    change_approval_required = var.record_lifecycle.change_approval_required
    scheduled_updates        = var.record_lifecycle.scheduled_updates
  }
}

output "validation_configuration" {
  description = "Summary of validation configuration"
  value = {
    strict_format_checking = var.validation_rules.strict_format_checking
    allow_wildcard_records = var.validation_rules.allow_wildcard_records
    max_record_count       = var.validation_rules.max_record_count
    forbidden_values       = var.validation_rules.forbidden_values
  }
}

# Compliance and audit outputs
output "compliance_status" {
  description = "Compliance and governance status"
  value = {
    compliance_requirements_met = length(var.compliance_requirements) > 0
    audit_logging_enabled       = var.security_config.audit_logging
    change_protection_enabled   = var.security_config.change_protection
    monitoring_enabled          = var.enable_monitoring
    environment_validated       = contains(["dev", "test", "staging", "prod", "sandbox"], var.environment)
    criticality_level           = var.criticality
  }
}

# Record management outputs
output "record_management" {
  description = "Summary of record management capabilities"
  value = {
    record_count             = length(var.records)
    supports_multiple_values = local.record_type_upper != "CNAME"
    zone_type                = local.is_private_zone ? "private" : "public"
    ttl_configured           = local.ttl_value
    record_type              = local.record_type_upper
    apex_record              = var.name == "@"
  }
}

# Network information
output "network_information" {
  description = "Network-related information about the DNS record"
  value = {
    is_private_zone = local.is_private_zone
    zone_name       = local.dns_zone_name
    record_fqdn     = local.record_fqdn
    record_name     = var.name
    resource_group  = local.dns_zone_resource_group
  }
}

# Tags information
output "applied_tags" {
  description = "Tags applied to the DNS record"
  value       = local.common_tags
}

# Record validation status
output "validation_status" {
  description = "Status of record validation"
  value = {
    record_values_valid   = local.record_values_valid
    zone_reference_valid  = local.zone_reference_count == 1
    ttl_valid             = local.ttl_value >= 1 && local.ttl_value <= 2147483647
    record_type_supported = contains(["A", "AAAA", "CNAME", "MX", "NS", "PTR", "SOA", "SRV", "TXT", "CAA"], local.record_type_upper)
    cname_count_valid     = local.record_type_upper != "CNAME" || length(var.records) == 1
  }
}