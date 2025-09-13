# Data sources for existing resources
data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "example" {
  name                = var.vnet_name
  resource_group_name = var.vnet_resource_group_name
}

data "azurerm_subnet" "private_endpoint" {
  name                 = var.private_endpoint_subnet_name
  virtual_network_name = data.azurerm_virtual_network.example.name
  resource_group_name  = var.vnet_resource_group_name
}

data "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_resource_group_name
}

data "azurerm_storage_account" "example" {
  name                = var.storage_account_name
  resource_group_name = var.storage_account_resource_group_name
}

data "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.private_dns_zone_resource_group_name
}

# Advanced Key Vault configuration with all features
module "key_vault_advanced" {
  source = "../../"

  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Premium SKU for HSM-backed keys
  sku_name = "premium"

  # Security configuration
  enable_rbac_authorization       = false # Using access policies for granular control
  purge_protection_enabled        = true
  soft_delete_retention_days      = 90
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  public_network_access_enabled   = false # Private access only

  # Network restrictions
  network_acls = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  # Access policies for different roles
  access_policies = {
    admin = {
      object_id = data.azurerm_client_config.current.object_id
      key_permissions = [
        "Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore",
        "Recover", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "WrapKey", "UnwrapKey"
      ]
      secret_permissions = [
        "Get", "List", "Set", "Delete", "Backup", "Restore", "Recover", "Purge"
      ]
      certificate_permissions = [
        "Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore",
        "Recover", "Purge", "ManageContacts", "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers"
      ]
    }

    application = {
      object_id               = var.application_object_id
      key_permissions         = ["Get", "Encrypt", "Decrypt", "WrapKey", "UnwrapKey"]
      secret_permissions      = ["Get"]
      certificate_permissions = ["Get"]
    }

    backup_service = {
      object_id               = var.backup_service_object_id
      key_permissions         = ["Get", "Backup"]
      secret_permissions      = ["Get", "Backup"]
      certificate_permissions = ["Get", "Backup"]
    }
  }

  # Application secrets
  secrets = var.secrets

  # Encryption keys
  keys = {
    database-encryption-key = {
      key_type = "RSA-HSM" # HSM-backed key for production
      key_size = 4096
      key_opts = ["encrypt", "decrypt", "wrapKey", "unwrapKey"]
      tags = {
        Purpose  = "Database Encryption"
        Rotation = "Annual"
      }
    }

    application-signing-key = {
      key_type = "EC-HSM"
      curve    = "P-384"
      key_opts = ["sign", "verify"]
      tags = {
        Purpose  = "JWT Signing"
        Rotation = "Quarterly"
      }
    }

    file-encryption-key = {
      key_type        = "RSA-HSM"
      key_size        = 2048
      key_opts        = ["encrypt", "decrypt"]
      expiration_date = "2025-12-31T23:59:59Z"
      tags = {
        Purpose   = "File Encryption"
        Temporary = "true"
      }
    }
  }

  # Certificate contacts for notifications
  certificate_contacts = [
    {
      email = var.primary_admin_email
      name  = "Primary Security Admin"
      phone = var.primary_admin_phone
    },
    {
      email = var.secondary_admin_email
      name  = "Secondary Security Admin"
      phone = var.secondary_admin_phone
    }
  ]

  # Private endpoint for secure access
  private_endpoint = {
    subnet_id            = data.azurerm_subnet.private_endpoint.id
    private_dns_zone_ids = [data.azurerm_private_dns_zone.keyvault.id]
  }

  # Comprehensive diagnostic settings
  diagnostic_setting = {
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.example.id
    storage_account_id         = data.azurerm_storage_account.example.id
    log_categories = [
      "AuditEvent",
      "AzurePolicyEvaluationDetails"
    ]
    metric_categories = ["AllMetrics"]
  }

  # Comprehensive tagging
  common_tags = var.common_tags

  key_vault_tags = {
    Environment        = var.environment
    SecurityLevel      = "High"
    DataClassification = "Confidential"
    BackupRequired     = "true"
    MonitoringLevel    = "Enhanced"
    ComplianceScope    = "SOC2-PCI-DSS"
    Owner              = var.security_team_email
    CostCenter         = var.cost_center
    Project            = var.project_name
  }
}

# Outputs
output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.key_vault_advanced.uri
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = module.key_vault_advanced.id
}

output "private_endpoint_ip" {
  description = "Private IP address of the Key Vault"
  value       = module.key_vault_advanced.private_endpoint_ip_address
}

output "secret_ids" {
  description = "Map of secret names to their IDs"
  value       = module.key_vault_advanced.secret_ids
  sensitive   = true
}

output "key_ids" {
  description = "Map of key names to their IDs"
  value       = module.key_vault_advanced.key_ids
}