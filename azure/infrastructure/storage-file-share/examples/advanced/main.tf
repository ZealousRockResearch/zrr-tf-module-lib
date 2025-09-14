module "file_share_advanced" {
  source = "../../"

  name                 = var.file_share_name
  storage_account_name = var.storage_account_name
  resource_group_name  = var.resource_group_name
  location             = var.location
  quota_gb             = var.quota_gb
  access_tier          = var.access_tier
  enabled_protocol     = var.enabled_protocol
  metadata             = var.metadata

  # Directory structure
  directories = var.directories

  # Access policies
  access_policies = var.access_policies

  # Backup configuration
  enable_backup                = var.enable_backup
  backup_vault_name            = var.backup_vault_name
  backup_vault_sku             = var.backup_vault_sku
  backup_soft_delete_enabled   = var.backup_soft_delete_enabled
  backup_public_access_enabled = var.backup_public_access_enabled
  backup_policy                = var.backup_policy

  # Monitoring and alerting
  enable_monitoring                = var.enable_monitoring
  alert_email_addresses            = var.alert_email_addresses
  quota_alert_threshold_percentage = var.quota_alert_threshold_percentage
  quota_alert_severity             = var.quota_alert_severity

  # Private networking
  enable_private_endpoint    = var.enable_private_endpoint
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  private_dns_zone_id        = var.private_dns_zone_id

  # Tags
  common_tags     = var.common_tags
  file_share_tags = var.file_share_tags
}

# Output all key values for reference
output "file_share_id" {
  description = "ID of the created file share"
  value       = module.file_share_advanced.id
}

output "file_share_name" {
  description = "Name of the created file share"
  value       = module.file_share_advanced.name
}

output "file_share_url" {
  description = "URL of the created file share"
  value       = module.file_share_advanced.url
}

output "file_share_quota_gb" {
  description = "Quota of the file share in GB"
  value       = module.file_share_advanced.quota_gb
}

output "file_share_access_tier" {
  description = "Access tier of the file share"
  value       = module.file_share_advanced.access_tier
}

output "directories" {
  description = "Created directories in the file share"
  value       = module.file_share_advanced.directories
}

output "backup_vault_id" {
  description = "ID of the backup vault"
  value       = module.file_share_advanced.backup_vault_id
}

output "backup_vault_name" {
  description = "Name of the backup vault"
  value       = module.file_share_advanced.backup_vault_name
}

output "backup_policy_id" {
  description = "ID of the backup policy"
  value       = module.file_share_advanced.backup_policy_id
}

output "action_group_id" {
  description = "ID of the monitor action group"
  value       = module.file_share_advanced.action_group_id
}

output "quota_alert_id" {
  description = "ID of the quota metric alert"
  value       = module.file_share_advanced.quota_alert_id
}

output "private_endpoint_id" {
  description = "ID of the private endpoint"
  value       = module.file_share_advanced.private_endpoint_id
}

output "private_endpoint_ip_addresses" {
  description = "Private IP addresses of the private endpoint"
  value       = module.file_share_advanced.private_endpoint_ip_addresses
}

output "tags" {
  description = "All tags applied to the resources"
  value       = module.file_share_advanced.tags
}