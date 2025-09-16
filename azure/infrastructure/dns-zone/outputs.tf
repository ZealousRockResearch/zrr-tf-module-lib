# Primary DNS zone outputs
output "id" {
  description = "ID of the DNS zone"
  value       = azurerm_dns_zone.main.id
}

output "name" {
  description = "Name of the DNS zone"
  value       = azurerm_dns_zone.main.name
}

output "resource_group_name" {
  description = "Resource group name containing the DNS zone"
  value       = local.resource_group_name
}

output "zone_name" {
  description = "DNS zone name (same as name output for consistency)"
  value       = azurerm_dns_zone.main.name
}

output "fqdn" {
  description = "Fully qualified domain name of the DNS zone"
  value       = azurerm_dns_zone.main.name
}

# Name servers
output "name_servers" {
  description = "List of name servers for the DNS zone"
  value       = azurerm_dns_zone.main.name_servers
}

output "primary_name_server" {
  description = "Primary name server for the DNS zone"
  value       = length(azurerm_dns_zone.main.name_servers) > 0 ? tolist(azurerm_dns_zone.main.name_servers)[0] : null
}

# DNS Records outputs
output "a_records" {
  description = "Information about created A records"
  value = {
    for name, record in azurerm_dns_a_record.a_records : name => {
      id      = record.id
      name    = record.name
      fqdn    = record.fqdn
      ttl     = record.ttl
      records = record.records
    }
  }
}

output "aaaa_records" {
  description = "Information about created AAAA records"
  value = {
    for name, record in azurerm_dns_aaaa_record.aaaa_records : name => {
      id      = record.id
      name    = record.name
      fqdn    = record.fqdn
      ttl     = record.ttl
      records = record.records
    }
  }
}

output "cname_records" {
  description = "Information about created CNAME records"
  value = {
    for name, record in azurerm_dns_cname_record.cname_records : name => {
      id     = record.id
      name   = record.name
      fqdn   = record.fqdn
      ttl    = record.ttl
      record = record.record
    }
  }
}

output "mx_records" {
  description = "Information about created MX records"
  value = {
    for name, record in azurerm_dns_mx_record.mx_records : name => {
      id   = record.id
      name = record.name
      fqdn = record.fqdn
      ttl  = record.ttl
    }
  }
}

output "txt_records" {
  description = "Information about created TXT records"
  value = {
    for name, record in azurerm_dns_txt_record.txt_records : name => {
      id   = record.id
      name = record.name
      fqdn = record.fqdn
      ttl  = record.ttl
    }
  }
}

output "srv_records" {
  description = "Information about created SRV records"
  value = {
    for name, record in azurerm_dns_srv_record.srv_records : name => {
      id   = record.id
      name = record.name
      fqdn = record.fqdn
      ttl  = record.ttl
    }
  }
}

output "ptr_records" {
  description = "Information about created PTR records"
  value = {
    for name, record in azurerm_dns_ptr_record.ptr_records : name => {
      id      = record.id
      name    = record.name
      fqdn    = record.fqdn
      ttl     = record.ttl
      records = record.records
    }
  }
}

# Record statistics
output "record_count" {
  description = "Total number of DNS records created"
  value = (
    length(var.a_records) +
    length(var.aaaa_records) +
    length(var.cname_records) +
    length(var.mx_records) +
    length(var.txt_records) +
    length(var.srv_records) +
    length(var.ptr_records)
  )
}

output "record_types_summary" {
  description = "Summary of record types and counts"
  value = {
    a_records     = length(var.a_records)
    aaaa_records  = length(var.aaaa_records)
    cname_records = length(var.cname_records)
    mx_records    = length(var.mx_records)
    txt_records   = length(var.txt_records)
    srv_records   = length(var.srv_records)
    ptr_records   = length(var.ptr_records)
  }
}

# Delegation outputs
output "delegation_enabled" {
  description = "Whether DNS delegation is enabled"
  value       = var.enable_delegation
}

output "parent_zone_name" {
  description = "Parent zone name for delegation"
  value       = var.parent_zone_name
}

output "delegation_ns_record_id" {
  description = "ID of the delegation NS record in parent zone"
  value       = var.enable_delegation && var.parent_zone_name != null ? azurerm_dns_ns_record.delegation[0].id : null
}

# Virtual Network integration outputs
output "vnet_link_id" {
  description = "ID of the virtual network link"
  value       = var.virtual_network_id != null ? azurerm_private_dns_zone_virtual_network_link.vnet_link[0].id : null
}

output "vnet_link_enabled" {
  description = "Whether virtual network link is enabled"
  value       = var.virtual_network_id != null
}

output "auto_registration_enabled" {
  description = "Whether auto-registration is enabled"
  value       = var.enable_auto_registration
}

# Monitoring outputs
output "monitoring_enabled" {
  description = "Whether monitoring is enabled for the DNS zone"
  value       = var.enable_monitoring
}

output "query_volume_alert_id" {
  description = "ID of the query volume metric alert"
  value       = var.enable_monitoring ? azurerm_monitor_metric_alert.dns_query_volume[0].id : null
}

output "record_count_alert_id" {
  description = "ID of the record count metric alert"
  value       = var.enable_monitoring && var.record_set_count_threshold > 0 ? azurerm_monitor_metric_alert.dns_record_set_count[0].id : null
}

output "alert_thresholds" {
  description = "Configured alert thresholds"
  value = {
    query_volume     = var.query_volume_threshold
    record_set_count = var.record_set_count_threshold
  }
}

# Naming convention outputs
output "naming_convention_used" {
  description = "Whether naming convention was used"
  value       = var.use_naming_convention
}

output "zone_name_details" {
  description = "DNS zone naming details"
  value = {
    original_name     = var.name
    final_zone_name   = local.dns_zone_name
    environment       = var.environment
    domain_suffix     = var.domain_suffix
    naming_convention = var.use_naming_convention
  }
}

# Security outputs
output "zone_signing_enabled" {
  description = "Whether DNSSEC zone signing is enabled"
  value       = var.enable_zone_signing
}

output "zone_signing_key_rollover_frequency" {
  description = "Zone signing key rollover frequency in days"
  value       = var.zone_signing_key_rollover_frequency
}

# Tags output
output "tags" {
  description = "Tags applied to the DNS zone"
  value       = local.common_tags
}

# Zone summary
output "zone_summary" {
  description = "Comprehensive summary of the DNS zone configuration"
  value = {
    zone_name      = azurerm_dns_zone.main.name
    resource_group = local.resource_group_name
    name_servers   = azurerm_dns_zone.main.name_servers
    total_records = (
      length(var.a_records) +
      length(var.aaaa_records) +
      length(var.cname_records) +
      length(var.mx_records) +
      length(var.txt_records) +
      length(var.srv_records) +
      length(var.ptr_records)
    )
    delegation_enabled   = var.enable_delegation
    vnet_linked          = var.virtual_network_id != null
    monitoring_enabled   = var.enable_monitoring
    zone_signing_enabled = var.enable_zone_signing
  }
  sensitive = false
}