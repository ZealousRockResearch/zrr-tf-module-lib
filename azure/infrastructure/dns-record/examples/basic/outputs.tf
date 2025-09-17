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