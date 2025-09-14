output "app_service_plan_id" {
  description = "ID of the created App Service Plan"
  value       = module.app_service_plan_example.id
}

output "app_service_plan_name" {
  description = "Name of the created App Service Plan"
  value       = module.app_service_plan_example.name
}

output "app_service_plan_location" {
  description = "Location of the created App Service Plan"
  value       = module.app_service_plan_example.location
}

output "os_type" {
  description = "Operating system type of the App Service Plan"
  value       = module.app_service_plan_example.os_type
}

output "sku_name" {
  description = "SKU name of the App Service Plan"
  value       = module.app_service_plan_example.sku_name
}

output "worker_count" {
  description = "Number of workers (instances) in the App Service Plan"
  value       = module.app_service_plan_example.worker_count
}

output "app_service_plan_info" {
  description = "Complete App Service Plan information for use by App Services"
  value       = module.app_service_plan_example.app_service_plan_info
}

output "scaling_summary" {
  description = "Summary of scaling configuration"
  value       = module.app_service_plan_example.scaling_summary
}

output "tags" {
  description = "Tags applied to the App Service Plan"
  value       = module.app_service_plan_example.tags
}