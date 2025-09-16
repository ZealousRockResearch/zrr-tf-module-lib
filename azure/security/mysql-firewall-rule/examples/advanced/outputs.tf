output "firewall_rule_ids" {
  description = "Map of firewall rule names to their IDs"
  value       = module.mysql_firewall_rules_advanced.firewall_rule_ids
}

output "firewall_rule_names" {
  description = "List of created firewall rule names"
  value       = module.mysql_firewall_rules_advanced.firewall_rule_names
}

output "server_name" {
  description = "Name of the MySQL server"
  value       = module.mysql_firewall_rules_advanced.server_name
}

output "server_type" {
  description = "Type of MySQL server (single or flexible)"
  value       = module.mysql_firewall_rules_advanced.server_type
}

output "firewall_rules_count" {
  description = "Total number of firewall rules created"
  value       = module.mysql_firewall_rules_advanced.firewall_rules_count
}

output "azure_services_allowed" {
  description = "Whether Azure services access is enabled"
  value       = module.mysql_firewall_rules_advanced.azure_services_allowed
}

output "office_ips_count" {
  description = "Number of office IP ranges configured"
  value       = module.mysql_firewall_rules_advanced.office_ips_count
}

output "developer_ips_count" {
  description = "Number of developer IP addresses configured"
  value       = module.mysql_firewall_rules_advanced.developer_ips_count
}

output "application_subnets_count" {
  description = "Number of application subnets configured"
  value       = module.mysql_firewall_rules_advanced.application_subnets_count
}

output "security_configuration" {
  description = "Summary of security configuration"
  value       = module.mysql_firewall_rules_advanced.security_configuration
}

output "compliance_status" {
  description = "Compliance and governance status"
  value       = module.mysql_firewall_rules_advanced.compliance_status
}

output "firewall_rules_details" {
  description = "Detailed information about all firewall rules"
  value       = module.mysql_firewall_rules_advanced.firewall_rules_details
}

output "network_access_summary" {
  description = "Summary of network access configuration"
  value       = module.mysql_firewall_rules_advanced.network_access_summary
}

output "mysql_server_reference" {
  description = "Reference information for the MySQL server"
  value       = module.mysql_firewall_rules_advanced.mysql_server_reference
}

output "applied_tags" {
  description = "Tags applied to the firewall rules"
  value       = module.mysql_firewall_rules_advanced.applied_tags
}