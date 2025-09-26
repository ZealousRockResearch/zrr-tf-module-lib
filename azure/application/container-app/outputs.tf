output "id" {
  description = "The ID of the Container App"
  value       = azurerm_container_app.main.id
}

output "name" {
  description = "The name of the Container App"
  value       = azurerm_container_app.main.name
}

output "location" {
  description = "The location of the Container App"
  value       = azurerm_container_app.main.location
}

output "resource_group_name" {
  description = "The resource group name of the Container App"
  value       = azurerm_container_app.main.resource_group_name
}

output "container_app_environment_id" {
  description = "The Container App Environment ID"
  value       = azurerm_container_app.main.container_app_environment_id
}

output "revision_mode" {
  description = "The revision mode of the Container App"
  value       = azurerm_container_app.main.revision_mode
}

output "latest_revision_name" {
  description = "The name of the latest revision"
  value       = azurerm_container_app.main.latest_revision_name
}

output "latest_revision_fqdn" {
  description = "The FQDN of the latest revision"
  value       = azurerm_container_app.main.latest_revision_fqdn
}

output "outbound_ip_addresses" {
  description = "List of outbound IP addresses"
  value       = azurerm_container_app.main.outbound_ip_addresses
}

output "custom_domain_verification_id" {
  description = "The custom domain verification ID"
  value       = azurerm_container_app.main.custom_domain_verification_id
}

output "identity" {
  description = "The identity of the Container App"
  value       = try(azurerm_container_app.main.identity[0], null)
}

# URLs and endpoints
output "application_url" {
  description = "The main application URL (HTTPS)"
  value       = var.ingress != null && var.ingress.external_enabled ? "https://${azurerm_container_app.main.latest_revision_fqdn}" : null
}

output "application_url_http" {
  description = "The main application URL (HTTP)"
  value       = var.ingress != null && var.ingress.external_enabled && var.ingress.allow_insecure_connections ? "http://${azurerm_container_app.main.latest_revision_fqdn}" : null
}

output "fqdn" {
  description = "The fully qualified domain name"
  value       = azurerm_container_app.main.latest_revision_fqdn
}

# Configuration information
output "ingress_configuration" {
  description = "Ingress configuration details"
  value = var.ingress != null ? {
    external_enabled           = var.ingress.external_enabled
    target_port               = var.ingress.target_port
    exposed_port              = var.ingress.exposed_port
    transport                 = var.ingress.transport
    allow_insecure_connections = var.ingress.allow_insecure_connections
    fqdn                      = azurerm_container_app.main.latest_revision_fqdn
  } : null
}

output "container_configuration" {
  description = "Container configuration details"
  value = {
    containers      = var.containers
    init_containers = var.init_containers
    min_replicas    = var.min_replicas
    max_replicas    = var.max_replicas
    revision_mode   = var.revision_mode
  }
}

# Connection information for integration
output "connection_info" {
  description = "Complete connection information for the Container App"
  value = {
    app_id                        = azurerm_container_app.main.id
    app_name                      = azurerm_container_app.main.name
    fqdn                          = azurerm_container_app.main.latest_revision_fqdn
    latest_revision_name          = azurerm_container_app.main.latest_revision_name
    https_url                     = var.ingress != null && var.ingress.external_enabled ? "https://${azurerm_container_app.main.latest_revision_fqdn}" : null
    http_url                      = var.ingress != null && var.ingress.external_enabled && var.ingress.allow_insecure_connections ? "http://${azurerm_container_app.main.latest_revision_fqdn}" : null
    outbound_ip_addresses         = azurerm_container_app.main.outbound_ip_addresses
    custom_domain_verification_id = azurerm_container_app.main.custom_domain_verification_id
    resource_group_name           = azurerm_container_app.main.resource_group_name
    location                      = azurerm_container_app.main.location
    environment_id                = azurerm_container_app.main.container_app_environment_id
  }
}