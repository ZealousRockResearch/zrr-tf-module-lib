variable "mysql_server_name" {
  description = "Name of the MySQL server to create"
  type        = string
  default     = "example-mysql"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  # This should be set when running the example
}

variable "location" {
  description = "Azure region for the MySQL server"
  type        = string
  default     = "East US"
}

variable "administrator_login" {
  description = "Administrator login for the MySQL server"
  type        = string
  default     = "mysqladmin"
}

variable "administrator_password" {
  description = "Administrator password for the MySQL server"
  type        = string
  sensitive   = true
  # This should be set when running the example
}

variable "sku_name" {
  description = "SKU name for the MySQL server"
  type        = string
  default     = "GP_Standard_D2ds_v4"
}

variable "mysql_version" {
  description = "Version of MySQL server"
  type        = string
  default     = "8.0.21"
}

variable "storage_size_gb" {
  description = "Storage size in GB"
  type        = number
  default     = 100
}

variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "common_tags" {
  description = "Common tags for the example"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "zrr-example"
    Owner       = "terraform"
  }
}

variable "mysql_tags" {
  description = "Additional tags for the MySQL server"
  type        = map(string)
  default = {
    Purpose      = "example"
    DatabaseType = "mysql"
  }
}