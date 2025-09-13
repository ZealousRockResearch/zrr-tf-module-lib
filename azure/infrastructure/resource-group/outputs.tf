# Primary outputs
output "id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# Tags output
output "tags" {
  description = "Tags applied to the resource group"
  value       = azurerm_resource_group.main.tags
}

# Subscription information
output "subscription_id" {
  description = "Subscription ID where the resource group is created"
  value       = data.azurerm_subscription.current.subscription_id
}

output "tenant_id" {
  description = "Tenant ID of the subscription"
  value       = data.azurerm_subscription.current.tenant_id
}

# Lock information
output "lock_id" {
  description = "ID of the resource lock (if enabled)"
  value       = try(azurerm_management_lock.resource_group_lock[0].id, null)
}

output "lock_level" {
  description = "Lock level applied to the resource group"
  value       = try(azurerm_management_lock.resource_group_lock[0].lock_level, null)
}

# Budget information
output "budget_id" {
  description = "ID of the budget alert (if enabled)"
  value       = try(azurerm_consumption_budget_resource_group.budget[0].id, null)
}

output "budget_amount" {
  description = "Budget amount configured for the resource group"
  value       = try(azurerm_consumption_budget_resource_group.budget[0].amount, null)
}

# Computed values
output "resource_group_urn" {
  description = "Uniform Resource Name for the resource group"
  value       = "urn:azure:resource-group:${data.azurerm_subscription.current.subscription_id}:${azurerm_resource_group.main.name}"
}

output "is_locked" {
  description = "Boolean indicating if the resource group has a lock"
  value       = var.enable_resource_lock
}

output "has_budget_alert" {
  description = "Boolean indicating if the resource group has a budget alert"
  value       = var.enable_budget_alert
}