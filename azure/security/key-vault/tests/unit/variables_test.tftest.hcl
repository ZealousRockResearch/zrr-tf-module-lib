# Variable validation tests for Azure Key Vault module

variables {
  name     = "test-keyvault-001"
  location = "East US"
}

# Test valid name formats
run "valid_name_test" {
  command = plan

  assert {
    condition     = var.name == "test-keyvault-001"
    error_message = "Name variable should accept valid names"
  }
}

run "valid_name_with_hyphens_test" {
  command = plan

  variables {
    name = "test-kv-prod-001"
  }

  assert {
    condition     = var.name == "test-kv-prod-001"
    error_message = "Name should accept names with hyphens"
  }
}

# Test invalid name formats
run "invalid_name_too_short_test" {
  command = plan

  variables {
    name = "kv"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_too_long_test" {
  command = plan

  variables {
    name = "this-is-a-very-long-key-vault-name-that-exceeds-the-limit"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_special_chars_test" {
  command = plan

  variables {
    name = "invalid@keyvault!"
  }

  expect_failures = [
    var.name
  ]
}

# Test valid locations
run "valid_location_east_us_test" {
  command = plan

  variables {
    location = "East US"
  }

  assert {
    condition     = var.location == "East US"
    error_message = "Location should accept East US"
  }
}

run "valid_location_west_europe_test" {
  command = plan

  variables {
    location = "West Europe"
  }

  assert {
    condition     = var.location == "West Europe"
    error_message = "Location should accept West Europe"
  }
}

# Test invalid location
run "invalid_location_test" {
  command = plan

  variables {
    location = "Invalid Region"
  }

  expect_failures = [
    var.location
  ]
}

# Test SKU name validation
run "valid_sku_standard_test" {
  command = plan

  variables {
    sku_name = "standard"
  }

  assert {
    condition     = var.sku_name == "standard"
    error_message = "SKU should accept standard"
  }
}

run "valid_sku_premium_test" {
  command = plan

  variables {
    sku_name = "premium"
  }

  assert {
    condition     = var.sku_name == "premium"
    error_message = "SKU should accept premium"
  }
}

run "invalid_sku_test" {
  command = plan

  variables {
    sku_name = "basic"
  }

  expect_failures = [
    var.sku_name
  ]
}

# Test soft delete retention days validation
run "valid_retention_days_minimum_test" {
  command = plan

  variables {
    soft_delete_retention_days = 7
  }

  assert {
    condition     = var.soft_delete_retention_days == 7
    error_message = "Should accept minimum retention days of 7"
  }
}

run "valid_retention_days_maximum_test" {
  command = plan

  variables {
    soft_delete_retention_days = 90
  }

  assert {
    condition     = var.soft_delete_retention_days == 90
    error_message = "Should accept maximum retention days of 90"
  }
}

run "invalid_retention_days_too_low_test" {
  command = plan

  variables {
    soft_delete_retention_days = 5
  }

  expect_failures = [
    var.soft_delete_retention_days
  ]
}

run "invalid_retention_days_too_high_test" {
  command = plan

  variables {
    soft_delete_retention_days = 100
  }

  expect_failures = [
    var.soft_delete_retention_days
  ]
}

# Test required tags validation
run "valid_required_tags_test" {
  command = plan

  variables {
    common_tags = {
      Environment = "test"
      Project     = "validation"
      ManagedBy   = "Terraform"
    }
  }

  assert {
    condition     = can(var.common_tags["Environment"]) && can(var.common_tags["Project"])
    error_message = "Common tags should include Environment and Project"
  }
}

run "missing_environment_tag_test" {
  command = plan

  variables {
    common_tags = {
      Project   = "validation"
      ManagedBy = "Terraform"
    }
  }

  expect_failures = [
    var.common_tags
  ]
}

run "missing_project_tag_test" {
  command = plan

  variables {
    common_tags = {
      Environment = "test"
      ManagedBy   = "Terraform"
    }
  }

  expect_failures = [
    var.common_tags
  ]
}

# Test network ACLs validation
run "valid_network_acls_allow_test" {
  command = plan

  variables {
    network_acls = {
      default_action             = "Allow"
      bypass                     = "AzureServices"
      ip_rules                   = ["203.0.113.0/24"]
      virtual_network_subnet_ids = []
    }
  }

  assert {
    condition     = var.network_acls.default_action == "Allow"
    error_message = "Network ACLs should accept Allow action"
  }
}

run "valid_network_acls_deny_test" {
  command = plan

  variables {
    network_acls = {
      default_action             = "Deny"
      bypass                     = "None"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }
  }

  assert {
    condition     = var.network_acls.default_action == "Deny"
    error_message = "Network ACLs should accept Deny action"
  }
}

run "invalid_network_acls_action_test" {
  command = plan

  variables {
    network_acls = {
      default_action             = "Block"
      bypass                     = "AzureServices"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }
  }

  expect_failures = [
    var.network_acls
  ]
}

run "invalid_network_acls_bypass_test" {
  command = plan

  variables {
    network_acls = {
      default_action             = "Deny"
      bypass                     = "Invalid"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }
  }

  expect_failures = [
    var.network_acls
  ]
}

# Test boolean variables
run "boolean_variables_test" {
  command = plan

  variables {
    enabled_for_disk_encryption     = true
    enabled_for_deployment          = false
    enabled_for_template_deployment = true
    enable_rbac_authorization       = false
    purge_protection_enabled        = true
    public_network_access_enabled   = false
  }

  assert {
    condition     = var.enabled_for_disk_encryption == true
    error_message = "Boolean variables should accept true/false values"
  }
}