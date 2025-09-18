# Primary container group outputs
output "id" {
  description = "ID of the container group"
  value       = azurerm_container_group.main.id
}

output "name" {
  description = "Name of the container group"
  value       = azurerm_container_group.main.name
}

output "resource_group_name" {
  description = "Resource group name containing the container group"
  value       = local.resource_group_name
}

output "location" {
  description = "Location of the container group"
  value       = azurerm_container_group.main.location
}

# Network and connectivity outputs
output "ip_address" {
  description = "IP address of the container group"
  value       = azurerm_container_group.main.ip_address
}

output "fqdn" {
  description = "Fully qualified domain name of the container group"
  value       = azurerm_container_group.main.fqdn
}

output "dns_name_label" {
  description = "DNS name label of the container group"
  value       = local.dns_name_label
}

output "ip_address_type" {
  description = "IP address type of the container group"
  value       = azurerm_container_group.main.ip_address_type
}

output "subnet_ids" {
  description = "Subnet IDs assigned to the container group"
  value       = azurerm_container_group.main.subnet_ids
}

# Container information
output "containers" {
  description = "Information about containers in the group"
  value = {
    for idx, container in var.containers : container.name => {
      image  = container.image
      cpu    = container.cpu
      memory = container.memory
      ports  = container.ports
    }
  }
}

output "container_count" {
  description = "Number of containers in the group"
  value       = length(var.containers)
}

output "primary_container_name" {
  description = "Name of the primary (first) container"
  value       = var.containers[0].name
}

# Resource configuration outputs
output "os_type" {
  description = "Operating system type of the container group"
  value       = azurerm_container_group.main.os_type
}

output "restart_policy" {
  description = "Restart policy of the container group"
  value       = azurerm_container_group.main.restart_policy
}

# Registry configuration
output "container_registry_configured" {
  description = "Whether a container registry is configured"
  value       = var.container_registry_name != null
}

output "container_registry_server" {
  description = "Container registry server URL"
  value       = var.container_registry_name != null ? data.azurerm_container_registry.acr[0].login_server : null
}

output "additional_registries_count" {
  description = "Number of additional image registries configured"
  value       = length(var.additional_image_registries)
  sensitive   = true
}

# Volume configuration
output "volumes_configured" {
  description = "Information about configured volumes"
  value = {
    for volume in var.volumes : volume.name => {
      mount_path           = volume.mount_path
      read_only            = volume.read_only
      empty_dir            = volume.empty_dir
      storage_account_name = volume.storage_account_name != null ? volume.storage_account_name : null
      share_name           = volume.share_name
      has_git_repo         = volume.git_repo != null
      has_secrets          = length(volume.secret) > 0
    }
  }
}

output "volume_count" {
  description = "Number of volumes configured"
  value       = length(var.volumes)
}

# Identity outputs
output "identity" {
  description = "Managed identity information"
  value = var.managed_identity != null ? {
    type         = azurerm_container_group.main.identity[0].type
    principal_id = azurerm_container_group.main.identity[0].principal_id
    tenant_id    = azurerm_container_group.main.identity[0].tenant_id
    identity_ids = azurerm_container_group.main.identity[0].identity_ids
  } : null
}

output "has_managed_identity" {
  description = "Whether managed identity is configured"
  value       = var.managed_identity != null
}

# Monitoring outputs
output "monitoring_enabled" {
  description = "Whether monitoring is enabled"
  value       = var.enable_monitoring
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = var.enable_monitoring ? azurerm_log_analytics_workspace.container_logs[0].workspace_id : null
}

output "log_analytics_workspace_key" {
  description = "Log Analytics workspace key"
  value       = var.enable_monitoring ? azurerm_log_analytics_workspace.container_logs[0].primary_shared_key : null
  sensitive   = true
}

output "cpu_alert_id" {
  description = "ID of the CPU metric alert"
  value       = var.enable_monitoring && var.cpu_alert_threshold > 0 ? azurerm_monitor_metric_alert.container_cpu[0].id : null
}

output "memory_alert_id" {
  description = "ID of the memory metric alert"
  value       = var.enable_monitoring && var.memory_alert_threshold > 0 ? azurerm_monitor_metric_alert.container_memory[0].id : null
}

output "alert_thresholds" {
  description = "Configured alert thresholds"
  value = {
    cpu_threshold    = var.cpu_alert_threshold
    memory_threshold = var.memory_alert_threshold
  }
}

# Naming convention outputs
output "naming_convention_used" {
  description = "Whether naming convention was used"
  value       = var.use_naming_convention
}

output "container_name_details" {
  description = "Container group naming details"
  value = {
    original_name     = var.name
    final_name        = local.container_group_name
    environment       = var.environment
    location_short    = var.location_short
    naming_convention = var.use_naming_convention
  }
}

# Network security outputs
output "private_deployment" {
  description = "Whether this is a private deployment"
  value       = local.is_private_deployment
}

output "subnet_id" {
  description = "Subnet ID for private deployment"
  value       = var.subnet_id
}

output "exposed_ports" {
  description = "List of exposed ports"
  value       = local.exposed_ports
}

# DNS configuration outputs
output "dns_config" {
  description = "DNS configuration details"
  value = var.dns_config != null ? {
    nameservers    = var.dns_config.nameservers
    search_domains = var.dns_config.search_domains
    options        = var.dns_config.options
  } : null
}

# Resource usage outputs
output "total_cpu_allocation" {
  description = "Total CPU allocation across all containers"
  value       = sum([for container in var.containers : container.cpu])
}

output "total_memory_allocation" {
  description = "Total memory allocation across all containers (GB)"
  value       = sum([for container in var.containers : container.memory])
}

output "gpu_enabled_containers" {
  description = "Number of containers with GPU resources"
  value       = length([for container in var.containers : container if container.gpu != null])
}

# Security outputs
output "secure_environment_variables_count" {
  description = "Total number of secure environment variables across all containers"
  value = sum([
    for container in var.containers :
    container.secure_environment_variables != null ? length(container.secure_environment_variables) : 0
  ])
  sensitive = true
}

output "environment_variables_count" {
  description = "Total number of environment variables across all containers"
  value = sum([
    for container in var.containers :
    container.environment_variables != null ? length(container.environment_variables) : 0
  ])
}

# Health check outputs
output "containers_with_liveness_probes" {
  description = "Number of containers with liveness probes"
  value       = length([for container in var.containers : container if container.liveness_probe != null])
}

output "containers_with_readiness_probes" {
  description = "Number of containers with readiness probes"
  value       = length([for container in var.containers : container if container.readiness_probe != null])
}

# Tags output
output "tags" {
  description = "Tags applied to the container group"
  value       = local.common_tags
}

# Container group summary
output "container_group_summary" {
  description = "Comprehensive summary of the container group configuration"
  value = {
    name                 = azurerm_container_group.main.name
    resource_group       = local.resource_group_name
    location             = azurerm_container_group.main.location
    ip_address           = azurerm_container_group.main.ip_address
    fqdn                 = azurerm_container_group.main.fqdn
    os_type              = azurerm_container_group.main.os_type
    restart_policy       = azurerm_container_group.main.restart_policy
    container_count      = length(var.containers)
    total_cpu            = sum([for container in var.containers : container.cpu])
    total_memory         = sum([for container in var.containers : container.memory])
    private_deployment   = local.is_private_deployment
    monitoring_enabled   = var.enable_monitoring
    has_managed_identity = var.managed_identity != null
    volume_count         = length(var.volumes)
    registry_configured  = var.container_registry_name != null
  }
  sensitive = false
}