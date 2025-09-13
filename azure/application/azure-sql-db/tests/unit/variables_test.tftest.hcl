# Variable validation tests for Azure SQL Database module

variables {
  name                = "test-database"
  sql_server_name     = "test-server"
  resource_group_name = "test-rg"
}

# Test valid database name
run "valid_name_test" {
  command = plan

  assert {
    condition     = var.name == "test-database"
    error_message = "Name variable should accept valid database names"
  }
}

# Test invalid database name (too long)
run "invalid_name_length_test" {
  command = plan

  variables {
    name = "this-database-name-is-way-too-long-and-exceeds-the-maximum-allowed-length-for-azure-sql-database-names-which-is-128-characters-so-it-should-fail"
  }

  expect_failures = [
    var.name
  ]
}

# Test invalid database name (special characters)
run "invalid_name_characters_test" {
  command = plan

  variables {
    name = "invalid@name!"
  }

  expect_failures = [
    var.name
  ]
}

# Test valid SKU names
run "valid_sku_serverless_test" {
  command = plan

  variables {
    sku_name = "GP_S_Gen5_1"
  }

  assert {
    condition     = var.sku_name == "GP_S_Gen5_1"
    error_message = "Should accept valid serverless SKU"
  }
}

run "valid_sku_general_purpose_test" {
  command = plan

  variables {
    sku_name = "GP_Gen5_4"
  }

  assert {
    condition     = var.sku_name == "GP_Gen5_4"
    error_message = "Should accept valid general purpose SKU"
  }
}

run "valid_sku_business_critical_test" {
  command = plan

  variables {
    sku_name = "BC_Gen5_8"
  }

  assert {
    condition     = var.sku_name == "BC_Gen5_8"
    error_message = "Should accept valid business critical SKU"
  }
}

# Test invalid SKU name
run "invalid_sku_test" {
  command = plan

  variables {
    sku_name = "INVALID_SKU_NAME"
  }

  expect_failures = [
    var.sku_name
  ]
}

# Test max_size_gb validation
run "valid_max_size_test" {
  command = plan

  variables {
    max_size_gb = 100
  }

  assert {
    condition     = var.max_size_gb >= 0.5 && var.max_size_gb <= 4096
    error_message = "Max size should be within valid range"
  }
}

run "invalid_max_size_too_small_test" {
  command = plan

  variables {
    max_size_gb = 0.1
  }

  expect_failures = [
    var.max_size_gb
  ]
}

run "invalid_max_size_too_large_test" {
  command = plan

  variables {
    max_size_gb = 5000
  }

  expect_failures = [
    var.max_size_gb
  ]
}

# Test auto_pause_delay_in_minutes validation
run "valid_auto_pause_disabled_test" {
  command = plan

  variables {
    auto_pause_delay_in_minutes = -1
  }

  assert {
    condition     = var.auto_pause_delay_in_minutes == -1
    error_message = "Auto pause should accept -1 to disable"
  }
}

run "valid_auto_pause_minimum_test" {
  command = plan

  variables {
    auto_pause_delay_in_minutes = 60
  }

  assert {
    condition     = var.auto_pause_delay_in_minutes >= 60
    error_message = "Auto pause should accept minimum 60 minutes"
  }
}

run "invalid_auto_pause_too_small_test" {
  command = plan

  variables {
    auto_pause_delay_in_minutes = 30
  }

  expect_failures = [
    var.auto_pause_delay_in_minutes
  ]
}

# Test min_capacity validation
run "valid_min_capacity_test" {
  command = plan

  variables {
    min_capacity = 1.0
  }

  assert {
    condition     = var.min_capacity == null || (var.min_capacity >= 0.5 && var.min_capacity <= 80)
    error_message = "Min capacity should be within valid range"
  }
}

run "invalid_min_capacity_too_large_test" {
  command = plan

  variables {
    min_capacity = 100
  }

  expect_failures = [
    var.min_capacity
  ]
}

# Test short_term_retention_days validation
run "valid_retention_minimum_test" {
  command = plan

  variables {
    short_term_retention_days = 7
  }

  assert {
    condition     = var.short_term_retention_days >= 7 && var.short_term_retention_days <= 35
    error_message = "Retention should be within valid range"
  }
}

run "invalid_retention_too_small_test" {
  command = plan

  variables {
    short_term_retention_days = 5
  }

  expect_failures = [
    var.short_term_retention_days
  ]
}

run "invalid_retention_too_large_test" {
  command = plan

  variables {
    short_term_retention_days = 40
  }

  expect_failures = [
    var.short_term_retention_days
  ]
}

# Test backup_interval_in_hours validation
run "valid_backup_interval_12_test" {
  command = plan

  variables {
    backup_interval_in_hours = 12
  }

  assert {
    condition     = contains([12, 24], var.backup_interval_in_hours)
    error_message = "Backup interval should be 12 or 24 hours"
  }
}

run "valid_backup_interval_24_test" {
  command = plan

  variables {
    backup_interval_in_hours = 24
  }

  assert {
    condition     = contains([12, 24], var.backup_interval_in_hours)
    error_message = "Backup interval should be 12 or 24 hours"
  }
}

run "invalid_backup_interval_test" {
  command = plan

  variables {
    backup_interval_in_hours = 6
  }

  expect_failures = [
    var.backup_interval_in_hours
  ]
}

# Test license_type validation
run "valid_license_included_test" {
  command = plan

  variables {
    license_type = "LicenseIncluded"
  }

  assert {
    condition     = contains(["LicenseIncluded", "BasePrice"], var.license_type)
    error_message = "License type should be valid"
  }
}

run "valid_license_base_price_test" {
  command = plan

  variables {
    license_type = "BasePrice"
  }

  assert {
    condition     = contains(["LicenseIncluded", "BasePrice"], var.license_type)
    error_message = "License type should be valid"
  }
}

run "invalid_license_type_test" {
  command = plan

  variables {
    license_type = "InvalidLicense"
  }

  expect_failures = [
    var.license_type
  ]
}

# Test read_replica_count validation
run "valid_replica_count_test" {
  command = plan

  variables {
    read_replica_count = 2
  }

  assert {
    condition     = var.read_replica_count >= 0 && var.read_replica_count <= 4
    error_message = "Read replica count should be within valid range"
  }
}

run "invalid_replica_count_too_many_test" {
  command = plan

  variables {
    read_replica_count = 5
  }

  expect_failures = [
    var.read_replica_count
  ]
}

# Test storage_account_type validation
run "valid_storage_account_type_test" {
  command = plan

  variables {
    storage_account_type = "Geo"
  }

  assert {
    condition     = contains(["Local", "Zone", "Geo", "GeoZone"], var.storage_account_type)
    error_message = "Storage account type should be valid"
  }
}

run "invalid_storage_account_type_test" {
  command = plan

  variables {
    storage_account_type = "InvalidType"
  }

  expect_failures = [
    var.storage_account_type
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
    error_message = "Common tags must include Environment and Project"
  }
}

run "missing_required_tags_test" {
  command = plan

  variables {
    common_tags = {
      ManagedBy = "Terraform"
    }
  }

  expect_failures = [
    var.common_tags
  ]
}

# Test create_mode validation
run "valid_create_mode_test" {
  command = plan

  variables {
    create_mode = "Default"
  }

  assert {
    condition = contains([
      "Default", "Copy", "OnlineSecondary", "PointInTimeRestore",
      "Recovery", "Restore", "RestoreLongTermRetentionBackup"
    ], var.create_mode)
    error_message = "Create mode should be valid"
  }
}

run "invalid_create_mode_test" {
  command = plan

  variables {
    create_mode = "InvalidMode"
  }

  expect_failures = [
    var.create_mode
  ]
}

# Test sql_server configuration validation
run "missing_server_config_test" {
  command = plan

  variables {
    sql_server_id   = null
    sql_server_name = null
  }

  expect_failures = [
    var.sql_server_name
  ]
}