# azure-security-key-vault-secret module
# Description: Manages Azure Key Vault secrets with enterprise standards compliance

terraform {
  required_version = ">= 1.0"
}

# Data sources
data "azurerm_key_vault" "main" {
  count               = var.key_vault_name != null ? 1 : 0
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group_name
}

data "azurerm_client_config" "current" {}

# Local values
locals {
  common_tags = merge(
    var.common_tags,
    var.key_vault_secret_tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "zrr-tf-module-lib/azure/security/key-vault-secret"
      "Layer"     = "security"
    }
  )

  key_vault_id = var.key_vault_id != null ? var.key_vault_id : (
    length(data.azurerm_key_vault.main) > 0 ? data.azurerm_key_vault.main[0].id : null
  )
}

# Key Vault Secret
resource "azurerm_key_vault_secret" "main" {
  name         = var.name
  value        = var.value
  key_vault_id = local.key_vault_id

  content_type    = var.content_type
  not_before_date = var.not_before_date
  expiration_date = var.expiration_date

  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}