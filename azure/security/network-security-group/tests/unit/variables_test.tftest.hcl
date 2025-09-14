# Variable validation tests for Azure Network Security Group module

variables {
  name                = "test-nsg"
  location            = "East US"
  resource_group_name = "test-rg"
}

# Valid name tests
run "valid_name_test" {
  command = plan

  assert {
    condition     = var.name == "test-nsg"
    error_message = "Name variable should accept valid names"
  }
}

run "invalid_name_too_long_test" {
  command = plan

  variables {
    name = "this-is-a-very-long-network-security-group-name-that-exceeds-the-maximum-length-limit"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_special_chars_test" {
  command = plan

  variables {
    name = "invalid@name!"
  }

  expect_failures = [
    var.name
  ]
}

# Location validation tests
run "valid_location_test" {
  command = plan

  assert {
    condition     = contains(["East US", "West US", "Central US"], var.location)
    error_message = "Location should be a valid Azure region"
  }
}

run "invalid_location_test" {
  command = plan

  variables {
    location = "Invalid Region"
  }

  expect_failures = [
    var.location
  ]
}

# Resource group name validation tests
run "valid_resource_group_name_test" {
  command = plan

  variables {
    resource_group_name = "valid-rg-name"
  }

  assert {
    condition     = var.resource_group_name == "valid-rg-name"
    error_message = "Resource group name should accept valid names"
  }
}

run "invalid_resource_group_name_test" {
  command = plan

  variables {
    resource_group_name = "invalid@rg@name"
  }

  expect_failures = [
    var.resource_group_name
  ]
}

# Common tags validation tests
run "valid_common_tags_test" {
  command = plan

  variables {
    common_tags = {
      Environment = "test"
      Project     = "validation"
      Owner       = "terraform"
    }
  }

  assert {
    condition     = can(var.common_tags["Environment"]) && can(var.common_tags["Project"])
    error_message = "Common tags should include Environment and Project"
  }
}

run "missing_required_tags_test" {
  command = plan

  variables {
    common_tags = {
      Owner = "terraform"
    }
  }

  expect_failures = [
    var.common_tags
  ]
}

# Security rules validation tests
run "valid_security_rules_test" {
  command = plan

  variables {
    security_rules = [
      {
        name                       = "allow-ssh"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        description                = "Allow SSH"
      }
    ]
  }

  assert {
    condition     = length(var.security_rules) == 1
    error_message = "Should accept valid security rules"
  }
}

run "invalid_priority_too_low_test" {
  command = plan

  variables {
    security_rules = [
      {
        name                       = "invalid-rule"
        priority                   = 50
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }

  expect_failures = [
    var.security_rules
  ]
}

run "invalid_priority_too_high_test" {
  command = plan

  variables {
    security_rules = [
      {
        name                       = "invalid-rule"
        priority                   = 5000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }

  expect_failures = [
    var.security_rules
  ]
}

run "invalid_direction_test" {
  command = plan

  variables {
    security_rules = [
      {
        name                       = "invalid-rule"
        priority                   = 1000
        direction                  = "Invalid"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }

  expect_failures = [
    var.security_rules
  ]
}

run "invalid_access_test" {
  command = plan

  variables {
    security_rules = [
      {
        name                       = "invalid-rule"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Invalid"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }

  expect_failures = [
    var.security_rules
  ]
}

run "invalid_protocol_test" {
  command = plan

  variables {
    security_rules = [
      {
        name                       = "invalid-rule"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Invalid"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }

  expect_failures = [
    var.security_rules
  ]
}

run "invalid_rule_name_test" {
  command = plan

  variables {
    security_rules = [
      {
        name                       = "invalid@rule@name!"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }

  expect_failures = [
    var.security_rules
  ]
}

# Flow logs validation tests
run "valid_flow_logs_disabled_test" {
  command = plan

  variables {
    enable_flow_logs = false
  }

  assert {
    condition     = var.enable_flow_logs == false
    error_message = "Should allow flow logs to be disabled"
  }
}

run "invalid_flow_logs_missing_storage_test" {
  command = plan

  variables {
    enable_flow_logs            = true
    flow_log_storage_account_id = null
  }

  expect_failures = [
    var.flow_log_storage_account_id
  ]
}

run "valid_flow_logs_with_storage_test" {
  command = plan

  variables {
    enable_flow_logs            = true
    flow_log_storage_account_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Storage/storageAccounts/xxx"
  }

  assert {
    condition     = var.enable_flow_logs == true && var.flow_log_storage_account_id != null
    error_message = "Should accept valid flow logs configuration"
  }
}

run "invalid_flow_log_retention_too_low_test" {
  command = plan

  variables {
    flow_log_retention_days = 0
  }

  expect_failures = [
    var.flow_log_retention_days
  ]
}

run "invalid_flow_log_retention_too_high_test" {
  command = plan

  variables {
    flow_log_retention_days = 400
  }

  expect_failures = [
    var.flow_log_retention_days
  ]
}

run "invalid_flow_log_format_type_test" {
  command = plan

  variables {
    flow_log_format_type = "XML"
  }

  expect_failures = [
    var.flow_log_format_type
  ]
}

run "invalid_flow_log_format_version_test" {
  command = plan

  variables {
    flow_log_format_version = 3
  }

  expect_failures = [
    var.flow_log_format_version
  ]
}