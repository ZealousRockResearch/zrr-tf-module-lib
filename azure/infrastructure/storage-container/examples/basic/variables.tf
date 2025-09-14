variable "storage_account_name" {
  description = "Name of the storage account for the example"
  type        = string
  default     = "examplestorageacct"
}

variable "storage_account_resource_group_name" {
  description = "Resource group name of the storage account"
  type        = string
  default     = "example-rg"
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