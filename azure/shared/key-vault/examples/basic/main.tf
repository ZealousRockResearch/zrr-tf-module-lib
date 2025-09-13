module "key_vault_example" {
  source = "../../"

  name     = "example-kv-001"
  location = var.location

  # Basic configuration with secure defaults
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  public_network_access_enabled = true

  common_tags = var.common_tags

  key_vault_tags = {
    Purpose = "example"
    Backup  = "daily"
  }
}

# Example output usage
output "key_vault_uri" {
  description = "The URI of the created Key Vault"
  value       = module.key_vault_example.uri
}

output "key_vault_id" {
  description = "The ID of the created Key Vault"
  value       = module.key_vault_example.id
}