# Primary outputs
output "id" {
  description = "ID of the key vault secret"
  value       = azurerm_key_vault_secret.main.id
}

output "name" {
  description = "Name of the key vault secret"
  value       = azurerm_key_vault_secret.main.name
}

output "version" {
  description = "The current version of the key vault secret"
  value       = azurerm_key_vault_secret.main.version
}

output "versionless_id" {
  description = "The versionless ID of the key vault secret"
  value       = azurerm_key_vault_secret.main.versionless_id
}

output "resource_id" {
  description = "The resource ID of the key vault secret"
  value       = azurerm_key_vault_secret.main.resource_id
}

output "resource_versionless_id" {
  description = "The versionless resource ID of the key vault secret"
  value       = azurerm_key_vault_secret.main.resource_versionless_id
}

output "key_vault_id" {
  description = "ID of the key vault containing the secret"
  value       = local.key_vault_id
}

output "tags" {
  description = "Tags applied to the key vault secret"
  value       = azurerm_key_vault_secret.main.tags
}