module "vnet_example" {
  source = "../../"

  name                = "example-vnet"
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]

  environment           = var.environment
  location_short        = var.location_short
  use_naming_convention = true

  subnets = [
    {
      name              = "subnet-web"
      address_prefixes  = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    },
    {
      name              = "subnet-app"
      address_prefixes  = ["10.0.2.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    },
    {
      name                              = "subnet-data"
      address_prefixes                  = ["10.0.3.0/24"]
      private_endpoint_network_policies = "Enabled"
    }
  ]

  # Create default NSG rules for security
  create_default_nsg_rules = true

  common_tags = var.common_tags

  vnet_tags = {
    Example = "basic"
    Module  = "vnet"
    Tier    = "standard"
  }
}

# Outputs for verification
output "vnet_id" {
  description = "ID of the created virtual network"
  value       = module.vnet_example.vnet_id
}

output "vnet_name" {
  description = "Name of the created virtual network"
  value       = module.vnet_example.vnet_name
}

output "vnet_address_space" {
  description = "Address space of the virtual network"
  value       = module.vnet_example.vnet_address_space
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.vnet_example.subnet_ids
}

output "nsg_ids" {
  description = "Map of NSG names to their IDs"
  value       = module.vnet_example.nsg_ids
}

output "total_subnets" {
  description = "Total number of subnets created"
  value       = module.vnet_example.total_subnets
}