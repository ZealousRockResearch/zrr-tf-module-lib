# azure-security-network-security-group module
# Description: Creates and manages Azure Network Security Groups with configurable security rules

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Data sources
data "azurerm_resource_group" "main" {
  count = var.resource_group_name != null ? 1 : 0
  name  = var.resource_group_name
}

# Local values
locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.main[0].name : var.resource_group_name

  common_tags = merge(
    var.common_tags,
    var.network_security_group_tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "zrr-tf-module-lib/azure/security/network-security-group"
      "Layer"     = "security"
    }
  )

  # Flatten security rules for for_each
  security_rules = {
    for rule in var.security_rules : rule.name => rule
  }
}

# Resource Group (optional)
resource "azurerm_resource_group" "main" {
  count = var.create_resource_group ? 1 : 0

  name     = var.resource_group_name
  location = var.location

  tags = local.common_tags
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name

  tags = local.common_tags
}

# Security Rules
resource "azurerm_network_security_rule" "main" {
  for_each = local.security_rules

  name                         = each.value.name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_range            = each.value.source_port_range
  source_port_ranges           = each.value.source_port_ranges
  destination_port_range       = each.value.destination_port_range
  destination_port_ranges      = each.value.destination_port_ranges
  source_address_prefix        = each.value.source_address_prefix
  source_address_prefixes      = each.value.source_address_prefixes
  destination_address_prefix   = each.value.destination_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes
  description                  = each.value.description

  resource_group_name         = local.resource_group_name
  network_security_group_name = azurerm_network_security_group.main.name
}

# Network Security Group Association (optional)
resource "azurerm_subnet_network_security_group_association" "main" {
  count = var.subnet_id != null ? 1 : 0

  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Network Interface Security Group Association (optional)
resource "azurerm_network_interface_security_group_association" "main" {
  for_each = toset(var.network_interface_ids)

  network_interface_id      = each.value
  network_security_group_id = azurerm_network_security_group.main.id
}