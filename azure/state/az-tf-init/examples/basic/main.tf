# Basic Azure Terraform State Initialization Example
# This example demonstrates a simple setup for development and testing environments

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Basic Terraform State Infrastructure
module "terraform_state" {
  source = "../../"

  # Required variables
  project_name = var.project_name
  environment  = var.environment
  location     = var.location

  # Basic storage configuration suitable for development
  storage_account_tier     = "Standard"
  storage_replication_type = "LRS" # Locally redundant storage for cost efficiency

  # Enable essential features
  enable_state_locking   = true
  enable_blob_versioning = true

  # Security settings - reasonable defaults for development
  enable_shared_access_key             = true
  enable_public_network_access         = true
  blob_soft_delete_retention_days      = 7
  container_soft_delete_retention_days = 7

  # Naming convention
  use_naming_convention = true
  location_short        = var.location_short
  container_name        = "tfstate"

  # Basic tagging
  common_tags = var.common_tags

  az_tf_init_tags = {
    Purpose     = "terraform-state-management"
    Environment = var.environment
    Tier        = "basic"
  }
}

# Output the backend configuration for use in other projects
output "terraform_backend_config" {
  description = "Backend configuration for Terraform state"
  value       = module.terraform_state.terraform_backend_config
}

output "terraform_backend_hcl" {
  description = "HCL snippet for backend configuration"
  value       = module.terraform_state.terraform_backend_hcl
}

output "storage_account_name" {
  description = "Name of the created storage account"
  value       = module.terraform_state.storage_account_name
}

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = module.terraform_state.resource_group_name
}

output "container_name" {
  description = "Name of the state container"
  value       = module.terraform_state.container_name
}

output "access_instructions" {
  description = "Instructions for accessing the Terraform state backend"
  value       = module.terraform_state.access_instructions
}