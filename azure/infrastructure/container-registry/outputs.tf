output "id" {
  description = "The ID of the container registry"
  value       = azurerm_container_registry.main.id
}

output "name" {
  description = "The name of the container registry"
  value       = azurerm_container_registry.main.name
}

output "login_server" {
  description = "The login server of the container registry"
  value       = azurerm_container_registry.main.login_server
}

output "admin_username" {
  description = "The admin username of the container registry"
  value       = var.admin_enabled ? azurerm_container_registry.main.admin_username : null
  sensitive   = true
}

output "admin_password" {
  description = "The admin password of the container registry"
  value       = var.admin_enabled ? azurerm_container_registry.main.admin_password : null
  sensitive   = true
}

output "resource_group_name" {
  description = "The resource group name of the container registry"
  value       = azurerm_container_registry.main.resource_group_name
}

output "location" {
  description = "The location of the container registry"
  value       = azurerm_container_registry.main.location
}

output "sku" {
  description = "The SKU of the container registry"
  value       = azurerm_container_registry.main.sku
}

output "identity" {
  description = "The identity of the container registry"
  value       = try(azurerm_container_registry.main.identity[0], null)
}

output "imported_images" {
  description = "Map of imported images"
  value       = var.images_to_import
}