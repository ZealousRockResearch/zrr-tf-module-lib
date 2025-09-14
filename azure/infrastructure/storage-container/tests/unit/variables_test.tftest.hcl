# Variable validation tests for storage-container module

variables {
  name                                = "test-container"
  storage_account_name                = "teststorageacct"
  storage_account_resource_group_name = "test-rg"
}

run "valid_container_name_test" {
  command = plan

  assert {
    condition     = var.name == "test-container"
    error_message = "Container name variable should accept valid names"
  }
}

run "invalid_container_name_uppercase_test" {
  command = plan

  variables {
    name                                = "Test-Container"
    storage_account_name                = "teststorageacct"
    storage_account_resource_group_name = "test-rg"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_container_name_short_test" {
  command = plan

  variables {
    name                                = "ab"
    storage_account_name                = "teststorageacct"
    storage_account_resource_group_name = "test-rg"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_container_name_consecutive_hyphens_test" {
  command = plan

  variables {
    name                                = "test--container"
    storage_account_name                = "teststorageacct"
    storage_account_resource_group_name = "test-rg"
  }

  expect_failures = [
    var.name
  ]
}

run "valid_container_access_private_test" {
  command = plan

  variables {
    name                                = "test-container"
    storage_account_name                = "teststorageacct"
    storage_account_resource_group_name = "test-rg"
    container_access_type               = "private"
  }

  assert {
    condition     = var.container_access_type == "private"
    error_message = "Container access type private should be accepted"
  }
}

run "valid_container_access_blob_test" {
  command = plan

  variables {
    name                                = "test-container"
    storage_account_name                = "teststorageacct"
    storage_account_resource_group_name = "test-rg"
    container_access_type               = "blob"
  }

  assert {
    condition     = var.container_access_type == "blob"
    error_message = "Container access type blob should be accepted"
  }
}

run "invalid_container_access_test" {
  command = plan

  variables {
    name                                = "test-container"
    storage_account_name                = "teststorageacct"
    storage_account_resource_group_name = "test-rg"
    container_access_type               = "invalid"
  }

  expect_failures = [
    var.container_access_type
  ]
}

run "valid_storage_account_name_with_rg_test" {
  command = plan

  variables {
    name                                = "test-container"
    storage_account_name                = "teststorageacct"
    storage_account_resource_group_name = "test-rg"
    storage_account_id                  = null
  }

  assert {
    condition     = var.storage_account_name == "teststorageacct"
    error_message = "Storage account name should be accepted when resource group is provided"
  }
}

run "invalid_storage_account_name_without_rg_test" {
  command = plan

  variables {
    name                                = "test-container"
    storage_account_name                = "teststorageacct"
    storage_account_resource_group_name = null
    storage_account_id                  = null
  }

  expect_failures = [
    var.storage_account_resource_group_name
  ]
}

run "valid_lifecycle_rule_test" {
  command = plan

  variables {
    name                                = "test-container"
    storage_account_name                = "teststorageacct"
    storage_account_resource_group_name = "test-rg"
    lifecycle_rules = [
      {
        name                       = "test-rule"
        enabled                    = true
        prefix_match               = ["logs/"]
        blob_types                 = ["blockBlob"]
        tier_to_cool_after_days    = 30
        tier_to_archive_after_days = 90
        delete_after_days          = 365
      }
    ]
  }

  assert {
    condition     = length(var.lifecycle_rules) == 1
    error_message = "Valid lifecycle rule should be accepted"
  }
}

run "invalid_lifecycle_rule_negative_days_test" {
  command = plan

  variables {
    name                                = "test-container"
    storage_account_name                = "teststorageacct"
    storage_account_resource_group_name = "test-rg"
    lifecycle_rules = [
      {
        name                    = "test-rule"
        enabled                 = true
        prefix_match            = ["logs/"]
        blob_types              = ["blockBlob"]
        tier_to_cool_after_days = -1
      }
    ]
  }

  expect_failures = [
    var.lifecycle_rules
  ]
}

run "valid_legal_hold_test" {
  command = plan

  variables {
    name                                = "test-container"
    storage_account_name                = "teststorageacct"
    storage_account_resource_group_name = "test-rg"
    legal_hold = {
      tags = ["litigation-2024", "compliance"]
    }
  }

  assert {
    condition     = length(var.legal_hold.tags) == 2
    error_message = "Valid legal hold should be accepted"
  }
}

run "invalid_legal_hold_too_many_tags_test" {
  command = plan

  variables {
    name                                = "test-container"
    storage_account_name                = "teststorageacct"
    storage_account_resource_group_name = "test-rg"
    legal_hold = {
      tags = ["tag1", "tag2", "tag3", "tag4", "tag5", "tag6", "tag7", "tag8", "tag9", "tag10", "tag11"]
    }
  }

  expect_failures = [
    var.legal_hold
  ]
}

run "valid_immutability_policy_test" {
  command = plan

  variables {
    name                                = "test-container"
    storage_account_name                = "teststorageacct"
    storage_account_resource_group_name = "test-rg"
    immutability_policy = {
      period_in_days = 365
      locked         = false
    }
  }

  assert {
    condition     = var.immutability_policy.period_in_days == 365
    error_message = "Valid immutability policy should be accepted"
  }
}

run "invalid_immutability_policy_period_test" {
  command = plan

  variables {
    name                                = "test-container"
    storage_account_name                = "teststorageacct"
    storage_account_resource_group_name = "test-rg"
    immutability_policy = {
      period_in_days = 0
      locked         = false
    }
  }

  expect_failures = [
    var.immutability_policy
  ]
}

run "required_tags_test" {
  command = plan

  variables {
    name                                = "test-container"
    storage_account_name                = "teststorageacct"
    storage_account_resource_group_name = "test-rg"
    common_tags = {
      Environment = "test"
      Project     = "validation"
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
    name                                = "test-container"
    storage_account_name                = "teststorageacct"
    storage_account_resource_group_name = "test-rg"
    common_tags = {
      Environment = "test"
    }
  }

  expect_failures = [
    var.common_tags
  ]
}