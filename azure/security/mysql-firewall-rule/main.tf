# azure-security-mysql-firewall-rule module
# Description: Manages Azure MySQL Firewall Rules with comprehensive security features, IP range management, and enterprise governance capabilities

terraform {
  required_version = ">= 1.0"
}

# Data sources
data "azurerm_mysql_server" "main" {
  count               = var.mysql_server_name != null ? 1 : 0
  name                = var.mysql_server_name
  resource_group_name = var.mysql_server_resource_group_name
}

data "azurerm_mysql_flexible_server" "main" {
  count               = var.mysql_flexible_server_name != null ? 1 : 0
  name                = var.mysql_flexible_server_name
  resource_group_name = var.mysql_flexible_server_resource_group_name
}

data "azurerm_client_config" "current" {}

# Local values
locals {
  common_tags = merge(
    var.common_tags,
    var.mysql_firewall_rule_tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "zrr-tf-module-lib/azure/security/mysql-firewall-rule"
      "Layer"     = "security"
    }
  )

  # Determine MySQL server name based on server type
  mysql_server_name = var.mysql_server_id != null ? split("/", var.mysql_server_id)[8] : (
    var.mysql_server_name != null ? var.mysql_server_name : var.mysql_flexible_server_name
  )

  # Validate that exactly one server reference is provided
  server_reference_count = length([
    for ref in [var.mysql_server_id, var.mysql_server_name, var.mysql_flexible_server_name] : ref
    if ref != null
  ])

  # IP range validation
  ip_ranges_valid = alltrue([
    for rule in var.firewall_rules : can(cidrhost(rule.start_ip_address, 0)) || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", rule.start_ip_address))
  ])

  # Azure service access rule
  azure_service_rule = var.allow_azure_services ? [{
    name             = "AllowAllWindowsAzureIps"
    start_ip_address = "0.0.0.0"
    end_ip_address   = "0.0.0.0"
  }] : []

  # Combine all firewall rules
  all_firewall_rules = concat(var.firewall_rules, local.azure_service_rule)

  # Server type detection
  is_flexible_server = var.mysql_flexible_server_name != null || can(regex("flexibleServers", var.mysql_server_id))
}

# Validation checks
resource "null_resource" "validation" {
  lifecycle {
    precondition {
      condition     = local.server_reference_count == 1
      error_message = "Exactly one MySQL server reference must be provided: mysql_server_id, mysql_server_name, or mysql_flexible_server_name."
    }

    precondition {
      condition     = local.ip_ranges_valid
      error_message = "All firewall rule IP addresses must be valid IPv4 addresses."
    }

    precondition {
      condition     = var.mysql_server_name == null || var.mysql_server_resource_group_name != null
      error_message = "mysql_server_resource_group_name is required when mysql_server_name is provided."
    }

    precondition {
      condition     = var.mysql_flexible_server_name == null || var.mysql_flexible_server_resource_group_name != null
      error_message = "mysql_flexible_server_resource_group_name is required when mysql_flexible_server_name is provided."
    }
  }
}

# MySQL Server Firewall Rules (for Single Server)
resource "azurerm_mysql_firewall_rule" "main" {
  for_each = !local.is_flexible_server ? { for rule in local.all_firewall_rules : rule.name => rule } : {}

  name                = each.value.name
  resource_group_name = var.mysql_server_resource_group_name != null ? var.mysql_server_resource_group_name : split("/", var.mysql_server_id)[4]
  server_name         = local.mysql_server_name
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address
}

# MySQL Flexible Server Firewall Rules
resource "azurerm_mysql_flexible_server_firewall_rule" "main" {
  for_each = local.is_flexible_server ? { for rule in local.all_firewall_rules : rule.name => rule } : {}

  name                = each.value.name
  resource_group_name = var.mysql_flexible_server_resource_group_name != null ? var.mysql_flexible_server_resource_group_name : split("/", var.mysql_server_id)[4]
  server_name         = local.mysql_server_name
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address
}