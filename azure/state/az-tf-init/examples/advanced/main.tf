# Advanced Enterprise Azure Terraform State Initialization Example
# This example demonstrates comprehensive enterprise features including:
# - High availability storage with geo-redundancy
# - Network security restrictions
# - Key Vault integration for encryption
# - Comprehensive monitoring and diagnostics
# - RBAC assignments for team access
# - Enhanced data protection and compliance

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

# Data sources for current context
data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

# Example VNet and subnet for network restrictions
resource "azurerm_virtual_network" "example" {
  name                = "vnet-tfstate-example"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = "rg-network-example" # Assume this exists

  tags = var.common_tags
}

resource "azurerm_subnet" "terraform_subnet" {
  name                 = "snet-terraform"
  resource_group_name  = azurerm_virtual_network.example.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

# Advanced Enterprise Terraform State Infrastructure
module "terraform_state" {
  source = "../../"

  # Required variables
  project_name = var.project_name
  environment  = var.environment
  location     = var.location

  # Enterprise storage configuration
  storage_account_tier     = "Standard"
  storage_replication_type = "GZRS" # Geo-zone-redundant for maximum availability

  # Enable all enterprise features
  enable_state_locking   = true
  enable_blob_versioning = true
  enable_key_vault       = true
  enable_monitoring      = true

  # Enhanced security settings
  enable_shared_access_key     = false # Disable for security - use RBAC only
  enable_public_network_access = false # Private access only

  # Network security restrictions
  enable_network_restrictions = true
  network_default_action      = "Deny"
  allowed_ip_ranges           = var.allowed_ip_ranges
  allowed_subnet_ids          = [azurerm_subnet.terraform_subnet.id]

  # Data protection settings
  blob_soft_delete_retention_days      = 90 # Extended retention for compliance
  container_soft_delete_retention_days = 90

  # Key Vault configuration
  key_vault_sku                        = "premium" # Premium for HSM support
  enable_key_vault_rbac                = true
  enable_key_vault_purge_protection    = true # Prevent permanent deletion
  key_vault_soft_delete_retention_days = 90

  # Key Vault network restrictions
  enable_key_vault_network_restrictions = true
  key_vault_network_default_action      = "Deny"
  key_vault_allowed_ip_ranges           = var.allowed_ip_ranges
  key_vault_allowed_subnet_ids          = [azurerm_subnet.terraform_subnet.id]

  # RBAC assignments for team access
  storage_contributors = var.terraform_contributors
  storage_readers      = var.terraform_readers

  key_vault_administrators = var.terraform_admins
  key_vault_users          = var.terraform_users

  # Monitoring configuration
  log_analytics_sku            = "PerGB2018"
  log_analytics_retention_days = 90

  # Naming convention
  use_naming_convention = true
  location_short        = var.location_short
  container_name        = "tfstate"

  # Enterprise tagging strategy
  common_tags = var.common_tags

  az_tf_init_tags = {
    Purpose        = "terraform-state-management"
    Environment    = var.environment
    Tier           = "enterprise"
    Compliance     = "required"
    DataClass      = "confidential"
    BackupRequired = "yes"
    Monitoring     = "enhanced"
    NetworkAccess  = "private"
  }
}

# Create example service principal for automation (optional)
resource "azurerm_user_assigned_identity" "terraform_automation" {
  count = var.create_automation_identity ? 1 : 0

  name                = "id-terraform-automation"
  location            = var.location
  resource_group_name = module.terraform_state.resource_group_name

  tags = var.common_tags
}

# Grant the automation identity access to state resources
resource "azurerm_role_assignment" "automation_storage" {
  count = var.create_automation_identity ? 1 : 0

  scope                = module.terraform_state.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.terraform_automation[0].principal_id
}

resource "azurerm_role_assignment" "automation_key_vault" {
  count = var.create_automation_identity ? 1 : 0

  scope                = module.terraform_state.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.terraform_automation[0].principal_id
}

# Comprehensive outputs for enterprise use
output "terraform_backend_config" {
  description = "Complete backend configuration for enterprise use"
  value       = module.terraform_state.terraform_backend_config
}

output "terraform_backend_hcl" {
  description = "HCL snippet for backend configuration"
  value       = module.terraform_state.terraform_backend_hcl
}

output "terraform_backend_command" {
  description = "Complete terraform init command with backend config"
  value       = module.terraform_state.terraform_backend_command
}

output "storage_account_details" {
  description = "Storage account information"
  value = {
    id                    = module.terraform_state.storage_account_id
    name                  = module.terraform_state.storage_account_name
    resource_group_name   = module.terraform_state.resource_group_name
    location              = module.terraform_state.resource_group_location
    primary_blob_endpoint = module.terraform_state.storage_account_primary_blob_endpoint
  }
}

output "key_vault_details" {
  description = "Key Vault information"
  value = {
    id   = module.terraform_state.key_vault_id
    name = module.terraform_state.key_vault_name
    uri  = module.terraform_state.key_vault_uri
  }
}

output "monitoring_details" {
  description = "Monitoring and diagnostics information"
  value = {
    log_analytics_workspace_id   = module.terraform_state.log_analytics_workspace_id
    log_analytics_workspace_name = module.terraform_state.log_analytics_workspace_name
  }
}

output "access_instructions" {
  description = "Comprehensive access instructions for enterprise teams"
  value = {
    general_instructions = module.terraform_state.access_instructions

    rbac_assignments = {
      storage_contributors = "Users with Storage Blob Data Contributor role can read/write state files"
      storage_readers      = "Users with Storage Blob Data Reader role can read state files"
      key_vault_admins     = "Users with Key Vault Administrator role can manage keys and secrets"
      key_vault_users      = "Users with Key Vault Secrets User role can access secrets"
    }

    network_access = {
      allowed_ips     = var.allowed_ip_ranges
      allowed_subnets = [azurerm_subnet.terraform_subnet.id]
      access_method   = "Private network access only - VPN or private connectivity required"
    }

    automation_identity = var.create_automation_identity ? {
      name         = azurerm_user_assigned_identity.terraform_automation[0].name
      client_id    = azurerm_user_assigned_identity.terraform_automation[0].client_id
      principal_id = azurerm_user_assigned_identity.terraform_automation[0].principal_id
      usage        = "Use this managed identity for CI/CD pipelines and automation"
    } : null
  }
}

output "security_summary" {
  description = "Security configuration summary"
  value = {
    storage_security = {
      shared_access_keys_disabled  = true
      public_access_disabled       = true
      network_restrictions_enabled = true
      blob_versioning_enabled      = true
      soft_delete_retention_days   = 90
    }

    key_vault_security = {
      sku                   = "premium"
      rbac_enabled          = true
      purge_protection      = true
      network_restrictions  = true
      soft_delete_retention = 90
    }

    compliance_features = [
      "Data encryption at rest and in transit",
      "Network isolation and access controls",
      "Comprehensive audit logging",
      "Role-based access control (RBAC)",
      "Data retention and backup policies",
      "Monitoring and alerting capabilities"
    ]
  }
}

output "configuration_summary" {
  description = "Complete configuration summary"
  value       = module.terraform_state.configuration_summary
}