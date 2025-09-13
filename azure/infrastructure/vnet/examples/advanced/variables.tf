# Resource Group Configuration
variable "hub_resource_group_name" {
  description = "Name of the resource group for the hub VNet"
  type        = string
  default     = "rg-prod-networking-hub-weu"
}

variable "spoke_resource_group_name" {
  description = "Name of the resource group for spoke VNets"
  type        = string
  default     = "rg-prod-networking-spokes-weu"
}

variable "location_short" {
  description = "Short code for the Azure region"
  type        = string
  default     = "weu"
}

# DDoS Protection Configuration
variable "ddos_protection_plan_id" {
  description = "ID of the DDoS protection plan for enterprise networks"
  type        = string
  default     = ""
}

# DNS Configuration
variable "hub_dns_servers" {
  description = "Custom DNS servers for the hub VNet"
  type        = list(string)
  default     = ["168.63.129.16", "10.0.3.4", "10.0.3.5"]
}

# Network Monitoring Configuration
variable "network_watcher_name" {
  description = "Name of the Network Watcher instance"
  type        = string
  default     = "NetworkWatcher_westeurope"
}

variable "network_watcher_resource_group_name" {
  description = "Resource group name of the Network Watcher"
  type        = string
  default     = "NetworkWatcherRG"
}

variable "flow_log_storage_account_id" {
  description = "Storage account ID for storing flow logs"
  type        = string
  default     = ""
}

# Log Analytics Configuration
variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for traffic analytics"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_region" {
  description = "Region of the Log Analytics workspace"
  type        = string
  default     = "westeurope"
}

variable "log_analytics_workspace_resource_id" {
  description = "Resource ID of the Log Analytics workspace"
  type        = string
  default     = ""
}

# Tagging Configuration
variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Environment   = "prod"
    Project       = "enterprise-networking"
    Owner         = "platform-team"
    ManagedBy     = "Terraform"
    CostCenter    = "infrastructure"
    BusinessUnit  = "IT"
    Contact       = "network-team@example.com"
    Documentation = "https://wiki.example.com/networking"
    Architecture  = "hub-and-spoke"
  }
}