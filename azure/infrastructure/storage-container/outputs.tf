# Primary outputs
output "id" {
  description = "The ID of the storage container"
  value       = azurerm_storage_container.main.id
}

output "name" {
  description = "The name of the storage container"
  value       = azurerm_storage_container.main.name
}

output "storage_account_name" {
  description = "The name of the storage account containing the container"
  value       = azurerm_storage_container.main.storage_account_name
}

output "container_access_type" {
  description = "The access type of the container"
  value       = azurerm_storage_container.main.container_access_type
}

output "has_immutability_policy" {
  description = "Whether the container has an immutability policy"
  value       = azurerm_storage_container.main.has_immutability_policy
}

output "has_legal_hold" {
  description = "Whether the container has a legal hold"
  value       = azurerm_storage_container.main.has_legal_hold
}

output "metadata" {
  description = "The metadata assigned to the storage container"
  value       = azurerm_storage_container.main.metadata
}

output "resource_manager_id" {
  description = "The Resource Manager ID of the storage container"
  value       = azurerm_storage_container.main.resource_manager_id
}

# Management policy outputs
output "management_policy_id" {
  description = "The ID of the storage management policy (if created)"
  value       = length(azurerm_storage_management_policy.main) > 0 ? azurerm_storage_management_policy.main[0].id : null
}

output "lifecycle_rules_count" {
  description = "The number of lifecycle rules configured"
  value       = length(var.lifecycle_rules)
}

# Legal hold outputs (configuration only)
output "legal_hold_enabled" {
  description = "Whether legal hold is configured for the container"
  value       = local.legal_hold_enabled
}

output "legal_hold_tags" {
  description = "The legal hold tags (if configured)"
  value       = local.legal_hold_tags_configured
}

# Immutability policy outputs (configuration only)
output "immutability_policy_enabled" {
  description = "Whether immutability policy is configured for the container"
  value       = local.immutability_policy_enabled
}

output "immutability_period_days" {
  description = "The immutability period in days (if configured)"
  value       = local.immutability_period_configured
}

output "immutability_policy_locked" {
  description = "Whether the immutability policy is locked (if configured)"
  value       = local.immutability_locked_configured
}

# Composite outputs for easier consumption
output "container_url" {
  description = "The URL of the storage container"
  value       = "https://${azurerm_storage_container.main.storage_account_name}.blob.core.windows.net/${azurerm_storage_container.main.name}"
}

output "security_features" {
  description = "Summary of security features enabled on the container"
  value = {
    has_legal_hold          = local.legal_hold_enabled
    has_immutability_policy = local.immutability_policy_enabled
    access_type             = azurerm_storage_container.main.container_access_type
    lifecycle_rules_count   = length(var.lifecycle_rules)
  }
}