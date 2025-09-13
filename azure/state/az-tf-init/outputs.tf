# azure-state-az-tf-init module outputs
# Description: Output values for the Azure Terraform state initialization module

# Resource Group outputs
output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.tfstate.id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.tfstate.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.tfstate.location
}

# Storage Account outputs
output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.tfstate.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.tfstate.name
}

output "storage_account_primary_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.tfstate.primary_access_key
  sensitive   = true
}

output "storage_account_secondary_key" {
  description = "Secondary access key for the storage account"
  value       = azurerm_storage_account.tfstate.secondary_access_key
  sensitive   = true
}

output "storage_account_primary_connection_string" {
  description = "Primary connection string for the storage account"
  value       = azurerm_storage_account.tfstate.primary_connection_string
  sensitive   = true
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint for the storage account"
  value       = azurerm_storage_account.tfstate.primary_blob_endpoint
}

# Container outputs
output "container_name" {
  description = "Name of the state container"
  value       = azurerm_storage_container.tfstate.name
}

output "container_id" {
  description = "ID of the state container"
  value       = azurerm_storage_container.tfstate.id
}

output "state_lock_container_name" {
  description = "Name of the state locking container"
  value       = var.enable_state_locking ? azurerm_storage_container.tfstate_locks[0].name : null
}

output "state_lock_container_id" {
  description = "ID of the state locking container"
  value       = var.enable_state_locking ? azurerm_storage_container.tfstate_locks[0].id : null
}

# Key Vault outputs
output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = var.enable_key_vault ? azurerm_key_vault.tfstate[0].id : null
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = var.enable_key_vault ? azurerm_key_vault.tfstate[0].name : null
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = var.enable_key_vault ? azurerm_key_vault.tfstate[0].vault_uri : null
}

# Monitoring outputs
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = var.enable_monitoring ? azurerm_log_analytics_workspace.tfstate[0].id : null
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = var.enable_monitoring ? azurerm_log_analytics_workspace.tfstate[0].name : null
}

output "log_analytics_workspace_key" {
  description = "Primary shared key for the Log Analytics workspace"
  value       = var.enable_monitoring ? azurerm_log_analytics_workspace.tfstate[0].primary_shared_key : null
  sensitive   = true
}

# Terraform backend configuration
output "terraform_backend_config" {
  description = "Terraform backend configuration for use in other projects"
  value = {
    resource_group_name  = azurerm_resource_group.tfstate.name
    storage_account_name = azurerm_storage_account.tfstate.name
    container_name       = azurerm_storage_container.tfstate.name
    key                  = "terraform.tfstate" # Default state file name

    # Optional: state locking configuration
    use_state_locking = var.enable_state_locking
    lock_container    = var.enable_state_locking ? azurerm_storage_container.tfstate_locks[0].name : null

    # Optional: encryption configuration
    use_key_vault = var.enable_key_vault
    key_vault_uri = var.enable_key_vault ? azurerm_key_vault.tfstate[0].vault_uri : null
  }
}

# Generated configuration snippets
output "terraform_backend_hcl" {
  description = "HCL configuration snippet for Terraform backend"
  value       = <<-EOF
    terraform {
      backend "azurerm" {
        resource_group_name  = "${azurerm_resource_group.tfstate.name}"
        storage_account_name = "${azurerm_storage_account.tfstate.name}"
        container_name       = "${azurerm_storage_container.tfstate.name}"
        key                  = "terraform.tfstate"
      }
    }
  EOF
}

output "terraform_backend_command" {
  description = "Terraform init command with backend configuration"
  value       = "terraform init -backend-config=\"resource_group_name=${azurerm_resource_group.tfstate.name}\" -backend-config=\"storage_account_name=${azurerm_storage_account.tfstate.name}\" -backend-config=\"container_name=${azurerm_storage_container.tfstate.name}\" -backend-config=\"key=terraform.tfstate\""
}

# Access instructions
output "access_instructions" {
  description = "Instructions for accessing and using the Terraform state backend"
  value = {
    storage_account = {
      name           = azurerm_storage_account.tfstate.name
      resource_group = azurerm_resource_group.tfstate.name
      location       = azurerm_resource_group.tfstate.location
    }
    container = {
      name = azurerm_storage_container.tfstate.name
      url  = "${azurerm_storage_account.tfstate.primary_blob_endpoint}${azurerm_storage_container.tfstate.name}"
    }
    key_vault = var.enable_key_vault ? {
      name = azurerm_key_vault.tfstate[0].name
      uri  = azurerm_key_vault.tfstate[0].vault_uri
    } : null
    rbac_requirements = {
      storage_contributor_required = "Users need 'Storage Blob Data Contributor' role on the storage account"
      key_vault_access_required    = var.enable_key_vault ? "Users need appropriate Key Vault access roles if enabled" : null
    }
  }
}

# Configuration validation outputs
output "configuration_summary" {
  description = "Summary of the configuration applied"
  value = {
    project_name            = var.project_name
    environment             = var.environment
    location                = var.location
    naming_convention_used  = var.use_naming_convention
    storage_replication     = var.storage_replication_type
    blob_versioning_enabled = var.enable_blob_versioning
    state_locking_enabled   = var.enable_state_locking
    key_vault_enabled       = var.enable_key_vault
    monitoring_enabled      = var.enable_monitoring
    network_restrictions    = var.enable_network_restrictions
    public_access_enabled   = var.enable_public_network_access
  }
}

# Tags applied
output "applied_tags" {
  description = "Tags applied to all resources"
  value       = local.common_tags
}