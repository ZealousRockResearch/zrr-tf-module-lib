module "file_share_example" {
  source = "../../"

  name                 = var.file_share_name
  storage_account_name = var.storage_account_name
  resource_group_name  = var.resource_group_name
  location             = var.location
  quota_gb             = var.quota_gb
  access_tier          = var.access_tier

  enable_backup = var.enable_backup

  common_tags = var.common_tags

  file_share_tags = var.file_share_tags
}

# Output the key values for reference
output "file_share_id" {
  description = "ID of the created file share"
  value       = module.file_share_example.id
}

output "file_share_name" {
  description = "Name of the created file share"
  value       = module.file_share_example.name
}

output "file_share_url" {
  description = "URL of the created file share"
  value       = module.file_share_example.url
}

output "backup_vault_id" {
  description = "ID of the backup vault (if backup is enabled)"
  value       = module.file_share_example.backup_vault_id
}