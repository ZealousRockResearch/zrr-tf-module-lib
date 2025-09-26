output "id" {
  description = "The ID of the Container App Environment"
  value       = azurerm_container_app_environment.main.id
}

output "name" {
  description = "The name of the Container App Environment"
  value       = azurerm_container_app_environment.main.name
}

output "default_domain" {
  description = "The default domain of the Container App Environment"
  value       = azurerm_container_app_environment.main.default_domain
}

output "docker_bridge_cidr" {
  description = "The Docker bridge CIDR of the Container App Environment"
  value       = azurerm_container_app_environment.main.docker_bridge_cidr
}

output "platform_reserved_cidr" {
  description = "The platform reserved CIDR of the Container App Environment"
  value       = azurerm_container_app_environment.main.platform_reserved_cidr
}

output "platform_reserved_dns_ip_address" {
  description = "The platform reserved DNS IP address of the Container App Environment"
  value       = azurerm_container_app_environment.main.platform_reserved_dns_ip_address
}

output "static_ip_address" {
  description = "The static IP address of the Container App Environment"
  value       = azurerm_container_app_environment.main.static_ip_address
}

output "location" {
  description = "The location of the Container App Environment"
  value       = azurerm_container_app_environment.main.location
}

output "resource_group_name" {
  description = "The resource group name of the Container App Environment"
  value       = azurerm_container_app_environment.main.resource_group_name
}

output "log_analytics_workspace_id" {
  description = "The Log Analytics workspace ID"
  value       = azurerm_container_app_environment.main.log_analytics_workspace_id
}

output "infrastructure_subnet_id" {
  description = "The infrastructure subnet ID"
  value       = azurerm_container_app_environment.main.infrastructure_subnet_id
}

output "internal_load_balancer_enabled" {
  description = "Whether internal load balancer is enabled"
  value       = azurerm_container_app_environment.main.internal_load_balancer_enabled
}

output "zone_redundancy_enabled" {
  description = "Whether zone redundancy is enabled"
  value       = azurerm_container_app_environment.main.zone_redundancy_enabled
}

output "storage_accounts" {
  description = "Map of configured storage accounts"
  value       = { for k, v in azurerm_container_app_environment_storage.storage : k => v.id }
}

output "certificates" {
  description = "Map of configured certificates"
  value       = { for k, v in azurerm_container_app_environment_certificate.certificates : k => v.id }
}

output "dapr_components" {
  description = "Map of configured Dapr components"
  value       = { for k, v in azurerm_container_app_environment_dapr_component.dapr_components : k => v.id }
}

# Connection information for Container Apps
output "connection_info" {
  description = "Connection information for Container Apps"
  value = {
    environment_id                        = azurerm_container_app_environment.main.id
    environment_name                      = azurerm_container_app_environment.main.name
    default_domain                        = azurerm_container_app_environment.main.default_domain
    static_ip_address                     = azurerm_container_app_environment.main.static_ip_address
    platform_reserved_dns_ip_address     = azurerm_container_app_environment.main.platform_reserved_dns_ip_address
    location                             = azurerm_container_app_environment.main.location
    resource_group_name                  = azurerm_container_app_environment.main.resource_group_name
    log_analytics_workspace_id           = azurerm_container_app_environment.main.log_analytics_workspace_id
  }
}