output "database_id" {
  description = "ID of the created Azure SQL Database"
  value       = module.azure_sql_db_example.id
}

output "database_name" {
  description = "Name of the created Azure SQL Database"
  value       = module.azure_sql_db_example.name
}

output "server_id" {
  description = "ID of the Azure SQL Server hosting the database"
  value       = module.azure_sql_db_example.server_id
}

output "sku_name" {
  description = "SKU name of the database"
  value       = module.azure_sql_db_example.sku_name
}

output "max_size_gb" {
  description = "Maximum size of the database in GB"
  value       = module.azure_sql_db_example.max_size_gb
}

output "tags" {
  description = "Tags applied to the database"
  value       = module.azure_sql_db_example.tags
}