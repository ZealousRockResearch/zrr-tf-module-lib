module "dns_zone_basic" {
  source = "../../"

  name                = var.zone_name
  resource_group_name = var.resource_group_name

  # Basic A record
  a_records = var.a_records

  # Basic CNAME record
  cname_records = var.cname_records

  # Common tags
  common_tags = var.common_tags

  # DNS zone specific tags
  dns_zone_tags = var.dns_zone_tags
}

# Output all key values for reference
output "dns_zone_id" {
  description = "ID of the DNS zone"
  value       = module.dns_zone_basic.id
}

output "dns_zone_name" {
  description = "Name of the DNS zone"
  value       = module.dns_zone_basic.name
}

output "name_servers" {
  description = "Name servers for the DNS zone"
  value       = module.dns_zone_basic.name_servers
}

output "primary_name_server" {
  description = "Primary name server for the DNS zone"
  value       = module.dns_zone_basic.primary_name_server
}

output "a_records" {
  description = "Created A records"
  value       = module.dns_zone_basic.a_records
}

output "cname_records" {
  description = "Created CNAME records"
  value       = module.dns_zone_basic.cname_records
}

output "record_count" {
  description = "Total number of DNS records"
  value       = module.dns_zone_basic.record_count
}

output "tags" {
  description = "Tags applied to resources"
  value       = module.dns_zone_basic.tags
}