variable "location" {
  description = "Azure region for the example"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
  default     = "example-rg"
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