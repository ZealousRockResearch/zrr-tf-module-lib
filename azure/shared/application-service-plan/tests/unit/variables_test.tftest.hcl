# Variable validation tests for Azure App Service Plan module

variables {
  name                = "test-service-plan"
  resource_group_name = "test-rg"
}

# Test valid service plan name
run "valid_name_test" {
  command = plan

  assert {
    condition     = var.name == "test-service-plan"
    error_message = "Name variable should accept valid service plan names"
  }
}

# Test invalid service plan name (too long)
run "invalid_name_length_test" {
  command = plan

  variables {
    name = "this-service-plan-name-is-way-too-long-and-exceeds-the-maximum-allowed-length-for-azure-app-service-plans"
  }

  expect_failures = [
    var.name
  ]
}

# Test invalid service plan name (special characters)
run "invalid_name_characters_test" {
  command = plan

  variables {
    name = "invalid@name!"
  }

  expect_failures = [
    var.name
  ]
}

# Test valid OS types
run "valid_os_type_linux_test" {
  command = plan

  variables {
    os_type = "Linux"
  }

  assert {
    condition     = var.os_type == "Linux"
    error_message = "Should accept Linux OS type"
  }
}

run "valid_os_type_windows_test" {
  command = plan

  variables {
    os_type = "Windows"
  }

  assert {
    condition     = var.os_type == "Windows"
    error_message = "Should accept Windows OS type"
  }
}

# Test invalid OS type
run "invalid_os_type_test" {
  command = plan

  variables {
    os_type = "MacOS"
  }

  expect_failures = [
    var.os_type
  ]
}

# Test valid SKU names
run "valid_sku_basic_test" {
  command = plan

  variables {
    sku_name = "B1"
  }

  assert {
    condition     = var.sku_name == "B1"
    error_message = "Should accept valid Basic SKU"
  }
}

run "valid_sku_standard_test" {
  command = plan

  variables {
    sku_name = "S1"
  }

  assert {
    condition     = var.sku_name == "S1"
    error_message = "Should accept valid Standard SKU"
  }
}

run "valid_sku_premium_v2_test" {
  command = plan

  variables {
    sku_name = "P1v2"
  }

  assert {
    condition     = var.sku_name == "P1v2"
    error_message = "Should accept valid Premium v2 SKU"
  }
}

run "valid_sku_premium_v3_test" {
  command = plan

  variables {
    sku_name = "P1v3"
  }

  assert {
    condition     = var.sku_name == "P1v3"
    error_message = "Should accept valid Premium v3 SKU"
  }
}

run "valid_sku_isolated_test" {
  command = plan

  variables {
    sku_name = "I1"
  }

  assert {
    condition     = var.sku_name == "I1"
    error_message = "Should accept valid Isolated SKU"
  }
}

# Test invalid SKU name
run "invalid_sku_test" {
  command = plan

  variables {
    sku_name = "INVALID_SKU"
  }

  expect_failures = [
    var.sku_name
  ]
}

# Test worker_count validation
run "valid_worker_count_test" {
  command = plan

  variables {
    worker_count = 5
  }

  assert {
    condition     = var.worker_count >= 1 && var.worker_count <= 30
    error_message = "Worker count should be within valid range"
  }
}

run "invalid_worker_count_too_small_test" {
  command = plan

  variables {
    worker_count = 0
  }

  expect_failures = [
    var.worker_count
  ]
}

run "invalid_worker_count_too_large_test" {
  command = plan

  variables {
    worker_count = 50
  }

  expect_failures = [
    var.worker_count
  ]
}

# Test maximum_elastic_worker_count validation
run "valid_elastic_worker_count_test" {
  command = plan

  variables {
    maximum_elastic_worker_count = 20
  }

  assert {
    condition     = var.maximum_elastic_worker_count == null || (var.maximum_elastic_worker_count >= 1 && var.maximum_elastic_worker_count <= 100)
    error_message = "Elastic worker count should be within valid range"
  }
}

run "invalid_elastic_worker_count_too_large_test" {
  command = plan

  variables {
    maximum_elastic_worker_count = 150
  }

  expect_failures = [
    var.maximum_elastic_worker_count
  ]
}

# Test autoscale_settings validation
run "valid_autoscale_settings_test" {
  command = plan

  variables {
    autoscale_settings = {
      default_instances     = 3
      minimum_instances     = 2
      maximum_instances     = 10
      cpu_threshold_out     = 70
      cpu_threshold_in      = 25
      memory_threshold_out  = 80
      memory_threshold_in   = 60
      enable_memory_scaling = true
      scale_out_cooldown    = 5
      scale_in_cooldown     = 10
    }
  }

  assert {
    condition = (
      var.autoscale_settings.minimum_instances <= var.autoscale_settings.default_instances &&
      var.autoscale_settings.default_instances <= var.autoscale_settings.maximum_instances
    )
    error_message = "Auto-scale instances should follow min <= default <= max"
  }
}

run "invalid_autoscale_settings_instance_order_test" {
  command = plan

  variables {
    autoscale_settings = {
      default_instances = 2
      minimum_instances = 5
      maximum_instances = 10
      cpu_threshold_out = 70
      cpu_threshold_in  = 25
    }
  }

  expect_failures = [
    var.autoscale_settings
  ]
}

run "invalid_autoscale_settings_cpu_thresholds_test" {
  command = plan

  variables {
    autoscale_settings = {
      default_instances = 3
      minimum_instances = 2
      maximum_instances = 10
      cpu_threshold_out = 30 # Should be > cpu_threshold_in
      cpu_threshold_in  = 70
    }
  }

  expect_failures = [
    var.autoscale_settings
  ]
}

run "invalid_autoscale_settings_too_many_instances_test" {
  command = plan

  variables {
    autoscale_settings = {
      default_instances = 50
      minimum_instances = 40
      maximum_instances = 150 # Should be <= 100
      cpu_threshold_out = 70
      cpu_threshold_in  = 25
    }
  }

  expect_failures = [
    var.autoscale_settings
  ]
}

# Test CPU alert settings validation
run "valid_cpu_alert_settings_test" {
  command = plan

  variables {
    cpu_alert_settings = {
      enabled   = true
      threshold = 80
      severity  = 2
    }
  }

  assert {
    condition = (
      var.cpu_alert_settings.threshold >= 1 &&
      var.cpu_alert_settings.threshold <= 100 &&
      contains([0, 1, 2, 3, 4], var.cpu_alert_settings.severity)
    )
    error_message = "CPU alert settings should be valid"
  }
}

run "invalid_cpu_alert_threshold_test" {
  command = plan

  variables {
    cpu_alert_settings = {
      enabled   = true
      threshold = 150 # Should be <= 100
      severity  = 2
    }
  }

  expect_failures = [
    var.cpu_alert_settings
  ]
}

run "invalid_cpu_alert_severity_test" {
  command = plan

  variables {
    cpu_alert_settings = {
      enabled   = true
      threshold = 80
      severity  = 5 # Should be 0-4
    }
  }

  expect_failures = [
    var.cpu_alert_settings
  ]
}

# Test memory alert settings validation
run "valid_memory_alert_settings_test" {
  command = plan

  variables {
    memory_alert_settings = {
      enabled   = true
      threshold = 85
      severity  = 1
    }
  }

  assert {
    condition = (
      var.memory_alert_settings.threshold >= 1 &&
      var.memory_alert_settings.threshold <= 100 &&
      contains([0, 1, 2, 3, 4], var.memory_alert_settings.severity)
    )
    error_message = "Memory alert settings should be valid"
  }
}

run "invalid_memory_alert_threshold_test" {
  command = plan

  variables {
    memory_alert_settings = {
      enabled   = true
      threshold = 0 # Should be >= 1
      severity  = 2
    }
  }

  expect_failures = [
    var.memory_alert_settings
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

# Test boolean variables
run "valid_zone_balancing_test" {
  command = plan

  variables {
    zone_balancing_enabled = true
  }

  assert {
    condition     = var.zone_balancing_enabled == true
    error_message = "Zone balancing should accept boolean values"
  }
}

run "valid_per_site_scaling_test" {
  command = plan

  variables {
    per_site_scaling_enabled = false
  }

  assert {
    condition     = var.per_site_scaling_enabled == false
    error_message = "Per-site scaling should accept boolean values"
  }
}

run "valid_enable_autoscaling_test" {
  command = plan

  variables {
    enable_autoscaling = true
  }

  assert {
    condition     = var.enable_autoscaling == true
    error_message = "Enable autoscaling should accept boolean values"
  }
}

# Test diagnostic settings validation
run "valid_diagnostic_settings_test" {
  command = plan

  variables {
    enable_diagnostic_settings = true
    diagnostic_log_categories = [
      "AppServicePlatformLogs",
      "AppServiceHTTPLogs"
    ]
    diagnostic_metrics = ["AllMetrics"]
  }

  assert {
    condition = (
      var.enable_diagnostic_settings == true &&
      length(var.diagnostic_log_categories) > 0 &&
      length(var.diagnostic_metrics) > 0
    )
    error_message = "Diagnostic settings should be properly configured"
  }
}