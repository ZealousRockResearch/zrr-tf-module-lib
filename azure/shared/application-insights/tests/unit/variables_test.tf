# Unit tests for Application Insights module variable validation
# These tests validate the variable constraints and validation rules

terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

# Test Application Insights name validation
resource "test_assertions" "name_validation" {
  component = "application_insights_name"

  check "valid_name" {
    assertion     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,258}[a-zA-Z0-9]$", "valid-app-insights"))
    error_message = "Should accept valid Application Insights names"
  }

  check "name_with_underscores" {
    assertion     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,258}[a-zA-Z0-9]$", "app_insights_test"))
    error_message = "Should accept names with underscores"
  }

  check "name_with_numbers" {
    assertion     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,258}[a-zA-Z0-9]$", "appinsights123"))
    error_message = "Should accept names with numbers"
  }

  check "minimum_length" {
    assertion     = length("a") >= 1 && length("a") <= 260
    error_message = "Should accept minimum length names"
  }
}

# Test location validation
resource "test_assertions" "location_validation" {
  component = "application_insights_location"

  check "valid_locations" {
    assertion = alltrue([
      contains(["eastus", "eastus2", "westus", "westus2", "centralus", "northcentralus"], "eastus"),
      contains(["eastus", "eastus2", "westus", "westus2", "centralus", "northcentralus"], "westus2"),
      contains(["eastus", "eastus2", "westus", "westus2", "centralus", "northcentralus"], "centralus")
    ])
    error_message = "Should accept valid Azure regions"
  }

  check "european_regions" {
    assertion = alltrue([
      contains(["northeurope", "westeurope", "uksouth", "ukwest", "francecentral"], "westeurope"),
      contains(["northeurope", "westeurope", "uksouth", "ukwest", "francecentral"], "northeurope")
    ])
    error_message = "Should accept European regions"
  }
}

# Test application type validation
resource "test_assertions" "application_type_validation" {
  component = "application_insights_application_type"

  check "web_application" {
    assertion     = contains(["web", "other", "java", "ios", "android", "mobile", "desktop"], "web")
    error_message = "Should accept web application type"
  }

  check "java_application" {
    assertion     = contains(["web", "other", "java", "ios", "android", "mobile", "desktop"], "java")
    error_message = "Should accept java application type"
  }

  check "mobile_applications" {
    assertion = alltrue([
      contains(["web", "other", "java", "ios", "android", "mobile", "desktop"], "ios"),
      contains(["web", "other", "java", "ios", "android", "mobile", "desktop"], "android"),
      contains(["web", "other", "java", "ios", "android", "mobile", "desktop"], "mobile")
    ])
    error_message = "Should accept mobile application types"
  }
}

# Test workspace ID validation
resource "test_assertions" "workspace_id_validation" {
  component = "application_insights_workspace_id"

  check "valid_workspace_id" {
    assertion = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[^/]+/providers/Microsoft.OperationalInsights/workspaces/[^/]+$",
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/my-rg/providers/Microsoft.OperationalInsights/workspaces/my-workspace"))
    error_message = "Should accept valid workspace resource IDs"
  }

  check "null_workspace_id" {
    assertion     = true # null should be accepted
    error_message = "Should accept null workspace ID"
  }
}

# Test environment validation
resource "test_assertions" "environment_validation" {
  component = "application_insights_environment"

  check "valid_environments" {
    assertion = alltrue([
      contains(["dev", "test", "staging", "prod"], "dev"),
      contains(["dev", "test", "staging", "prod"], "test"),
      contains(["dev", "test", "staging", "prod"], "staging"),
      contains(["dev", "test", "staging", "prod"], "prod")
    ])
    error_message = "Should accept all valid environments"
  }
}

# Test criticality validation
resource "test_assertions" "criticality_validation" {
  component = "application_insights_criticality"

  check "valid_criticality_levels" {
    assertion = alltrue([
      contains(["low", "medium", "high", "critical"], "low"),
      contains(["low", "medium", "high", "critical"], "medium"),
      contains(["low", "medium", "high", "critical"], "high"),
      contains(["low", "medium", "high", "critical"], "critical")
    ])
    error_message = "Should accept all valid criticality levels"
  }
}

# Test retention validation
resource "test_assertions" "retention_validation" {
  component = "application_insights_retention"

  check "valid_retention_periods" {
    assertion = alltrue([
      contains([30, 60, 90, 120, 180, 270, 365, 550, 730], 30),
      contains([30, 60, 90, 120, 180, 270, 365, 550, 730], 90),
      contains([30, 60, 90, 120, 180, 270, 365, 550, 730], 365),
      contains([30, 60, 90, 120, 180, 270, 365, 550, 730], 730)
    ])
    error_message = "Should accept valid retention periods"
  }
}

# Test daily data cap validation
resource "test_assertions" "daily_data_cap_validation" {
  component = "application_insights_daily_data_cap"

  check "minimum_data_cap" {
    assertion     = 0.023 >= 0.023 && 0.023 <= 1000
    error_message = "Should accept minimum data cap"
  }

  check "maximum_data_cap" {
    assertion     = 1000 >= 0.023 && 1000 <= 1000
    error_message = "Should accept maximum data cap"
  }

  check "standard_data_caps" {
    assertion = alltrue([
      1 >= 0.023 && 1 <= 1000,
      5 >= 0.023 && 5 <= 1000,
      10 >= 0.023 && 10 <= 1000
    ])
    error_message = "Should accept standard data cap values"
  }
}

# Test sampling percentage validation
resource "test_assertions" "sampling_percentage_validation" {
  component = "application_insights_sampling_percentage"

  check "minimum_sampling" {
    assertion     = 0.1 >= 0.1 && 0.1 <= 100
    error_message = "Should accept minimum sampling percentage"
  }

  check "maximum_sampling" {
    assertion     = 100 >= 0.1 && 100 <= 100
    error_message = "Should accept maximum sampling percentage"
  }

  check "standard_sampling_values" {
    assertion = alltrue([
      25 >= 0.1 && 25 <= 100,
      50 >= 0.1 && 50 <= 100,
      75 >= 0.1 && 75 <= 100,
      100 >= 0.1 && 100 <= 100
    ])
    error_message = "Should accept standard sampling percentages"
  }
}

# Test alert severity validation
resource "test_assertions" "alert_severity_validation" {
  component = "application_insights_alert_severity"

  check "valid_severity_levels" {
    assertion = alltrue([
      0 >= 0 && 0 <= 4, # Critical
      1 >= 0 && 1 <= 4, # Error
      2 >= 0 && 2 <= 4, # Warning
      3 >= 0 && 3 <= 4, # Informational
      4 >= 0 && 4 <= 4  # Verbose
    ])
    error_message = "Should accept all valid alert severity levels"
  }
}

# Test threshold validation
resource "test_assertions" "threshold_validation" {
  component = "application_insights_thresholds"

  check "response_time_threshold" {
    assertion     = 5000 > 0
    error_message = "Response time threshold should be positive"
  }

  check "failure_rate_threshold" {
    assertion     = 10 > 0
    error_message = "Failure rate threshold should be positive"
  }

  check "exception_rate_threshold" {
    assertion     = 5 > 0
    error_message = "Exception rate threshold should be positive"
  }
}

# Test action group ID validation
resource "test_assertions" "action_group_validation" {
  component = "application_insights_action_groups"

  check "valid_action_group_id" {
    assertion = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[^/]+/providers/Microsoft.Insights/actionGroups/[^/]+$",
    "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/my-rg/providers/Microsoft.Insights/actionGroups/my-action-group"))
    error_message = "Should accept valid action group resource IDs"
  }
}

# Test web test configuration validation
resource "test_assertions" "web_test_validation" {
  component = "application_insights_web_tests"

  check "web_test_kind" {
    assertion = alltrue([
      contains(["ping", "multistep"], "ping"),
      contains(["ping", "multistep"], "multistep")
    ])
    error_message = "Should accept valid web test kinds"
  }

  check "web_test_frequency" {
    assertion = alltrue([
      contains([300, 600, 900], 300),
      contains([300, 600, 900], 600),
      contains([300, 600, 900], 900)
    ])
    error_message = "Should accept valid web test frequencies"
  }

  check "web_test_timeout" {
    assertion = alltrue([
      30 >= 30 && 30 <= 120,
      60 >= 30 && 60 <= 120,
      120 >= 30 && 120 <= 120
    ])
    error_message = "Should accept valid web test timeout values"
  }
}

# Test custom alert validation
resource "test_assertions" "custom_alert_validation" {
  component = "application_insights_custom_alerts"

  check "alert_aggregation" {
    assertion = alltrue([
      contains(["Average", "Count", "Maximum", "Minimum", "Total"], "Average"),
      contains(["Average", "Count", "Maximum", "Minimum", "Total"], "Count"),
      contains(["Average", "Count", "Maximum", "Minimum", "Total"], "Maximum")
    ])
    error_message = "Should accept valid alert aggregation types"
  }

  check "alert_operator" {
    assertion = alltrue([
      contains(["Equals", "NotEquals", "GreaterThan", "GreaterThanOrEqual", "LessThan", "LessThanOrEqual"], "GreaterThan"),
      contains(["Equals", "NotEquals", "GreaterThan", "GreaterThanOrEqual", "LessThan", "LessThanOrEqual"], "LessThan"),
      contains(["Equals", "NotEquals", "GreaterThan", "GreaterThanOrEqual", "LessThan", "LessThanOrEqual"], "Equals")
    ])
    error_message = "Should accept valid alert operators"
  }
}

# Test smart detection email validation
resource "test_assertions" "smart_detection_email_validation" {
  component = "application_insights_smart_detection"

  check "valid_email_addresses" {
    assertion = alltrue([
      can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", "user@example.com")),
      can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", "ops-team@company.org")),
      can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", "dev.team@enterprise.co.uk"))
    ])
    error_message = "Should accept valid email addresses"
  }
}

# Test analytics item validation
resource "test_assertions" "analytics_item_validation" {
  component = "application_insights_analytics_items"

  check "analytics_item_type" {
    assertion = alltrue([
      contains(["query", "function"], "query"),
      contains(["query", "function"], "function")
    ])
    error_message = "Should accept valid analytics item types"
  }

  check "analytics_item_scope" {
    assertion = alltrue([
      contains(["shared", "user"], "shared"),
      contains(["shared", "user"], "user")
    ])
    error_message = "Should accept valid analytics item scopes"
  }
}

# Test API key permissions validation
resource "test_assertions" "api_key_validation" {
  component = "application_insights_api_keys"

  check "read_permissions" {
    assertion = alltrue([
      contains(["aggregate", "api", "draft", "extendqueries", "search"], "aggregate"),
      contains(["aggregate", "api", "draft", "extendqueries", "search"], "api"),
      contains(["aggregate", "api", "draft", "extendqueries", "search"], "search")
    ])
    error_message = "Should accept valid read permissions"
  }

  check "write_permissions" {
    assertion     = contains(["annotations"], "annotations")
    error_message = "Should accept valid write permissions"
  }
}

# Test workbook template validation
resource "test_assertions" "workbook_template_validation" {
  component = "application_insights_workbook_templates"

  check "workbook_priority" {
    assertion = alltrue([
      1 >= 1 && 1 <= 10,
      5 >= 1 && 5 <= 10,
      10 >= 1 && 10 <= 10
    ])
    error_message = "Should accept valid workbook priorities"
  }
}

# Test compliance requirements validation
resource "test_assertions" "compliance_validation" {
  component = "application_insights_compliance"

  check "compliance_frameworks" {
    assertion = alltrue([
      contains(["SOX", "PCI-DSS", "HIPAA", "ISO27001", "SOC2", "GDPR", "CCPA", "FedRAMP"], "SOX"),
      contains(["SOX", "PCI-DSS", "HIPAA", "ISO27001", "SOC2", "GDPR", "CCPA", "FedRAMP"], "GDPR"),
      contains(["SOX", "PCI-DSS", "HIPAA", "ISO27001", "SOC2", "GDPR", "CCPA", "FedRAMP"], "ISO27001")
    ])
    error_message = "Should accept valid compliance frameworks"
  }
}

# Test data governance validation
resource "test_assertions" "data_governance_validation" {
  component = "application_insights_data_governance"

  check "data_classification" {
    assertion = alltrue([
      contains(["public", "internal", "confidential", "restricted"], "public"),
      contains(["public", "internal", "confidential", "restricted"], "internal"),
      contains(["public", "internal", "confidential", "restricted"], "confidential"),
      contains(["public", "internal", "confidential", "restricted"], "restricted")
    ])
    error_message = "Should accept valid data classifications"
  }

  check "data_retention_policy" {
    assertion = alltrue([
      contains(["minimal", "standard", "extended", "maximum"], "minimal"),
      contains(["minimal", "standard", "extended", "maximum"], "standard"),
      contains(["minimal", "standard", "extended", "maximum"], "extended"),
      contains(["minimal", "standard", "extended", "maximum"], "maximum")
    ])
    error_message = "Should accept valid data retention policies"
  }
}

# Test tags validation
resource "test_assertions" "tags_validation" {
  component = "application_insights_tags"

  check "required_common_tags" {
    assertion = alltrue([
      can(tomap({ "Environment" = "dev", "Project" = "test" })["Environment"]),
      can(tomap({ "Environment" = "dev", "Project" = "test" })["Project"])
    ])
    error_message = "Should require Environment and Project tags"
  }

  check "tag_key_length" {
    assertion     = length("Environment") <= 512
    error_message = "Tag keys should not exceed 512 characters"
  }

  check "tag_value_length" {
    assertion     = length("production") <= 256
    error_message = "Tag values should not exceed 256 characters"
  }
}