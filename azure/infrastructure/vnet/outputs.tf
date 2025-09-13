# VNet outputs
output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "vnet_location" {
  description = "Location of the virtual network"
  value       = azurerm_virtual_network.main.location
}

output "vnet_address_space" {
  description = "Address space of the virtual network"
  value       = azurerm_virtual_network.main.address_space
}

output "vnet_dns_servers" {
  description = "DNS servers configured for the virtual network"
  value       = azurerm_virtual_network.main.dns_servers
}

# Subnet outputs
output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = { for k, v in azurerm_subnet.main : k => v.id }
}

output "subnet_names" {
  description = "List of subnet names"
  value       = [for s in azurerm_subnet.main : s.name]
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to their address prefixes"
  value       = { for k, v in azurerm_subnet.main : k => v.address_prefixes }
}

output "subnets" {
  description = "Complete subnet information"
  value = { for k, v in azurerm_subnet.main : k => {
    id                = v.id
    name              = v.name
    address_prefixes  = v.address_prefixes
    service_endpoints = v.service_endpoints
  } }
}

# NSG outputs
output "nsg_ids" {
  description = "Map of NSG names to their IDs"
  value       = { for k, v in azurerm_network_security_group.main : k => v.id }
}

output "nsg_names" {
  description = "List of NSG names"
  value       = [for nsg in azurerm_network_security_group.main : nsg.name]
}

# Route table outputs
output "route_table_ids" {
  description = "Map of route table names to their IDs"
  value       = { for k, v in azurerm_route_table.main : k => v.id }
}

output "route_table_names" {
  description = "List of route table names"
  value       = [for rt in azurerm_route_table.main : rt.name]
}

# Peering outputs
output "peering_ids" {
  description = "Map of peering names to their IDs"
  value       = { for k, v in azurerm_virtual_network_peering.main : k => v.id }
}

output "peering_states" {
  description = "Map of peering names to their connection states"
  value       = { for k, v in azurerm_virtual_network_peering.main : k => v.peering_state }
}

# Resource group information
output "resource_group_name" {
  description = "Name of the resource group containing the VNet"
  value       = data.azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = data.azurerm_resource_group.main.location
}

# Subscription information
output "subscription_id" {
  description = "Subscription ID where the VNet is created"
  value       = data.azurerm_subscription.current.subscription_id
}

output "tenant_id" {
  description = "Tenant ID of the subscription"
  value       = data.azurerm_subscription.current.tenant_id
}

# Tags output
output "tags" {
  description = "Tags applied to the virtual network"
  value       = azurerm_virtual_network.main.tags
}

# Computed values
output "vnet_resource_id" {
  description = "Full resource ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_guid" {
  description = "GUID of the virtual network"
  value       = azurerm_virtual_network.main.guid
}

output "has_ddos_protection" {
  description = "Boolean indicating if DDoS protection is enabled"
  value       = var.enable_ddos_protection
}

output "has_flow_logs" {
  description = "Boolean indicating if flow logs are enabled"
  value       = var.enable_flow_logs
}

output "total_subnets" {
  description = "Total number of subnets created"
  value       = length(azurerm_subnet.main)
}

output "total_nsgs" {
  description = "Total number of NSGs created"
  value       = length(azurerm_network_security_group.main)
}