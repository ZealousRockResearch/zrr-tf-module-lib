# Variable validation tests for Azure Storage File Share module

variables {
  name                 = "test-file-share"
  storage_account_name = "teststorageaccount"
  resource_group_name  = "test-rg"
  location             = "East US"
}

run "valid_file_share_name_test" {
  command = plan

  assert {
    condition     = var.name == "test-file-share"
    error_message = "File share name variable should accept valid names"
  }
}

run "invalid_file_share_name_test" {
  command = plan

  variables {
    name                 = "Invalid@Name!"
    storage_account_name = "teststorageaccount"
    resource_group_name  = "test-rg"
  }

  expect_failures = [
    var.name
  ]
}

run "file_share_name_too_short_test" {
  command = plan

  variables {
    name                 = "ab"
    storage_account_name = "teststorageaccount"
    resource_group_name  = "test-rg"
  }

  expect_failures = [
    var.name
  ]
}

run "file_share_name_too_long_test" {
  command = plan

  variables {
    name                 = "this-is-a-very-long-file-share-name-that-exceeds-the-maximum-length"
    storage_account_name = "teststorageaccount"
    resource_group_name  = "test-rg"
  }

  expect_failures = [
    var.name
  ]
}

run "valid_storage_account_name_test" {
  command = plan

  assert {
    condition     = var.storage_account_name == "teststorageaccount"
    error_message = "Storage account name should accept valid names"
  }
}

run "invalid_storage_account_name_test" {
  command = plan

  variables {
    name                 = "test-file-share"
    storage_account_name = "Invalid-Storage-Account"
    resource_group_name  = "test-rg"
  }

  expect_failures = [
    var.storage_account_name
  ]
}

run "valid_location_test" {
  command = plan

  variables {
    location = "West Europe"
  }

  assert {
    condition     = contains(["East US", "East US 2", "West Europe"], var.location)
    error_message = "Location should be a valid Azure region"
  }
}

run "invalid_location_test" {
  command = plan

  variables {
    name                 = "test-file-share"
    storage_account_name = "teststorageaccount"
    resource_group_name  = "test-rg"
    location             = "Invalid Region"
  }

  expect_failures = [
    var.location
  ]
}

run "valid_quota_test" {
  command = plan

  variables {
    quota_gb = 500
  }

  assert {
    condition     = var.quota_gb >= 1 && var.quota_gb <= 102400
    error_message = "Quota should be within valid range"
  }
}

run "invalid_quota_too_small_test" {
  command = plan

  variables {
    name                 = "test-file-share"
    storage_account_name = "teststorageaccount"
    resource_group_name  = "test-rg"
    quota_gb             = 0
  }

  expect_failures = [
    var.quota_gb
  ]
}

run "invalid_quota_too_large_test" {
  command = plan

  variables {
    name                 = "test-file-share"
    storage_account_name = "teststorageaccount"
    resource_group_name  = "test-rg"
    quota_gb             = 200000
  }

  expect_failures = [
    var.quota_gb
  ]
}

run "valid_access_tier_test" {
  command = plan

  variables {
    access_tier = "Premium"
  }

  assert {
    condition     = contains(["Hot", "Cool", "TransactionOptimized", "Premium"], var.access_tier)
    error_message = "Access tier should be valid"
  }
}

run "invalid_access_tier_test" {
  command = plan

  variables {
    name                 = "test-file-share"
    storage_account_name = "teststorageaccount"
    resource_group_name  = "test-rg"
    access_tier          = "InvalidTier"
  }

  expect_failures = [
    var.access_tier
  ]
}

run "valid_protocol_test" {
  command = plan

  variables {
    enabled_protocol = "NFS"
  }

  assert {
    condition     = contains(["SMB", "NFS"], var.enabled_protocol)
    error_message = "Enabled protocol should be valid"
  }
}

run "invalid_protocol_test" {
  command = plan

  variables {
    name                 = "test-file-share"
    storage_account_name = "teststorageaccount"
    resource_group_name  = "test-rg"
    enabled_protocol     = "FTP"
  }

  expect_failures = [
    var.enabled_protocol
  ]
}

run "valid_backup_vault_sku_test" {
  command = plan

  variables {
    backup_vault_sku = "RS0"
  }

  assert {
    condition     = contains(["Standard", "RS0"], var.backup_vault_sku)
    error_message = "Backup vault SKU should be valid"
  }
}

run "invalid_backup_vault_sku_test" {
  command = plan

  variables {
    name                 = "test-file-share"
    storage_account_name = "teststorageaccount"
    resource_group_name  = "test-rg"
    backup_vault_sku     = "InvalidSKU"
  }

  expect_failures = [
    var.backup_vault_sku
  ]
}

run "valid_backup_policy_frequency_test" {
  command = plan

  variables {
    backup_policy = {
      frequency = "Daily"
      time      = "02:00"
    }
  }

  assert {
    condition     = var.backup_policy.frequency == "Daily"
    error_message = "Backup policy frequency should be Daily"
  }
}

run "valid_backup_policy_time_test" {
  command = plan

  variables {
    backup_policy = {
      frequency = "Daily"
      time      = "23:59"
    }
  }

  assert {
    condition     = can(regex("^([0-1][0-9]|2[0-3]):[0-5][0-9]$", var.backup_policy.time))
    error_message = "Backup policy time should be in HH:MM format"
  }
}

run "invalid_backup_policy_time_test" {
  command = plan

  variables {
    name                 = "test-file-share"
    storage_account_name = "teststorageaccount"
    resource_group_name  = "test-rg"
    backup_policy = {
      frequency = "Daily"
      time      = "25:70"
    }
  }

  expect_failures = [
    var.backup_policy
  ]
}

run "valid_email_addresses_test" {
  command = plan

  variables {
    alert_email_addresses = ["admin@company.com", "devops@company.com"]
  }

  assert {
    condition     = length(var.alert_email_addresses) == 2
    error_message = "Should accept valid email addresses"
  }
}

run "invalid_email_addresses_test" {
  command = plan

  variables {
    name                  = "test-file-share"
    storage_account_name  = "teststorageaccount"
    resource_group_name   = "test-rg"
    alert_email_addresses = ["invalid-email", "admin@company.com"]
  }

  expect_failures = [
    var.alert_email_addresses
  ]
}

run "valid_quota_alert_threshold_test" {
  command = plan

  variables {
    quota_alert_threshold_percentage = 85
  }

  assert {
    condition     = var.quota_alert_threshold_percentage >= 0 && var.quota_alert_threshold_percentage <= 100
    error_message = "Quota alert threshold should be between 0 and 100"
  }
}

run "invalid_quota_alert_threshold_test" {
  command = plan

  variables {
    name                             = "test-file-share"
    storage_account_name             = "teststorageaccount"
    resource_group_name              = "test-rg"
    quota_alert_threshold_percentage = 150
  }

  expect_failures = [
    var.quota_alert_threshold_percentage
  ]
}

run "valid_alert_severity_test" {
  command = plan

  variables {
    quota_alert_severity = 2
  }

  assert {
    condition     = var.quota_alert_severity >= 0 && var.quota_alert_severity <= 4
    error_message = "Alert severity should be between 0 and 4"
  }
}

run "invalid_alert_severity_test" {
  command = plan

  variables {
    name                 = "test-file-share"
    storage_account_name = "teststorageaccount"
    resource_group_name  = "test-rg"
    quota_alert_severity = 5
  }

  expect_failures = [
    var.quota_alert_severity
  ]
}

run "required_common_tags_test" {
  command = plan

  variables {
    common_tags = {
      Environment = "test"
      Project     = "zrr-test"
      ManagedBy   = "Terraform"
    }
  }

  assert {
    condition     = can(var.common_tags["Environment"]) && can(var.common_tags["Project"])
    error_message = "Common tags must include Environment and Project"
  }
}

run "missing_required_common_tags_test" {
  command = plan

  variables {
    name                 = "test-file-share"
    storage_account_name = "teststorageaccount"
    resource_group_name  = "test-rg"
    common_tags = {
      ManagedBy = "Terraform"
    }
  }

  expect_failures = [
    var.common_tags
  ]
}