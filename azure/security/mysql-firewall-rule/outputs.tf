# Primary outputs
output "firewall_rule_ids" {
  description = "Map of firewall rule names to their IDs"
  value = merge(
    { for k, v in azurerm_mysql_firewall_rule.main : k => v.id },
    { for k, v in azurerm_mysql_flexible_server_firewall_rule.main : k => v.id }
  )
}

output "firewall_rule_names" {
  description = "List of created firewall rule names"
  value = concat(
    [for v in azurerm_mysql_firewall_rule.main : v.name],
    [for v in azurerm_mysql_flexible_server_firewall_rule.main : v.name]
  )
}

output "server_name" {
  description = "Name of the MySQL server"
  value       = local.mysql_server_name
}

output "server_type" {
  description = "Type of MySQL server (single or flexible)"
  value       = local.is_flexible_server ? "flexible" : "single"
}

# Rule configuration outputs
output "firewall_rules_count" {
  description = "Total number of firewall rules created"
  value       = length(local.all_firewall_rules)
}

output "azure_services_allowed" {
  description = "Whether Azure services access is enabled"
  value       = var.allow_azure_services
}

output "office_ips_count" {
  description = "Number of office IP ranges configured"
  value       = length(var.allow_office_ips)
}

output "developer_ips_count" {
  description = "Number of developer IP addresses configured"
  value       = length(var.allow_developer_ips)
}

output "application_subnets_count" {
  description = "Number of application subnets configured"
  value       = length(var.allow_application_subnets)
}

# Security and compliance outputs
output "security_configuration" {
  description = "Summary of security configuration"
  value = {
    ip_range_validation_enabled = var.enable_ip_range_validation
    max_firewall_rules_limit    = var.max_firewall_rules
    monitoring_enabled          = var.enable_monitoring
    alert_on_changes            = var.alert_on_rule_changes
    justification_required      = var.require_justification
    environment                 = var.environment
  }
}

output "compliance_status" {
  description = "Compliance and governance status"
  value = {
    compliance_tags_applied = length(var.compliance_tags) > 0
    environment_validated   = contains(["dev", "test", "staging", "prod", "sandbox"], var.environment)
    rule_count_within_limit = length(local.all_firewall_rules) <= var.max_firewall_rules
    azure_services_access   = var.allow_azure_services
  }
}

# Detailed rule information
output "firewall_rules_details" {
  description = "Detailed information about all firewall rules"
  value = {
    for rule in local.all_firewall_rules : rule.name => {
      start_ip = rule.start_ip_address
      end_ip   = rule.end_ip_address
      type     = rule.name == "AllowAllWindowsAzureIps" ? "azure_services" : "custom"
    }
  }
}

# Network access summary
output "network_access_summary" {
  description = "Summary of network access configuration"
  value = {
    total_rules             = length(local.all_firewall_rules)
    azure_services_enabled  = var.allow_azure_services
    office_locations        = length(var.allow_office_ips)
    developer_access_points = length(var.allow_developer_ips)
    application_networks    = length(var.allow_application_subnets)
    custom_rules            = length(var.firewall_rules)
  }
}

# Resource references
output "mysql_server_reference" {
  description = "Reference information for the MySQL server"
  value = {
    server_id      = var.mysql_server_id
    server_name    = local.mysql_server_name
    server_type    = local.is_flexible_server ? "flexible" : "single"
    resource_group = var.mysql_server_resource_group_name != null ? var.mysql_server_resource_group_name : var.mysql_flexible_server_resource_group_name
  }
  sensitive = false
}

# Tags information
output "applied_tags" {
  description = "Tags applied to the firewall rules"
  value       = local.common_tags
}