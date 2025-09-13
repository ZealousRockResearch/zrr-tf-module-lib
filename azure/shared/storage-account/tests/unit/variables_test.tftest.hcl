# Variable validation tests for Azure Storage Account module

variables {
  name                = "teststorageaccount"
  resource_group_name = "rg-test"
  environment         = "dev"
}

# Test valid storage account name
run "valid_name_test" {
  command = plan

  assert {
    condition     = var.name == "teststorageaccount"
    error_message = "Name variable should accept valid storage account names"
  }
}

# Test invalid storage account name with uppercase
run "invalid_name_uppercase_test" {
  command = plan

  variables {
    name = "TestStorageAccount"
  }

  expect_failures = [
    var.name
  ]
}

# Test invalid storage account name with special characters
run "invalid_name_special_chars_test" {
  command = plan

  variables {
    name = "test-storage-account"
  }

  expect_failures = [
    var.name
  ]
}

# Test invalid storage account name too short
run "invalid_name_too_short_test" {
  command = plan

  variables {
    name = "ab"
  }

  expect_failures = [
    var.name
  ]
}

# Test invalid storage account name too long
run "invalid_name_too_long_test" {
  command = plan

  variables {
    name = "thisstorageaccountnameistoolong"
  }

  expect_failures = [
    var.name
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

# Test valid account tier
run "valid_account_tier_test" {
  command = plan

  variables {
    account_tier = "Premium"
  }

  assert {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier should be Standard or Premium"
  }
}

# Test invalid account tier
run "invalid_account_tier_test" {
  command = plan

  variables {
    account_tier = "Basic"
  }

  expect_failures = [
    var.account_tier
  ]
}

# Test valid replication type
run "valid_replication_type_test" {
  command = plan

  variables {
    replication_type = "GZRS"
  }

  assert {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.replication_type)
    error_message = "Replication type should be one of the allowed values"
  }
}

# Test invalid replication type
run "invalid_replication_type_test" {
  command = plan

  variables {
    replication_type = "INVALID"
  }

  expect_failures = [
    var.replication_type
  ]
}

# Test valid account kind
run "valid_account_kind_test" {
  command = plan

  variables {
    account_kind = "BlockBlobStorage"
  }

  assert {
    condition     = contains(["Storage", "StorageV2", "BlobStorage", "FileStorage", "BlockBlobStorage"], var.account_kind)
    error_message = "Account kind should be one of the allowed values"
  }
}

# Test invalid account kind
run "invalid_account_kind_test" {
  command = plan

  variables {
    account_kind = "InvalidStorage"
  }

  expect_failures = [
    var.account_kind
  ]
}

# Test valid access tier
run "valid_access_tier_test" {
  command = plan

  variables {
    access_tier = "Cool"
  }

  assert {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "Access tier should be Hot or Cool"
  }
}

# Test invalid access tier
run "invalid_access_tier_test" {
  command = plan

  variables {
    access_tier = "Archive"
  }

  expect_failures = [
    var.access_tier
  ]
}

# Test valid TLS version
run "valid_tls_version_test" {
  command = plan

  variables {
    min_tls_version = "TLS1_1"
  }

  assert {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "TLS version should be one of the allowed values"
  }
}

# Test invalid TLS version
run "invalid_tls_version_test" {
  command = plan

  variables {
    min_tls_version = "TLS1_3"
  }

  expect_failures = [
    var.min_tls_version
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

# Test valid network bypass
run "valid_network_bypass_test" {
  command = plan

  variables {
    network_bypass = ["AzureServices", "Logging"]
  }

  assert {
    condition     = length(var.network_bypass) == 2
    error_message = "Network bypass should accept valid values"
  }
}

# Test invalid network bypass
run "invalid_network_bypass_test" {
  command = plan

  variables {
    network_bypass = ["InvalidService"]
  }

  expect_failures = [
    var.network_bypass
  ]
}

# Test valid private endpoint subresource names
run "valid_private_endpoint_subresources_test" {
  command = plan

  variables {
    private_endpoint_subresource_names = ["blob", "file", "queue", "table"]
  }

  assert {
    condition     = length(var.private_endpoint_subresource_names) == 4
    error_message = "Private endpoint subresource names should accept valid values"
  }
}

# Test invalid private endpoint subresource names
run "invalid_private_endpoint_subresources_test" {
  command = plan

  variables {
    private_endpoint_subresource_names = ["invalid"]
  }

  expect_failures = [
    var.private_endpoint_subresource_names
  ]
}

# Test valid blob change feed retention days
run "valid_blob_change_feed_retention_test" {
  command = plan

  variables {
    blob_change_feed_retention_days = 30
  }

  assert {
    condition     = var.blob_change_feed_retention_days >= 1 && var.blob_change_feed_retention_days <= 146000
    error_message = "Blob change feed retention days should be within valid range"
  }
}

# Test invalid blob change feed retention days
run "invalid_blob_change_feed_retention_test" {
  command = plan

  variables {
    blob_change_feed_retention_days = 200000
  }

  expect_failures = [
    var.blob_change_feed_retention_days
  ]
}

# Test valid blob delete retention days
run "valid_blob_delete_retention_test" {
  command = plan

  variables {
    blob_delete_retention_days = 30
  }

  assert {
    condition     = var.blob_delete_retention_days >= 1 && var.blob_delete_retention_days <= 365
    error_message = "Blob delete retention days should be within valid range"
  }
}

# Test invalid blob delete retention days
run "invalid_blob_delete_retention_test" {
  command = plan

  variables {
    blob_delete_retention_days = 400
  }

  expect_failures = [
    var.blob_delete_retention_days
  ]
}

# Test valid blob restore days
run "valid_blob_restore_days_test" {
  command = plan

  variables {
    blob_restore_days = 7
  }

  assert {
    condition     = var.blob_restore_days >= 0 && var.blob_restore_days <= 365
    error_message = "Blob restore days should be within valid range"
  }
}

# Test invalid blob restore days
run "invalid_blob_restore_days_test" {
  command = plan

  variables {
    blob_restore_days = 400
  }

  expect_failures = [
    var.blob_restore_days
  ]
}

# Test valid container delete retention days
run "valid_container_delete_retention_test" {
  command = plan

  variables {
    container_delete_retention_days = 30
  }

  assert {
    condition     = var.container_delete_retention_days >= 1 && var.container_delete_retention_days <= 365
    error_message = "Container delete retention days should be within valid range"
  }
}

# Test invalid container delete retention days
run "invalid_container_delete_retention_test" {
  command = plan

  variables {
    container_delete_retention_days = 400
  }

  expect_failures = [
    var.container_delete_retention_days
  ]
}

# Test valid share retention days
run "valid_share_retention_test" {
  command = plan

  variables {
    share_retention_days = 30
  }

  assert {
    condition     = var.share_retention_days >= 0 && var.share_retention_days <= 365
    error_message = "Share retention days should be within valid range"
  }
}

# Test invalid share retention days
run "invalid_share_retention_test" {
  command = plan

  variables {
    share_retention_days = 400
  }

  expect_failures = [
    var.share_retention_days
  ]
}

# Test valid identity type
run "valid_identity_type_test" {
  command = plan

  variables {
    identity_type = "SystemAssigned, UserAssigned"
  }

  assert {
    condition     = contains(["", "SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Identity type should be one of the allowed values"
  }
}

# Test invalid identity type
run "invalid_identity_type_test" {
  command = plan

  variables {
    identity_type = "InvalidIdentity"
  }

  expect_failures = [
    var.identity_type
  ]
}

# Test valid container access types
run "valid_container_access_types_test" {
  command = plan

  variables {
    containers = [
      {
        name        = "test-container"
        access_type = "blob"
      }
    ]
  }

  assert {
    condition     = length(var.containers) == 1
    error_message = "Should accept valid container access types"
  }
}

# Test invalid container access type
run "invalid_container_access_type_test" {
  command = plan

  variables {
    containers = [
      {
        name        = "test-container"
        access_type = "invalid"
      }
    ]
  }

  expect_failures = [
    var.containers
  ]
}

# Test valid file share protocol
run "valid_file_share_protocol_test" {
  command = plan

  variables {
    file_shares = [
      {
        name     = "test-share"
        protocol = "NFS"
      }
    ]
  }

  assert {
    condition     = length(var.file_shares) == 1
    error_message = "Should accept valid file share protocols"
  }
}

# Test invalid file share protocol
run "invalid_file_share_protocol_test" {
  command = plan

  variables {
    file_shares = [
      {
        name     = "test-share"
        protocol = "INVALID"
      }
    ]
  }

  expect_failures = [
    var.file_shares
  ]
}

# Test valid file share access tier
run "valid_file_share_access_tier_test" {
  command = plan

  variables {
    file_shares = [
      {
        name        = "test-share"
        access_tier = "Premium"
      }
    ]
  }

  assert {
    condition     = length(var.file_shares) == 1
    error_message = "Should accept valid file share access tiers"
  }
}

# Test invalid file share access tier
run "invalid_file_share_access_tier_test" {
  command = plan

  variables {
    file_shares = [
      {
        name        = "test-share"
        access_tier = "Invalid"
      }
    ]
  }

  expect_failures = [
    var.file_shares
  ]
}

# Test valid location short code
run "valid_location_short_test" {
  command = plan

  variables {
    location_short = "weu"
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

# Test boolean flags functionality
run "boolean_flags_test" {
  command = plan

  variables {
    enable_https_traffic_only        = true
    allow_public_access              = false
    enable_shared_access_key         = true
    enable_public_network_access     = true
    enable_infrastructure_encryption = true
    enable_network_rules             = false
    enable_private_endpoints         = false
    enable_blob_properties           = true
    blob_versioning_enabled          = true
    blob_change_feed_enabled         = true
    blob_last_access_time_enabled    = true
    enable_queue_properties          = false
    enable_share_properties          = false
    enable_static_website            = false
    enable_lifecycle_management      = false
    use_naming_convention            = true
  }

  assert {
    condition     = var.enable_https_traffic_only == true && var.allow_public_access == false
    error_message = "Boolean variables should accept true/false values"
  }
}