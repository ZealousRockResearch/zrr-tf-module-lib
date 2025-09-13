# Primary outputs
output "id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "resource_group_name" {
  description = "Name of the resource group containing the Key Vault"
  value       = azurerm_key_vault.main.resource_group_name
}

output "location" {
  description = "Location of the Key Vault"
  value       = azurerm_key_vault.main.location
}

output "tenant_id" {
  description = "Tenant ID of the Key Vault"
  value       = azurerm_key_vault.main.tenant_id
}

# Secret outputs
output "secret_ids" {
  description = "Map of secret names to their IDs"
  value       = { for k, v in azurerm_key_vault_secret.main : k => v.id }
  sensitive   = true
}

output "secret_versions" {
  description = "Map of secret names to their versions"
  value       = { for k, v in azurerm_key_vault_secret.main : k => v.version }
  sensitive   = true
}

output "secret_version_ids" {
  description = "Map of secret names to their version IDs"
  value       = { for k, v in azurerm_key_vault_secret.main : k => v.versionless_id }
  sensitive   = true
}

# Key outputs
output "key_ids" {
  description = "Map of key names to their IDs"
  value       = { for k, v in azurerm_key_vault_key.main : k => v.id }
}

output "key_versions" {
  description = "Map of key names to their versions"
  value       = { for k, v in azurerm_key_vault_key.main : k => v.version }
}

output "key_version_ids" {
  description = "Map of key names to their version IDs"
  value       = { for k, v in azurerm_key_vault_key.main : k => v.versionless_id }
}

# Private endpoint outputs
output "private_endpoint_id" {
  description = "ID of the private endpoint (if created)"
  value       = var.private_endpoint != null ? azurerm_private_endpoint.main[0].id : null
}

output "private_endpoint_ip_address" {
  description = "Private IP address of the private endpoint (if created)"
  value       = var.private_endpoint != null ? azurerm_private_endpoint.main[0].private_service_connection[0].private_ip_address : null
}

# Diagnostic setting outputs
output "diagnostic_setting_id" {
  description = "ID of the diagnostic setting (if created)"
  value       = var.diagnostic_setting != null ? azurerm_monitor_diagnostic_setting.main[0].id : null
}

# Access policy outputs
output "access_policy_object_ids" {
  description = "List of object IDs that have access policies configured"
  value       = [for policy in azurerm_key_vault_access_policy.main : policy.object_id]
}

output "tags" {
  description = "Tags applied to the Key Vault"
  value       = azurerm_key_vault.main.tags
}