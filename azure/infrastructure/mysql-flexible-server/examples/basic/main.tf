module "mysql_server_example" {
  source = "../../"

  name                   = var.mysql_server_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  sku_name        = var.sku_name
  mysql_version   = var.mysql_version
  storage_size_gb = var.storage_size_gb

  backup_retention_days = var.backup_retention_days

  common_tags = var.common_tags
  mysql_tags  = var.mysql_tags
}

# Output the key values for reference
output "mysql_server_id" {
  description = "ID of the MySQL server"
  value       = module.mysql_server_example.id
}

output "mysql_server_name" {
  description = "Name of the MySQL server"
  value       = module.mysql_server_example.name
}

output "mysql_server_fqdn" {
  description = "FQDN of the MySQL server"
  value       = module.mysql_server_example.fqdn
}

output "connection_string" {
  description = "MySQL connection string"
  value       = module.mysql_server_example.connection_string
  sensitive   = true
}