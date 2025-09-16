output "firewall_rule_ids" {
  description = "Map of firewall rule names to their IDs"
  value       = module.mysql_firewall_rules.firewall_rule_ids
}

output "firewall_rule_names" {
  description = "List of created firewall rule names"
  value       = module.mysql_firewall_rules.firewall_rule_names
}

output "firewall_rules_count" {
  description = "Total number of firewall rules created"
  value       = module.mysql_firewall_rules.firewall_rules_count
}

output "azure_services_allowed" {
  description = "Whether Azure services access is enabled"
  value       = module.mysql_firewall_rules.azure_services_allowed
}

output "security_configuration" {
  description = "Summary of security configuration"
  value       = module.mysql_firewall_rules.security_configuration
}

output "network_access_summary" {
  description = "Summary of network access configuration"
  value       = module.mysql_firewall_rules.network_access_summary
}