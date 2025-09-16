output "dns_record_id" {
  description = "ID of the DNS record"
  value       = module.dns_record.id
}

output "dns_record_fqdn" {
  description = "FQDN of the DNS record"
  value       = module.dns_record.fqdn
}

output "dns_record_name" {
  description = "Name of the DNS record"
  value       = module.dns_record.name
}

output "dns_record_type" {
  description = "Type of the DNS record"
  value       = module.dns_record.record_type
}

output "dns_record_ttl" {
  description = "TTL of the DNS record"
  value       = module.dns_record.ttl
}

output "dns_zone_type" {
  description = "Type of DNS zone (public or private)"
  value       = module.dns_record.dns_zone_type
}

output "record_management" {
  description = "Record management information"
  value       = module.dns_record.record_management
}

output "validation_status" {
  description = "Record validation status"
  value       = module.dns_record.validation_status
}

output "monitoring_config" {
  description = "Monitoring configuration details"
  value       = module.dns_record.monitoring_config
}

output "compliance_status" {
  description = "Compliance status and requirements"
  value       = module.dns_record.compliance_status
}

output "security_posture" {
  description = "Security configuration and posture"
  value       = module.dns_record.security_posture
}

output "lifecycle_config" {
  description = "Record lifecycle configuration"
  value       = module.dns_record.lifecycle_config
}

output "health_check_status" {
  description = "Health check status and configuration"
  value       = module.dns_record.health_check_status
}

output "network_info" {
  description = "Network and connectivity information"
  value       = module.dns_record.network_info
}