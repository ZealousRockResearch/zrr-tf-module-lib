variable "key_vault_name" {
  description = "Name of the key vault for the example"
  type        = string
  default     = "example-keyvault"
}

variable "key_vault_resource_group_name" {
  description = "Resource group name of the key vault"
  type        = string
  default     = "example-rg"
}

variable "secret_value" {
  description = "Value for the example secret"
  type        = string
  sensitive   = true
  default     = "example-secret-value"
}

variable "common_tags" {
  description = "Common tags for the example"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "zrr-example"
    Owner       = "platform-team"
    CostCenter  = "engineering"
  }
}