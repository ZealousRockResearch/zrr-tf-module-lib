module "compliance_container" {
  source = "../../"

  name                                = "compliance-archive"
  storage_account_name                = var.storage_account_name
  storage_account_resource_group_name = var.storage_account_resource_group_name
  container_access_type               = "private"

  metadata = {
    environment = "production"
    project     = "compliance-system"
    owner       = "legal-team"
    purpose     = "regulatory-compliance"
  }

  # Advanced lifecycle management
  lifecycle_rules = [
    {
      name                       = "general-archive-policy"
      enabled                    = true
      prefix_match               = ["documents/", "records/"]
      blob_types                 = ["blockBlob"]
      tier_to_cool_after_days    = 30   # Move to cool storage after 30 days
      tier_to_archive_after_days = 90   # Move to archive after 90 days
      delete_after_days          = 2555 # Delete after 7 years
    },
    {
      name                       = "logs-retention-policy"
      enabled                    = true
      prefix_match               = ["logs/"]
      blob_types                 = ["blockBlob"]
      tier_to_cool_after_days    = 7   # Logs to cool storage quickly
      tier_to_archive_after_days = 30  # Archive logs after 30 days
      delete_after_days          = 365 # Delete logs after 1 year
      snapshot_delete_after_days = 30  # Delete snapshots after 30 days
      version_delete_after_days  = 90  # Delete old versions after 90 days
    },
    {
      name              = "temporary-files-policy"
      enabled           = true
      prefix_match      = ["temp/", "cache/"]
      blob_types        = ["blockBlob"]
      delete_after_days = 30 # Delete temporary files after 30 days
    }
  ]

  # Legal hold for litigation purposes
  legal_hold = var.enable_legal_hold ? {
    tags = var.legal_hold_tags
  } : null

  # Immutability policy for compliance
  immutability_policy = var.enable_immutability_policy ? {
    period_in_days = var.immutability_period_days
    locked         = var.immutability_policy_locked
  } : null

  common_tags = var.common_tags

  storage_container_tags = {
    Purpose      = "compliance-archive"
    DataClass    = "sensitive"
    Retention    = "7-years"
    Compliance   = "required"
    BackupPolicy = "critical"
    AccessLevel  = "restricted"
  }
}

module "application_data_container" {
  source = "../../"

  name                                = "app-data-${var.environment}"
  storage_account_name                = var.storage_account_name
  storage_account_resource_group_name = var.storage_account_resource_group_name
  container_access_type               = var.app_container_access_type

  metadata = {
    environment = var.environment
    project     = "application-backend"
    owner       = "development-team"
    purpose     = "application-data-storage"
  }

  # Application-specific lifecycle rules
  lifecycle_rules = var.enable_app_lifecycle ? [
    {
      name                       = "app-data-optimization"
      enabled                    = true
      prefix_match               = ["uploads/", "user-content/"]
      blob_types                 = ["blockBlob"]
      tier_to_cool_after_days    = 60   # Cool storage after 2 months
      tier_to_archive_after_days = 180  # Archive after 6 months
      delete_after_days          = 1095 # Delete after 3 years
    }
  ] : []

  common_tags = var.common_tags

  storage_container_tags = {
    Purpose     = "application-data"
    DataClass   = "general"
    Application = "web-backend"
    Tier        = "production"
  }
}

module "backup_container" {
  source = "../../"

  name                                = "system-backups"
  storage_account_name                = var.storage_account_name
  storage_account_resource_group_name = var.storage_account_resource_group_name
  container_access_type               = "private"

  metadata = {
    environment = var.environment
    project     = "infrastructure-backup"
    owner       = "operations-team"
    purpose     = "system-backup-storage"
  }

  # Backup-specific lifecycle management
  lifecycle_rules = [
    {
      name                       = "backup-retention-policy"
      enabled                    = true
      prefix_match               = ["daily/", "weekly/", "monthly/"]
      blob_types                 = ["blockBlob"]
      tier_to_cool_after_days    = 1    # Immediate cool storage for backups
      tier_to_archive_after_days = 30   # Archive after 30 days
      delete_after_days          = 1095 # Keep backups for 3 years
    },
    {
      name                       = "annual-backup-policy"
      enabled                    = true
      prefix_match               = ["annual/"]
      blob_types                 = ["blockBlob"]
      tier_to_archive_after_days = 1    # Immediate archive for annual backups
      delete_after_days          = 3650 # Keep annual backups for 10 years
    }
  ]

  common_tags = var.common_tags

  storage_container_tags = {
    Purpose    = "backup-storage"
    DataClass  = "operational"
    Retention  = "3-years"
    BackupType = "system"
    Priority   = "high"
  }
}