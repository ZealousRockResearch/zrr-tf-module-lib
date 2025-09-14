# Primary outputs
output "id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.main.id
}

output "name" {
  description = "Name of the network security group"
  value       = azurerm_network_security_group.main.name
}

output "location" {
  description = "Location of the network security group"
  value       = azurerm_network_security_group.main.location
}

output "resource_group_name" {
  description = "Resource group name of the network security group"
  value       = azurerm_network_security_group.main.resource_group_name
}

# Security rules outputs
output "security_rules" {
  description = "List of security rules created"
  value = {
    for k, v in azurerm_network_security_rule.main : k => {
      id                           = v.id
      name                         = v.name
      priority                     = v.priority
      direction                    = v.direction
      access                       = v.access
      protocol                     = v.protocol
      source_port_range            = v.source_port_range
      source_port_ranges           = v.source_port_ranges
      destination_port_range       = v.destination_port_range
      destination_port_ranges      = v.destination_port_ranges
      source_address_prefix        = v.source_address_prefix
      source_address_prefixes      = v.source_address_prefixes
      destination_address_prefix   = v.destination_address_prefix
      destination_address_prefixes = v.destination_address_prefixes
      description                  = v.description
    }
  }
}

output "security_rule_ids" {
  description = "Map of security rule names to their IDs"
  value = {
    for k, v in azurerm_network_security_rule.main : k => v.id
  }
}

# Association outputs
output "subnet_association_id" {
  description = "ID of the subnet association (if created)"
  value       = try(azurerm_subnet_network_security_group_association.main[0].id, null)
}

output "network_interface_association_ids" {
  description = "Map of network interface IDs to their association IDs"
  value = {
    for k, v in azurerm_network_interface_security_group_association.main : k => v.id
  }
}

# Resource group output (if created)
output "resource_group_id" {
  description = "ID of the resource group (if created by this module)"
  value       = try(azurerm_resource_group.main[0].id, null)
}

output "tags" {
  description = "Tags applied to the network security group"
  value       = azurerm_network_security_group.main.tags
}

# Computed attributes
output "effective_security_rules_count" {
  description = "Number of security rules created"
  value       = length(azurerm_network_security_rule.main)
}

output "has_inbound_rules" {
  description = "Whether the NSG has any inbound rules"
  value       = length([for rule in var.security_rules : rule if rule.direction == "Inbound"]) > 0
}

output "has_outbound_rules" {
  description = "Whether the NSG has any outbound rules"
  value       = length([for rule in var.security_rules : rule if rule.direction == "Outbound"]) > 0
}

output "inbound_rules_count" {
  description = "Number of inbound security rules"
  value       = length([for rule in var.security_rules : rule if rule.direction == "Inbound"])
}

output "outbound_rules_count" {
  description = "Number of outbound security rules"
  value       = length([for rule in var.security_rules : rule if rule.direction == "Outbound"])
}