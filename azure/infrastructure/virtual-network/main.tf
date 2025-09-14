# azure-infrastructure-vnet module
# Description: Manages Azure Virtual Networks with subnets, NSGs, and advanced networking features

# Data sources
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_subscription" "current" {}

# Local values
locals {
  common_tags = merge(
    var.common_tags,
    var.vnet_tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "zrr-tf-module-lib/azure/infrastructure/vnet"
      "Layer"     = "infrastructure"
    }
  )

  # Construct vnet name with naming convention
  vnet_name = var.use_naming_convention ? "vnet-${var.environment}-${var.name}-${var.location_short}" : var.name

  # Flatten subnets for easier iteration
  subnets_map = { for subnet in var.subnets : subnet.name => subnet }

  # Calculate subnet addresses if auto_calculate is enabled
  calculated_subnets = var.auto_calculate_subnets ? [
    for idx, subnet in var.subnets : merge(subnet, {
      address_prefixes = [cidrsubnet(var.address_space[0], subnet.newbits != null ? subnet.newbits : 8, idx)]
    })
  ] : var.subnets
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = var.address_space
  dns_servers         = var.dns_servers

  dynamic "ddos_protection_plan" {
    for_each = var.enable_ddos_protection ? [1] : []
    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }

  tags = local.common_tags
}

# Subnets
resource "azurerm_subnet" "main" {
  for_each = { for subnet in local.calculated_subnets : subnet.name => subnet }

  name                 = each.value.name
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = each.value.address_prefixes

  private_endpoint_network_policies             = lookup(each.value, "private_endpoint_network_policies", "Disabled")
  private_link_service_network_policies_enabled = lookup(each.value, "private_link_service_network_policies_enabled", false)

  dynamic "delegation" {
    for_each = lookup(each.value, "delegations", [])
    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = lookup(delegation.value.service_delegation, "actions", null)
      }
    }
  }

  service_endpoints = lookup(each.value, "service_endpoints", [])
}

# Network Security Groups
resource "azurerm_network_security_group" "main" {
  for_each = { for subnet in local.calculated_subnets : subnet.name => subnet if lookup(subnet, "create_nsg", true) }

  name                = "nsg-${each.value.name}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  tags = merge(
    local.common_tags,
    {
      "AssociatedSubnet" = each.value.name
    }
  )
}

# Default NSG Rules
resource "azurerm_network_security_rule" "deny_all_inbound" {
  for_each = var.create_default_nsg_rules ? azurerm_network_security_group.main : {}

  name                        = "DenyAllInbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.main.name
  network_security_group_name = each.value.name
}

resource "azurerm_network_security_rule" "allow_vnet_inbound" {
  for_each = var.create_default_nsg_rules ? azurerm_network_security_group.main : {}

  name                        = "AllowVnetInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = data.azurerm_resource_group.main.name
  network_security_group_name = each.value.name
}

resource "azurerm_network_security_rule" "allow_load_balancer_inbound" {
  for_each = var.create_default_nsg_rules ? azurerm_network_security_group.main : {}

  name                        = "AllowAzureLoadBalancerInbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.main.name
  network_security_group_name = each.value.name
}

# NSG Associations
resource "azurerm_subnet_network_security_group_association" "main" {
  for_each = azurerm_network_security_group.main

  subnet_id                 = azurerm_subnet.main[each.key].id
  network_security_group_id = each.value.id
}

# Route Tables (optional)
resource "azurerm_route_table" "main" {
  for_each = { for subnet in local.calculated_subnets : subnet.name => subnet if lookup(subnet, "create_route_table", false) }

  name                          = "rt-${each.value.name}"
  location                      = data.azurerm_resource_group.main.location
  resource_group_name           = data.azurerm_resource_group.main.name
  disable_bgp_route_propagation = lookup(each.value, "disable_bgp_route_propagation", false)

  tags = merge(
    local.common_tags,
    {
      "AssociatedSubnet" = each.value.name
    }
  )
}

# Route Table Associations
resource "azurerm_subnet_route_table_association" "main" {
  for_each = azurerm_route_table.main

  subnet_id      = azurerm_subnet.main[each.key].id
  route_table_id = each.value.id
}

# VNet Peering (optional)
resource "azurerm_virtual_network_peering" "main" {
  for_each = var.vnet_peerings

  name                      = each.key
  resource_group_name       = data.azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.main.name
  remote_virtual_network_id = each.value.remote_vnet_id

  allow_virtual_network_access = lookup(each.value, "allow_virtual_network_access", true)
  allow_forwarded_traffic      = lookup(each.value, "allow_forwarded_traffic", false)
  allow_gateway_transit        = lookup(each.value, "allow_gateway_transit", false)
  use_remote_gateways          = lookup(each.value, "use_remote_gateways", false)
}

# Network Watcher Flow Logs (optional)
resource "azurerm_network_watcher_flow_log" "main" {
  count = var.enable_flow_logs ? 1 : 0

  name                      = "flowlog-${local.vnet_name}"
  network_watcher_name      = var.network_watcher_name
  resource_group_name       = var.network_watcher_resource_group_name
  network_security_group_id = values(azurerm_network_security_group.main)[0].id
  storage_account_id        = var.flow_log_storage_account_id
  enabled                   = true
  version                   = 2

  retention_policy {
    enabled = true
    days    = var.flow_log_retention_days
  }

  dynamic "traffic_analytics" {
    for_each = var.enable_traffic_analytics ? [1] : []
    content {
      enabled               = true
      workspace_id          = var.log_analytics_workspace_id
      workspace_region      = var.log_analytics_workspace_region
      workspace_resource_id = var.log_analytics_workspace_resource_id
      interval_in_minutes   = 10
    }
  }

  tags = local.common_tags
}