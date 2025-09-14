output "container_id" {
  description = "The ID of the storage container"
  value       = module.storage_container_example.id
}

output "container_name" {
  description = "The name of the storage container"
  value       = module.storage_container_example.name
}

output "container_url" {
  description = "The URL of the storage container"
  value       = module.storage_container_example.container_url
}

output "security_features" {
  description = "Security features enabled on the container"
  value       = module.storage_container_example.security_features
}