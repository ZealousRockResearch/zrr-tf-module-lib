# Variable validation tests for Azure Terraform State Initialization module

variables {
  project_name = "testproject"
  environment  = "dev"
  location     = "East US"
}

# Test valid project name
run "valid_project_name_test" {
  command = plan

  assert {
    condition     = var.project_name == "testproject"
    error_message = "Project name variable should accept valid names"
  }
}

# Test invalid project name with uppercase
run "invalid_project_name_uppercase_test" {
  command = plan

  variables {
    project_name = "TestProject"
  }

  expect_failures = [
    var.project_name
  ]
}

# Test invalid project name with special characters
run "invalid_project_name_special_chars_test" {
  command = plan

  variables {
    project_name = "test-project!"
  }

  expect_failures = [
    var.project_name
  ]
}

# Test invalid project name too short
run "invalid_project_name_too_short_test" {
  command = plan

  variables {
    project_name = "ab"
  }

  expect_failures = [
    var.project_name
  ]
}

# Test invalid project name too long
run "invalid_project_name_too_long_test" {
  command = plan

  variables {
    project_name = "verylongprojectname"
  }

  expect_failures = [
    var.project_name
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

# Test valid location
run "valid_location_test" {
  command = plan

  variables {
    location = "West US"
  }

  assert {
    condition = contains([
      "East US", "East US 2", "West US", "West US 2", "West US 3",
      "Central US", "North Central US", "South Central US", "West Central US"
    ], var.location)
    error_message = "Location should be a valid Azure region"
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

# Test valid storage account tier
run "valid_storage_tier_test" {
  command = plan

  variables {
    storage_account_tier = "Premium"
  }

  assert {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage account tier should be Standard or Premium"
  }
}

# Test invalid storage account tier
run "invalid_storage_tier_test" {
  command = plan

  variables {
    storage_account_tier = "Basic"
  }

  expect_failures = [
    var.storage_account_tier
  ]
}

# Test valid storage replication type
run "valid_replication_type_test" {
  command = plan

  variables {
    storage_replication_type = "GZRS"
  }

  assert {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_replication_type)
    error_message = "Replication type should be one of the allowed values"
  }
}

# Test invalid storage replication type
run "invalid_replication_type_test" {
  command = plan

  variables {
    storage_replication_type = "INVALID"
  }

  expect_failures = [
    var.storage_replication_type
  ]
}

# Test valid container name
run "valid_container_name_test" {
  command = plan

  variables {
    container_name = "my-tfstate"
  }

  assert {
    condition     = can(regex("^[a-z0-9-]{3,63}$", var.container_name))
    error_message = "Container name should accept valid format"
  }
}

# Test invalid container name with uppercase
run "invalid_container_name_uppercase_test" {
  command = plan

  variables {
    container_name = "MyTfstate"
  }

  expect_failures = [
    var.container_name
  ]
}

# Test valid blob soft delete retention
run "valid_blob_retention_test" {
  command = plan

  variables {
    blob_soft_delete_retention_days = 30
  }

  assert {
    condition     = var.blob_soft_delete_retention_days >= 1 && var.blob_soft_delete_retention_days <= 365
    error_message = "Blob retention should be within valid range"
  }
}

# Test invalid blob soft delete retention
run "invalid_blob_retention_test" {
  command = plan

  variables {
    blob_soft_delete_retention_days = 400
  }

  expect_failures = [
    var.blob_soft_delete_retention_days
  ]
}

# Test valid container soft delete retention
run "valid_container_retention_test" {
  command = plan

  variables {
    container_soft_delete_retention_days = 30
  }

  assert {
    condition     = var.container_soft_delete_retention_days >= 1 && var.container_soft_delete_retention_days <= 365
    error_message = "Container retention should be within valid range"
  }
}

# Test invalid container soft delete retention
run "invalid_container_retention_test" {
  command = plan

  variables {
    container_soft_delete_retention_days = 400
  }

  expect_failures = [
    var.container_soft_delete_retention_days
  ]
}

# Test valid network default action
run "valid_network_default_action_test" {
  command = plan

  variables {
    network_default_action = "Deny"
  }

  assert {
    condition     = contains(["Allow", "Deny"], var.network_default_action)
    error_message = "Network default action should be Allow or Deny"
  }
}

# Test invalid network default action
run "invalid_network_default_action_test" {
  command = plan

  variables {
    network_default_action = "Block"
  }

  expect_failures = [
    var.network_default_action
  ]
}

# Test valid key vault SKU
run "valid_key_vault_sku_test" {
  command = plan

  variables {
    key_vault_sku = "premium"
  }

  assert {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "Key Vault SKU should be standard or premium"
  }
}

# Test invalid key vault SKU
run "invalid_key_vault_sku_test" {
  command = plan

  variables {
    key_vault_sku = "basic"
  }

  expect_failures = [
    var.key_vault_sku
  ]
}

# Test valid key vault soft delete retention
run "valid_key_vault_retention_test" {
  command = plan

  variables {
    key_vault_soft_delete_retention_days = 30
  }

  assert {
    condition     = var.key_vault_soft_delete_retention_days >= 7 && var.key_vault_soft_delete_retention_days <= 90
    error_message = "Key Vault retention should be between 7 and 90 days"
  }
}

# Test invalid key vault soft delete retention
run "invalid_key_vault_retention_test" {
  command = plan

  variables {
    key_vault_soft_delete_retention_days = 100
  }

  expect_failures = [
    var.key_vault_soft_delete_retention_days
  ]
}

# Test valid log analytics SKU
run "valid_log_analytics_sku_test" {
  command = plan

  variables {
    log_analytics_sku = "PerGB2018"
  }

  assert {
    condition     = contains(["Free", "Standalone", "PerNode", "PerGB2018"], var.log_analytics_sku)
    error_message = "Log Analytics SKU should be one of the allowed values"
  }
}

# Test invalid log analytics SKU
run "invalid_log_analytics_sku_test" {
  command = plan

  variables {
    log_analytics_sku = "Invalid"
  }

  expect_failures = [
    var.log_analytics_sku
  ]
}

# Test valid log analytics retention
run "valid_log_analytics_retention_test" {
  command = plan

  variables {
    log_analytics_retention_days = 90
  }

  assert {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "Log Analytics retention should be between 30 and 730 days"
  }
}

# Test invalid log analytics retention
run "invalid_log_analytics_retention_test" {
  command = plan

  variables {
    log_analytics_retention_days = 800
  }

  expect_failures = [
    var.log_analytics_retention_days
  ]
}

# Test valid location short code
run "valid_location_short_test" {
  command = plan

  variables {
    location_short = "wus"
  }

  assert {
    condition     = can(regex("^[a-z]{2,4}$", var.location_short))
    error_message = "Location short should be valid format"
  }
}

# Test invalid location short code
run "invalid_location_short_test" {
  command = plan

  variables {
    location_short = "INVALID"
  }

  expect_failures = [
    var.location_short
  ]
}

# Test required tags validation
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

# Test custom storage account name validation
run "valid_custom_storage_name_test" {
  command = plan

  variables {
    storage_account_name = "customname123"
  }

  assert {
    condition     = var.storage_account_name == "" || can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Custom storage account name should be valid or empty"
  }
}

# Test invalid custom storage account name
run "invalid_custom_storage_name_test" {
  command = plan

  variables {
    storage_account_name = "Invalid-Name!"
  }

  expect_failures = [
    var.storage_account_name
  ]
}

# Test custom key vault name validation
run "valid_custom_key_vault_name_test" {
  command = plan

  variables {
    key_vault_name = "custom-kv-name"
  }

  assert {
    condition     = var.key_vault_name == "" || can(regex("^[a-zA-Z0-9-]{3,24}$", var.key_vault_name))
    error_message = "Custom key vault name should be valid or empty"
  }
}

# Test invalid custom key vault name
run "invalid_custom_key_vault_name_test" {
  command = plan

  variables {
    key_vault_name = "invalid_name!"
  }

  expect_failures = [
    var.key_vault_name
  ]
}

# Test boolean flags functionality
run "boolean_flags_test" {
  command = plan

  variables {
    enable_state_locking                  = true
    enable_blob_versioning                = true
    enable_shared_access_key              = false
    enable_public_network_access          = false
    enable_network_restrictions           = true
    enable_key_vault                      = true
    enable_key_vault_rbac                 = true
    enable_key_vault_purge_protection     = true
    enable_key_vault_public_access        = false
    enable_key_vault_network_restrictions = true
    enable_monitoring                     = true
    use_naming_convention                 = true
  }

  assert {
    condition     = var.enable_state_locking == true && var.enable_blob_versioning == true
    error_message = "Boolean variables should accept true/false values"
  }
}