variable "sql_server_name" {
  description = "Name of the existing Azure SQL Server"
  type        = string
  default     = "example-sql-server"
}

variable "resource_group_name" {
  description = "Name of the resource group containing the SQL Server"
  type        = string
  default     = "example-rg"
}

variable "sku_name" {
  description = "SKU name for the database"
  type        = string
  default     = "GP_S_Gen5_1"
}

variable "max_size_gb" {
  description = "Maximum size of the database in GB"
  type        = number
  default     = 2
}

variable "enable_threat_detection" {
  description = "Enable threat detection for the database"
  type        = bool
  default     = true
}

variable "enable_auditing" {
  description = "Enable database auditing"
  type        = bool
  default     = true
}

variable "short_term_retention_days" {
  description = "Point in time retention in days"
  type        = number
  default     = 7
}

variable "geo_backup_enabled" {
  description = "Enable geo-redundant backup"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags for the example"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "zrr-example"
    Owner       = "terraform"
    ManagedBy   = "Terraform"
  }
}

variable "azure_sql_db_tags" {
  description = "Additional tags specific to the Azure SQL Database"
  type        = map(string)
  default = {
    Purpose = "example"
    Tier    = "basic"
  }
}