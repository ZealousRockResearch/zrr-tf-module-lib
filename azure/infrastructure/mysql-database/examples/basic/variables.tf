variable "database_name" {
  description = "Name of the MySQL database"
  type        = string
  default     = "example_db"
}

variable "resource_group_name" {
  description = "Name of the resource group containing the MySQL server"
  type        = string
  default     = "example-rg"
}

# MySQL server configuration - use one of these options
variable "mysql_flexible_server_id" {
  description = "Resource ID of an existing MySQL Flexible Server"
  type        = string
  default     = null
}

variable "mysql_server_id" {
  description = "Resource ID of an existing MySQL Single Server"
  type        = string
  default     = null
}

variable "mysql_server_name" {
  description = "Name of the MySQL server (when not using resource IDs)"
  type        = string
  default     = "example-mysql-server"
}

variable "use_flexible_server" {
  description = "Whether to use MySQL Flexible Server (true) or Single Server (false)"
  type        = bool
  default     = true
}

# Database configuration
variable "charset" {
  description = "Character set for the database"
  type        = string
  default     = "utf8mb4"
}

variable "collation" {
  description = "Collation for the database"
  type        = string
  default     = "utf8mb4_unicode_ci"
}

# Tags
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

variable "mysql_database_tags" {
  description = "Additional tags for the MySQL database"
  type        = map(string)
  default = {
    DatabaseType = "mysql"
    Purpose      = "development"
    Backup       = "enabled"
  }
}