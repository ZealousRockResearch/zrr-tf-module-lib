# Variable validation tests for key-vault-secret module

variables {
  name         = "test-secret"
  value        = "test-value"
  key_vault_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-kv"
}

run "valid_name_test" {
  command = plan

  assert {
    condition     = var.name == "test-secret"
    error_message = "Name variable should accept valid secret names"
  }
}

run "invalid_name_test" {
  command = plan

  variables {
    name         = "invalid@secret!"
    value        = "test-value"
    key_vault_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-kv"
  }

  expect_failures = [
    var.name
  ]
}

run "long_name_test" {
  command = plan

  variables {
    name         = "this-is-a-very-long-secret-name-that-exceeds-the-maximum-allowed-length-of-127-characters-and-should-fail-validation-test"
    value        = "test-value"
    key_vault_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-kv"
  }

  expect_failures = [
    var.name
  ]
}

run "empty_value_test" {
  command = plan

  variables {
    name         = "test-secret"
    value        = ""
    key_vault_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-kv"
  }

  expect_failures = [
    var.value
  ]
}

run "valid_key_vault_name_with_rg_test" {
  command = plan

  variables {
    name                          = "test-secret"
    value                         = "test-value"
    key_vault_name                = "test-keyvault"
    key_vault_resource_group_name = "test-rg"
    key_vault_id                  = null
  }

  assert {
    condition     = var.key_vault_name == "test-keyvault"
    error_message = "Key vault name should be accepted when resource group is provided"
  }
}

run "invalid_key_vault_name_without_rg_test" {
  command = plan

  variables {
    name                          = "test-secret"
    value                         = "test-value"
    key_vault_name                = "test-keyvault"
    key_vault_resource_group_name = null
    key_vault_id                  = null
  }

  expect_failures = [
    var.key_vault_resource_group_name
  ]
}

run "valid_expiration_date_test" {
  command = plan

  variables {
    name            = "test-secret"
    value           = "test-value"
    key_vault_id    = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-kv"
    expiration_date = "2025-12-31T23:59:59Z"
  }

  assert {
    condition     = var.expiration_date == "2025-12-31T23:59:59Z"
    error_message = "Valid expiration date should be accepted"
  }
}

run "invalid_expiration_date_test" {
  command = plan

  variables {
    name            = "test-secret"
    value           = "test-value"
    key_vault_id    = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-kv"
    expiration_date = "invalid-date"
  }

  expect_failures = [
    var.expiration_date
  ]
}

run "valid_not_before_date_test" {
  command = plan

  variables {
    name            = "test-secret"
    value           = "test-value"
    key_vault_id    = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-kv"
    not_before_date = "2024-01-01T00:00:00Z"
  }

  assert {
    condition     = var.not_before_date == "2024-01-01T00:00:00Z"
    error_message = "Valid not before date should be accepted"
  }
}

run "required_tags_test" {
  command = plan

  variables {
    name         = "test-secret"
    value        = "test-value"
    key_vault_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-kv"
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
    name         = "test-secret"
    value        = "test-value"
    key_vault_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-kv"
    common_tags = {
      Environment = "test"
    }
  }

  expect_failures = [
    var.common_tags
  ]
}