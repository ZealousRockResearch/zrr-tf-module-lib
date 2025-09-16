variable "mysql_server_name" {
  description = "Name of the MySQL server for the example"
  type        = string
  default     = "example-mysql-server"
}

variable "mysql_server_resource_group_name" {
  description = "Resource group name of the MySQL server"
  type        = string
  default     = "example-rg"
}

variable "firewall_rules" {
  description = "Firewall rules for the example"
  type = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
  default = [
    {
      name             = "AllowOfficeNetwork"
      start_ip_address = "203.0.113.0"
      end_ip_address   = "203.0.113.255"
    }
  ]
}

variable "allow_azure_services" {
  description = "Allow Azure services access for the example"
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
  }
}