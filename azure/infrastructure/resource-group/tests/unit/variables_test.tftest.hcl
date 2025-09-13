# Variable validation tests for Azure Resource Group module

variables {
  name     = "test-resource-group"
  location = "eastus"
}

# Test valid name
run "valid_name_test" {
  command = plan

  assert {
    condition     = var.name == "test-resource-group"
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

# Test valid location
run "valid_location_test" {
  command = plan

  variables {
    location = "westeurope"
  }

  assert {
    condition     = var.location == "westeurope"
    error_message = "Location should accept valid Azure regions"
  }
}

# Test invalid location
run "invalid_location_test" {
  command = plan

  variables {
    location = "invalid-region"
  }

  expect_failures = [
    var.location
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

# Test lock level validation
run "valid_lock_level_test" {
  command = plan

  variables {
    enable_resource_lock = true
    lock_level           = "ReadOnly"
  }

  assert {
    condition     = contains(["CanNotDelete", "ReadOnly"], var.lock_level)
    error_message = "Lock level should be either CanNotDelete or ReadOnly"
  }
}

# Test invalid lock level
run "invalid_lock_level_test" {
  command = plan

  variables {
    enable_resource_lock = true
    lock_level           = "InvalidLevel"
  }

  expect_failures = [
    var.lock_level
  ]
}

# Test budget amount validation
run "valid_budget_amount_test" {
  command = plan

  variables {
    enable_budget_alert = true
    budget_amount       = 5000
  }

  assert {
    condition     = var.budget_amount > 0
    error_message = "Budget amount must be greater than 0"
  }
}

# Test invalid budget amount
run "invalid_budget_amount_test" {
  command = plan

  variables {
    enable_budget_alert = true
    budget_amount       = -100
  }

  expect_failures = [
    var.budget_amount
  ]
}

# Test budget threshold percentage
run "valid_budget_threshold_test" {
  command = plan

  variables {
    budget_threshold_percentage = 90
  }

  assert {
    condition     = var.budget_threshold_percentage > 0 && var.budget_threshold_percentage <= 100
    error_message = "Budget threshold must be between 0 and 100"
  }
}

# Test invalid budget threshold
run "invalid_budget_threshold_test" {
  command = plan

  variables {
    budget_threshold_percentage = 150
  }

  expect_failures = [
    var.budget_threshold_percentage
  ]
}

# Test valid email addresses
run "valid_email_test" {
  command = plan

  variables {
    budget_contact_emails = ["test@example.com", "admin@company.org"]
  }

  assert {
    condition     = length(var.budget_contact_emails) == 2
    error_message = "Should accept valid email addresses"
  }
}

# Test invalid email addresses
run "invalid_email_test" {
  command = plan

  variables {
    budget_contact_emails = ["invalid-email", "test@"]
  }

  expect_failures = [
    var.budget_contact_emails
  ]
}

# Test budget time grain validation
run "valid_time_grain_test" {
  command = plan

  variables {
    budget_time_grain = "Quarterly"
  }

  assert {
    condition     = contains(["Monthly", "Quarterly", "Annually"], var.budget_time_grain)
    error_message = "Time grain must be one of the allowed values"
  }
}

# Test invalid time grain
run "invalid_time_grain_test" {
  command = plan

  variables {
    budget_time_grain = "Weekly"
  }

  expect_failures = [
    var.budget_time_grain
  ]
}