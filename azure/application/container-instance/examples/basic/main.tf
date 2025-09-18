module "container_instance_basic" {
  source = "../../"

  name                = var.container_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Basic container configuration
  containers = var.containers

  # Network configuration
  ip_address_type = var.ip_address_type
  exposed_ports   = var.exposed_ports
  dns_name_label  = var.dns_name_label

  # OS and runtime
  os_type        = var.os_type
  restart_policy = var.restart_policy

  # Tags
  common_tags             = var.common_tags
  container_instance_tags = var.container_instance_tags
}

# Output all key values for reference
output "container_group_id" {
  description = "ID of the container group"
  value       = module.container_instance_basic.id
}

output "container_group_name" {
  description = "Name of the container group"
  value       = module.container_instance_basic.name
}

output "ip_address" {
  description = "IP address of the container group"
  value       = module.container_instance_basic.ip_address
}

output "fqdn" {
  description = "Fully qualified domain name"
  value       = module.container_instance_basic.fqdn
}

output "dns_name_label" {
  description = "DNS name label"
  value       = module.container_instance_basic.dns_name_label
}

output "containers" {
  description = "Container information"
  value       = module.container_instance_basic.containers
}

output "container_count" {
  description = "Number of containers"
  value       = module.container_instance_basic.container_count
}

output "total_cpu_allocation" {
  description = "Total CPU allocation"
  value       = module.container_instance_basic.total_cpu_allocation
}

output "total_memory_allocation" {
  description = "Total memory allocation (GB)"
  value       = module.container_instance_basic.total_memory_allocation
}

output "tags" {
  description = "Tags applied to resources"
  value       = module.container_instance_basic.tags
}