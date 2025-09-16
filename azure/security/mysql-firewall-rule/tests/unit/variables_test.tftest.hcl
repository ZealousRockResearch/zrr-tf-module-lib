# Variable validation tests for MySQL Firewall Rule module

variables {
  mysql_server_name                = "test-mysql-server"
  mysql_server_resource_group_name = "test-rg"
  firewall_rules = [
    {
      name             = "TestRule"
      start_ip_address = "192.168.1.0"
      end_ip_address   = "192.168.1.255"
    }
  ]
}

run "valid_firewall_rule_name_test" {
  command = plan

  assert {
    condition = alltrue([
      for rule in var.firewall_rules : can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,127}$", rule.name))
    ])
    error_message = "Firewall rule names should accept valid names"
  }
}

run "invalid_firewall_rule_name_test" {
  command = plan

  variables {
    firewall_rules = [
      {
        name             = "_InvalidName"
        start_ip_address = "192.168.1.0"
        end_ip_address   = "192.168.1.255"
      }
    ]
  }

  expect_failures = [
    var.firewall_rules
  ]
}

run "valid_ip_address_test" {
  command = plan

  assert {
    condition = alltrue([
      for rule in var.firewall_rules : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", rule.start_ip_address))
    ])
    error_message = "Start IP addresses should be valid IPv4 addresses"
  }
}

run "invalid_ip_address_test" {
  command = plan

  variables {
    firewall_rules = [
      {
        name             = "TestRule"
        start_ip_address = "300.300.300.300"
        end_ip_address   = "192.168.1.255"
      }
    ]
  }

  expect_failures = [
    var.firewall_rules
  ]
}

run "valid_office_ips_test" {
  command = plan

  variables {
    allow_office_ips = [
      "192.168.1.0/24",
      "10.0.0.1"
    ]
  }

  assert {
    condition = alltrue([
      for ip in var.allow_office_ips : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}(?:/[0-9]{1,2})?$", ip))
    ])
    error_message = "Office IPs should accept valid IPv4 addresses and CIDR blocks"
  }
}

run "invalid_office_ips_test" {
  command = plan

  variables {
    allow_office_ips = [
      "invalid.ip.address"
    ]
  }

  expect_failures = [
    var.allow_office_ips
  ]
}

run "valid_developer_ips_test" {
  command = plan

  variables {
    allow_developer_ips = [
      "192.168.1.10",
      "10.0.0.20"
    ]
  }

  assert {
    condition = alltrue([
      for ip in var.allow_developer_ips : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))
    ])
    error_message = "Developer IPs should accept valid IPv4 addresses"
  }
}

run "invalid_developer_ips_test" {
  command = plan

  variables {
    allow_developer_ips = [
      "192.168.1.0/24"
    ]
  }

  expect_failures = [
    var.allow_developer_ips
  ]
}

run "valid_application_subnets_test" {
  command = plan

  variables {
    allow_application_subnets = [
      "10.1.0.0/24",
      "172.16.0.0/16"
    ]
  }

  assert {
    condition = alltrue([
      for cidr in var.allow_application_subnets : can(cidrhost(cidr, 0))
    ])
    error_message = "Application subnets should accept valid CIDR blocks"
  }
}

run "invalid_application_subnets_test" {
  command = plan

  variables {
    allow_application_subnets = [
      "invalid-cidr"
    ]
  }

  expect_failures = [
    var.allow_application_subnets
  ]
}

run "valid_environment_test" {
  command = plan

  variables {
    environment = "prod"
  }

  assert {
    condition     = contains(["dev", "test", "staging", "prod", "sandbox"], var.environment)
    error_message = "Environment should be a valid environment name"
  }
}

run "invalid_environment_test" {
  command = plan

  variables {
    environment = "invalid-env"
  }

  expect_failures = [
    var.environment
  ]
}

run "valid_max_firewall_rules_test" {
  command = plan

  variables {
    max_firewall_rules = 50
  }

  assert {
    condition     = var.max_firewall_rules > 0 && var.max_firewall_rules <= 128
    error_message = "Max firewall rules should be between 1 and 128"
  }
}

run "invalid_max_firewall_rules_test" {
  command = plan

  variables {
    max_firewall_rules = 200
  }

  expect_failures = [
    var.max_firewall_rules
  ]
}

run "required_tags_test" {
  command = plan

  assert {
    condition     = can(var.common_tags["Environment"]) && can(var.common_tags["Project"])
    error_message = "Common tags must include Environment and Project"
  }
}