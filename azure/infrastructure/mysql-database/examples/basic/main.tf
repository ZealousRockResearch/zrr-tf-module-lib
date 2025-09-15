module "mysql_database_basic" {
  source = "../../"

  name                     = var.database_name
  resource_group_name      = var.resource_group_name
  mysql_flexible_server_id = var.mysql_flexible_server_id
  mysql_server_id          = var.mysql_server_id
  mysql_server_name        = var.mysql_server_name
  use_flexible_server      = var.use_flexible_server

  # Database configuration
  charset   = var.charset
  collation = var.collation

  # Tags
  common_tags         = var.common_tags
  mysql_database_tags = var.mysql_database_tags
}

# Outputs
output "database_id" {
  description = "ID of the MySQL database"
  value       = module.mysql_database_basic.id
}

output "database_name" {
  description = "Name of the MySQL database"
  value       = module.mysql_database_basic.name
}

output "server_name" {
  description = "Name of the MySQL server"
  value       = module.mysql_database_basic.server_name
}

output "server_type" {
  description = "Type of MySQL server (flexible or single)"
  value       = module.mysql_database_basic.server_type
}

output "charset" {
  description = "Character set of the database"
  value       = module.mysql_database_basic.charset
}

output "collation" {
  description = "Collation of the database"
  value       = module.mysql_database_basic.collation
}

output "database_summary" {
  description = "Summary of the database configuration"
  value       = module.mysql_database_basic.database_summary
}