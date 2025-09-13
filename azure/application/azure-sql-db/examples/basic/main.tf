module "azure_sql_db_example" {
  source = "../../"

  name                = "example-database"
  sql_server_name     = var.sql_server_name
  resource_group_name = var.resource_group_name

  # Basic performance configuration
  sku_name    = var.sku_name
  max_size_gb = var.max_size_gb

  # Security settings
  enable_threat_detection = var.enable_threat_detection
  enable_auditing         = var.enable_auditing

  # Backup settings
  short_term_retention_days = var.short_term_retention_days
  geo_backup_enabled        = var.geo_backup_enabled

  common_tags = var.common_tags

  azure_sql_db_tags = var.azure_sql_db_tags
}