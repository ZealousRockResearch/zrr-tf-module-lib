module "container_instance_advanced" {
  source = "../../"

  name                = var.container_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Multi-container configuration
  containers = var.containers

  # Network configuration
  ip_address_type = var.ip_address_type
  subnet_id       = var.subnet_id
  exposed_ports   = var.exposed_ports
  dns_name_label  = var.dns_name_label
  dns_config      = var.dns_config

  # OS and runtime
  os_type        = var.os_type
  restart_policy = var.restart_policy

  # Container registry
  container_registry_name           = var.container_registry_name
  container_registry_resource_group = var.container_registry_resource_group
  container_registry_username       = var.container_registry_username
  container_registry_password       = var.container_registry_password
  additional_image_registries       = var.additional_image_registries

  # Volumes
  volumes = var.volumes

  # Identity
  managed_identity = var.managed_identity

  # Monitoring
  enable_monitoring      = var.enable_monitoring
  log_analytics_sku      = var.log_analytics_sku
  log_retention_days     = var.log_retention_days
  action_group_id        = var.action_group_id
  cpu_alert_threshold    = var.cpu_alert_threshold
  memory_alert_threshold = var.memory_alert_threshold

  # Naming convention
  use_naming_convention = var.use_naming_convention
  environment           = var.environment
  location_short        = var.location_short

  # Tags
  common_tags             = var.common_tags
  container_instance_tags = var.container_instance_tags
}

# Output all key values for reference
output "container_group_id" {
  description = "ID of the container group"
  value       = module.container_instance_advanced.id
}

output "container_group_name" {
  description = "Name of the container group"
  value       = module.container_instance_advanced.name
}

output "ip_address" {
  description = "IP address of the container group"
  value       = module.container_instance_advanced.ip_address
}

output "fqdn" {
  description = "Fully qualified domain name"
  value       = module.container_instance_advanced.fqdn
}

output "dns_name_label" {
  description = "DNS name label"
  value       = module.container_instance_advanced.dns_name_label
}

output "containers" {
  description = "Container information"
  value       = module.container_instance_advanced.containers
}

output "container_count" {
  description = "Number of containers"
  value       = module.container_instance_advanced.container_count
}

output "primary_container_name" {
  description = "Name of the primary container"
  value       = module.container_instance_advanced.primary_container_name
}

output "total_cpu_allocation" {
  description = "Total CPU allocation"
  value       = module.container_instance_advanced.total_cpu_allocation
}

output "total_memory_allocation" {
  description = "Total memory allocation (GB)"
  value       = module.container_instance_advanced.total_memory_allocation
}

output "private_deployment" {
  description = "Whether this is a private deployment"
  value       = module.container_instance_advanced.private_deployment
}

output "monitoring_enabled" {
  description = "Whether monitoring is enabled"
  value       = module.container_instance_advanced.monitoring_enabled
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = module.container_instance_advanced.log_analytics_workspace_id
}

output "cpu_alert_id" {
  description = "CPU alert ID"
  value       = module.container_instance_advanced.cpu_alert_id
}

output "memory_alert_id" {
  description = "Memory alert ID"
  value       = module.container_instance_advanced.memory_alert_id
}

output "identity" {
  description = "Managed identity information"
  value       = module.container_instance_advanced.identity
}

output "has_managed_identity" {
  description = "Whether managed identity is configured"
  value       = module.container_instance_advanced.has_managed_identity
}

output "volumes_configured" {
  description = "Information about configured volumes"
  value       = module.container_instance_advanced.volumes_configured
}

output "volume_count" {
  description = "Number of volumes configured"
  value       = module.container_instance_advanced.volume_count
}

output "container_registry_configured" {
  description = "Whether container registry is configured"
  value       = module.container_instance_advanced.container_registry_configured
}

output "container_registry_server" {
  description = "Container registry server URL"
  value       = module.container_instance_advanced.container_registry_server
}

output "containers_with_liveness_probes" {
  description = "Number of containers with liveness probes"
  value       = module.container_instance_advanced.containers_with_liveness_probes
}

output "containers_with_readiness_probes" {
  description = "Number of containers with readiness probes"
  value       = module.container_instance_advanced.containers_with_readiness_probes
}

output "gpu_enabled_containers" {
  description = "Number of containers with GPU resources"
  value       = module.container_instance_advanced.gpu_enabled_containers
}

output "naming_convention_used" {
  description = "Whether naming convention was used"
  value       = module.container_instance_advanced.naming_convention_used
}

output "container_name_details" {
  description = "Container group naming details"
  value       = module.container_instance_advanced.container_name_details
}

output "container_group_summary" {
  description = "Comprehensive container group summary"
  value       = module.container_instance_advanced.container_group_summary
}

output "tags" {
  description = "Tags applied to resources"
  value       = module.container_instance_advanced.tags
}