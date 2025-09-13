module "resource_group_example" {
  source = "../../"

  name     = "example-resource-group"
  location = var.location

  environment           = var.environment
  location_short        = var.location_short
  use_naming_convention = true

  common_tags = var.common_tags

  resource_group_tags = {
    Example = "basic"
    Module  = "resource-group"
  }
}

# Outputs for verification
output "resource_group_id" {
  description = "ID of the created resource group"
  value       = module.resource_group_example.id
}

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = module.resource_group_example.name
}

output "resource_group_location" {
  description = "Location of the created resource group"
  value       = module.resource_group_example.location
}

output "resource_group_tags" {
  description = "Tags applied to the resource group"
  value       = module.resource_group_example.tags
}