module "app_service_plan_example" {
  source = "../../"

  name                = "example-service-plan"
  resource_group_name = var.resource_group_name
  location            = var.location

  # Basic configuration
  os_type  = var.os_type
  sku_name = var.sku_name

  # Optional scaling configuration
  worker_count             = var.worker_count
  per_site_scaling_enabled = var.per_site_scaling_enabled

  common_tags = var.common_tags

  application_plan_tags = var.application_plan_tags
}