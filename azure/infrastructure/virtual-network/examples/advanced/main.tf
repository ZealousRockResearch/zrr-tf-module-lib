# Hub VNet for enterprise hub-and-spoke architecture
module "hub_vnet" {
  source = "../../"

  name                = "hub-enterprise"
  resource_group_name = var.hub_resource_group_name
  address_space       = ["10.0.0.0/16"]

  environment           = "prod"
  location_short        = var.location_short
  use_naming_convention = true

  # Enable DDoS protection for production workloads
  enable_ddos_protection  = true
  ddos_protection_plan_id = var.ddos_protection_plan_id

  # Custom DNS servers for enterprise environment
  dns_servers = var.hub_dns_servers

  # Hub subnets with specific enterprise requirements
  subnets = [
    {
      name                              = "GatewaySubnet"
      address_prefixes                  = ["10.0.1.0/27"]
      create_nsg                        = false # Gateway subnet doesn't need NSG
      private_endpoint_network_policies = "Disabled"
    },
    {
      name             = "AzureFirewallSubnet"
      address_prefixes = ["10.0.2.0/26"]
      create_nsg       = false # Firewall subnet doesn't need NSG
    },
    {
      name                          = "subnet-shared-services"
      address_prefixes              = ["10.0.3.0/24"]
      service_endpoints             = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.AzureActiveDirectory"]
      create_route_table            = true
      disable_bgp_route_propagation = true
    },
    {
      name                                          = "subnet-management"
      address_prefixes                              = ["10.0.4.0/24"]
      service_endpoints                             = ["Microsoft.Storage", "Microsoft.KeyVault"]
      private_endpoint_network_policies             = "Enabled"
      private_link_service_network_policies_enabled = true
      create_route_table                            = true
    }
  ]

  # Enable flow logs and traffic analytics for monitoring
  enable_flow_logs                    = true
  network_watcher_name                = var.network_watcher_name
  network_watcher_resource_group_name = var.network_watcher_resource_group_name
  flow_log_storage_account_id         = var.flow_log_storage_account_id
  flow_log_retention_days             = 90

  enable_traffic_analytics            = true
  log_analytics_workspace_id          = var.log_analytics_workspace_id
  log_analytics_workspace_region      = var.log_analytics_workspace_region
  log_analytics_workspace_resource_id = var.log_analytics_workspace_resource_id

  common_tags = var.common_tags

  vnet_tags = {
    NetworkTier      = "Hub"
    Criticality      = "High"
    ConnectivityType = "Hub-and-Spoke"
    MonitoringLevel  = "Enhanced"
  }
}

# Spoke VNet 1 - Production Workloads
module "spoke1_vnet" {
  source = "../../"

  name                = "spoke-production"
  resource_group_name = var.spoke_resource_group_name
  address_space       = ["10.1.0.0/16"]

  environment           = "prod"
  location_short        = var.location_short
  use_naming_convention = true

  # Auto-calculate subnet addresses for efficiency
  auto_calculate_subnets = true

  subnets = [
    {
      name               = "subnet-web"
      newbits            = 8 # Creates 10.1.0.0/24
      service_endpoints  = ["Microsoft.Storage", "Microsoft.KeyVault"]
      create_route_table = true
      delegations = [
        {
          name = "webapp-delegation"
          service_delegation = {
            name    = "Microsoft.Web/serverFarms"
            actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
          }
        }
      ]
    },
    {
      name               = "subnet-app"
      newbits            = 8 # Creates 10.1.1.0/24
      service_endpoints  = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
      create_route_table = true
    },
    {
      name                                          = "subnet-data"
      newbits                                       = 6 # Creates 10.1.2.0/22 (larger for data services)
      service_endpoints                             = ["Microsoft.Storage", "Microsoft.Sql"]
      private_endpoint_network_policies             = "Enabled"
      private_link_service_network_policies_enabled = true
      create_route_table                            = true
    },
    {
      name               = "subnet-integration"
      newbits            = 8 # Creates 10.1.6.0/24
      service_endpoints  = ["Microsoft.ServiceBus", "Microsoft.EventHub"]
      create_route_table = true
      delegations = [
        {
          name = "logic-apps-delegation"
          service_delegation = {
            name    = "Microsoft.Logic/integrationServiceEnvironments"
            actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
          }
        }
      ]
    }
  ]

  # Peer with hub VNet
  vnet_peerings = {
    "spoke1-to-hub" = {
      remote_vnet_id               = module.hub_vnet.vnet_id
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
      use_remote_gateways          = true
    }
  }

  # Enable monitoring
  enable_flow_logs                    = true
  network_watcher_name                = var.network_watcher_name
  network_watcher_resource_group_name = var.network_watcher_resource_group_name
  flow_log_storage_account_id         = var.flow_log_storage_account_id
  flow_log_retention_days             = 60

  common_tags = merge(var.common_tags, {
    WorkloadType = "Production"
    Tier         = "Spoke"
  })

  vnet_tags = {
    NetworkTier      = "Spoke"
    Criticality      = "High"
    WorkloadType     = "Production"
    ConnectivityType = "Hub-and-Spoke"
  }
}

# Spoke VNet 2 - Development/Testing
module "spoke2_vnet" {
  source = "../../"

  name                = "spoke-development"
  resource_group_name = var.spoke_resource_group_name
  address_space       = ["10.2.0.0/16"]

  environment           = "dev"
  location_short        = var.location_short
  use_naming_convention = true

  # Auto-calculate subnet addresses
  auto_calculate_subnets = true

  subnets = [
    {
      name              = "subnet-dev-web"
      newbits           = 8 # Creates 10.2.0.0/24
      service_endpoints = ["Microsoft.Storage"]
    },
    {
      name              = "subnet-dev-app"
      newbits           = 8 # Creates 10.2.1.0/24
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    },
    {
      name              = "subnet-test"
      newbits           = 8 # Creates 10.2.2.0/24
      service_endpoints = ["Microsoft.Storage"]
    }
  ]

  # Peer with hub VNet
  vnet_peerings = {
    "spoke2-to-hub" = {
      remote_vnet_id               = module.hub_vnet.vnet_id
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
      use_remote_gateways          = true
    }
  }

  # Reduced monitoring for dev/test
  enable_flow_logs = false

  common_tags = merge(var.common_tags, {
    WorkloadType = "Development"
    Tier         = "Spoke"
  })

  vnet_tags = {
    NetworkTier      = "Spoke"
    Criticality      = "Medium"
    WorkloadType     = "Development"
    ConnectivityType = "Hub-and-Spoke"
  }
}

# Hub-to-Spoke reverse peerings (required for bidirectional connectivity)
resource "azurerm_virtual_network_peering" "hub_to_spoke1" {
  name                      = "hub-to-spoke1"
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = module.hub_vnet.vnet_name
  remote_virtual_network_id = module.spoke1_vnet.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "hub_to_spoke2" {
  name                      = "hub-to-spoke2"
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = module.hub_vnet.vnet_name
  remote_virtual_network_id = module.spoke2_vnet.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

# Outputs for hub VNet
output "hub_vnet" {
  description = "Hub VNet details"
  value = {
    id            = module.hub_vnet.vnet_id
    name          = module.hub_vnet.vnet_name
    address_space = module.hub_vnet.vnet_address_space
    subnet_ids    = module.hub_vnet.subnet_ids
    nsg_ids       = module.hub_vnet.nsg_ids
    total_subnets = module.hub_vnet.total_subnets
  }
}

# Outputs for spoke VNets
output "spoke1_vnet" {
  description = "Spoke 1 (Production) VNet details"
  value = {
    id            = module.spoke1_vnet.vnet_id
    name          = module.spoke1_vnet.vnet_name
    address_space = module.spoke1_vnet.vnet_address_space
    subnet_ids    = module.spoke1_vnet.subnet_ids
    nsg_ids       = module.spoke1_vnet.nsg_ids
    total_subnets = module.spoke1_vnet.total_subnets
  }
}

output "spoke2_vnet" {
  description = "Spoke 2 (Development) VNet details"
  value = {
    id            = module.spoke2_vnet.vnet_id
    name          = module.spoke2_vnet.vnet_name
    address_space = module.spoke2_vnet.vnet_address_space
    subnet_ids    = module.spoke2_vnet.subnet_ids
    nsg_ids       = module.spoke2_vnet.nsg_ids
    total_subnets = module.spoke2_vnet.total_subnets
  }
}

# Summary output
output "network_architecture_summary" {
  description = "Summary of the entire hub-and-spoke network architecture"
  value = {
    hub = {
      name           = module.hub_vnet.vnet_name
      address_space  = module.hub_vnet.vnet_address_space
      total_subnets  = module.hub_vnet.total_subnets
      ddos_protected = module.hub_vnet.has_ddos_protection
      flow_logs      = module.hub_vnet.has_flow_logs
    }
    spokes = {
      production = {
        name          = module.spoke1_vnet.vnet_name
        address_space = module.spoke1_vnet.vnet_address_space
        total_subnets = module.spoke1_vnet.total_subnets
      }
      development = {
        name          = module.spoke2_vnet.vnet_name
        address_space = module.spoke2_vnet.vnet_address_space
        total_subnets = module.spoke2_vnet.total_subnets
      }
    }
    total_vnets   = 3
    total_subnets = module.hub_vnet.total_subnets + module.spoke1_vnet.total_subnets + module.spoke2_vnet.total_subnets
  }
}