# Variable validation tests for Azure VNet module

variables {
  name                = "test-vnet"
  resource_group_name = "rg-test"
  address_space       = ["10.0.0.0/16"]
}

# Test valid name
run "valid_name_test" {
  command = plan

  assert {
    condition     = var.name == "test-vnet"
    error_message = "Name variable should accept valid names"
  }
}

# Test invalid name with special characters
run "invalid_name_test" {
  command = plan

  variables {
    name = "invalid@name!"
  }

  expect_failures = [
    var.name
  ]
}

# Test valid address space
run "valid_address_space_test" {
  command = plan

  variables {
    address_space = ["10.1.0.0/16", "10.2.0.0/16"]
  }

  assert {
    condition     = length(var.address_space) == 2
    error_message = "Address space should accept multiple CIDR blocks"
  }
}

# Test invalid address space
run "invalid_address_space_test" {
  command = plan

  variables {
    address_space = ["invalid-cidr"]
  }

  expect_failures = [
    var.address_space
  ]
}

# Test required tags
run "required_tags_test" {
  command = plan

  assert {
    condition     = can(var.common_tags["Environment"]) && can(var.common_tags["Project"])
    error_message = "Common tags must include Environment and Project"
  }
}

# Test missing required tags
run "missing_required_tags_test" {
  command = plan

  variables {
    common_tags = {
      Owner = "test"
    }
  }

  expect_failures = [
    var.common_tags
  ]
}

# Test valid environment values
run "valid_environment_test" {
  command = plan

  variables {
    environment = "prod"
  }

  assert {
    condition     = contains(["dev", "test", "staging", "prod", "dr"], var.environment)
    error_message = "Environment should be one of the allowed values"
  }
}

# Test invalid environment value
run "invalid_environment_test" {
  command = plan

  variables {
    environment = "invalid"
  }

  expect_failures = [
    var.environment
  ]
}

# Test valid DNS servers
run "valid_dns_servers_test" {
  command = plan

  variables {
    dns_servers = ["8.8.8.8", "1.1.1.1"]
  }

  assert {
    condition     = length(var.dns_servers) == 2
    error_message = "Should accept valid DNS server IP addresses"
  }
}

# Test invalid DNS servers
run "invalid_dns_servers_test" {
  command = plan

  variables {
    dns_servers = ["invalid-ip", "300.300.300.300"]
  }

  expect_failures = [
    var.dns_servers
  ]
}

# Test flow log retention validation
run "valid_flow_log_retention_test" {
  command = plan

  variables {
    flow_log_retention_days = 90
  }

  assert {
    condition     = var.flow_log_retention_days >= 0 && var.flow_log_retention_days <= 365
    error_message = "Flow log retention should be between 0 and 365 days"
  }
}

# Test invalid flow log retention
run "invalid_flow_log_retention_test" {
  command = plan

  variables {
    flow_log_retention_days = 400
  }

  expect_failures = [
    var.flow_log_retention_days
  ]
}

# Test subnet configuration with valid structure
run "valid_subnets_test" {
  command = plan

  variables {
    subnets = [
      {
        name              = "subnet-web"
        address_prefixes  = ["10.0.1.0/24"]
        service_endpoints = ["Microsoft.Storage"]
      },
      {
        name               = "subnet-app"
        address_prefixes   = ["10.0.2.0/24"]
        create_nsg         = true
        create_route_table = false
      }
    ]
  }

  assert {
    condition     = length(var.subnets) == 2
    error_message = "Should accept valid subnet configurations"
  }
}

# Test auto-calculate subnets functionality
run "auto_calculate_subnets_test" {
  command = plan

  variables {
    auto_calculate_subnets = true
    subnets = [
      {
        name    = "subnet-1"
        newbits = 8
      },
      {
        name    = "subnet-2"
        newbits = 6
      }
    ]
  }

  assert {
    condition     = var.auto_calculate_subnets == true
    error_message = "Auto-calculate subnets should work with newbits specification"
  }
}

# Test VNet peering configuration
run "valid_vnet_peering_test" {
  command = plan

  variables {
    vnet_peerings = {
      "peer-to-hub" = {
        remote_vnet_id               = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/virtualNetworks/vnet-hub"
        allow_virtual_network_access = true
        allow_forwarded_traffic      = true
      }
    }
  }

  assert {
    condition     = length(var.vnet_peerings) == 1
    error_message = "Should accept valid VNet peering configurations"
  }
}

# Test subnet with delegations
run "subnet_delegations_test" {
  command = plan

  variables {
    subnets = [
      {
        name             = "subnet-webapp"
        address_prefixes = ["10.0.1.0/24"]
        delegations = [
          {
            name = "webapp"
            service_delegation = {
              name    = "Microsoft.Web/serverFarms"
              actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
            }
          }
        ]
      }
    ]
  }

  assert {
    condition     = length(var.subnets[0].delegations) == 1
    error_message = "Should accept subnet delegations"
  }
}

# Test boolean flags
run "boolean_flags_test" {
  command = plan

  variables {
    enable_ddos_protection   = true
    enable_flow_logs         = true
    enable_traffic_analytics = true
    create_default_nsg_rules = false
    use_naming_convention    = false
  }

  assert {
    condition     = var.enable_ddos_protection == true && var.enable_flow_logs == true
    error_message = "Boolean variables should accept true/false values"
  }
}