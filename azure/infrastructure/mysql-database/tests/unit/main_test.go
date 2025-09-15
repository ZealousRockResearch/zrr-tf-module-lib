package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestMySQLDatabaseUnit(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"database_name":            "test_db",
			"resource_group_name":      "test-rg",
			"mysql_server_name":        "test-mysql-server",
			"use_flexible_server":      true,
			"charset":                  "utf8mb4",
			"collation":               "utf8mb4_unicode_ci",
		},
		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	// Run terraform plan
	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify resources will be created
	resourceCounts := terraform.GetResourceCount(t, planStruct)
	assert.Greater(t, resourceCounts.Add, 0, "Should plan to create resources")
	assert.Equal(t, resourceCounts.Change, 0, "Should not plan to change existing resources")
	assert.Equal(t, resourceCounts.Destroy, 0, "Should not plan to destroy existing resources")

	// Verify specific resources are planned for Flexible Server
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.mysql_database_basic.azurerm_mysql_flexible_database.main[0]")
}

func TestMySQLDatabaseSingleServerUnit(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"database_name":       "test_db",
			"resource_group_name": "test-rg",
			"mysql_server_name":   "test-mysql-server",
			"use_flexible_server": false,
			"charset":             "utf8mb4",
			"collation":          "utf8mb4_unicode_ci",
		},
		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	// Run terraform plan
	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify resources will be created
	resourceCounts := terraform.GetResourceCount(t, planStruct)
	assert.Greater(t, resourceCounts.Add, 0, "Should plan to create resources")

	// Verify specific resources are planned for Single Server
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.mysql_database_basic.azurerm_mysql_database.main[0]")
}

func TestMySQLDatabaseAdvancedUnit(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/advanced",
		Vars: map[string]interface{}{
			"database_name":            "primary_db",
			"resource_group_name":      "production-rg",
			"mysql_server_name":        "production-mysql-server",
			"use_flexible_server":      false,
			"enable_monitoring":        true,
			"enable_audit_logging":     true,
			"enable_slow_query_log":    true,
		},
		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	// Run terraform plan
	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify resources will be created
	resourceCounts := terraform.GetResourceCount(t, planStruct)
	assert.Greater(t, resourceCounts.Add, 3, "Should plan to create multiple resources for advanced config")

	// Verify key advanced resources are planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.mysql_database_advanced.azurerm_mysql_database.main[0]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.mysql_database_advanced.azurerm_monitor_metric_alert.database_connections[0]")
}

func TestMySQLDatabaseValidation(t *testing.T) {
	t.Parallel()

	// Test invalid database name
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                     "invalid-name!",
			"resource_group_name":      "test-rg",
			"mysql_server_name":        "test-mysql-server",
		},
		PlanOnly: true,
	})

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	assert.Error(t, err, "Should fail with invalid database name")

	// Test invalid character set
	terraformOptions2 := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                "test_db",
			"resource_group_name": "test-rg",
			"mysql_server_name":   "test-mysql-server",
			"charset":             "invalid_charset",
		},
		PlanOnly: true,
	})

	_, err2 := terraform.InitAndPlanE(t, terraformOptions2)
	assert.Error(t, err2, "Should fail with invalid character set")

	// Test invalid alert threshold
	terraformOptions3 := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                        "test_db",
			"resource_group_name":         "test-rg",
			"mysql_server_name":           "test-mysql-server",
			"connection_alert_threshold":  2000,
		},
		PlanOnly: true,
	})

	_, err3 := terraform.InitAndPlanE(t, terraformOptions3)
	assert.Error(t, err3, "Should fail with connection threshold > 1000")
}

func TestMySQLDatabaseCharacterSets(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		charset   string
		collation string
		valid     bool
	}{
		{"utf8mb4", "utf8mb4_unicode_ci", true},
		{"utf8mb4", "utf8mb4_general_ci", true},
		{"utf8mb4", "utf8mb4_bin", true},
		{"utf8", "utf8_general_ci", true},
		{"latin1", "latin1_swedish_ci", true},
		{"ascii", "ascii_general_ci", true},
		{"invalid_charset", "utf8mb4_unicode_ci", false},
	}

	for _, tc := range testCases {
		t.Run(tc.charset+"_"+tc.collation, func(t *testing.T) {
			terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
				TerraformDir: "../../",
				Vars: map[string]interface{}{
					"name":                "test_db",
					"resource_group_name": "test-rg",
					"mysql_server_name":   "test-mysql-server",
					"charset":             tc.charset,
					"collation":          tc.collation,
				},
				PlanOnly: true,
			})

			_, err := terraform.InitAndPlanE(t, terraformOptions)
			if tc.valid {
				assert.NoError(t, err, "Should succeed with valid charset/collation")
			} else {
				assert.Error(t, err, "Should fail with invalid charset/collation")
			}
		})
	}
}

func TestMySQLDatabaseAdditionalDatabases(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                "primary_db",
			"resource_group_name": "test-rg",
			"mysql_server_name":   "test-mysql-server",
			"use_flexible_server": true,
			"additional_databases": []map[string]interface{}{
				{
					"name":      "analytics_db",
					"charset":   "utf8mb4",
					"collation": "utf8mb4_unicode_ci",
				},
				{
					"name":      "logging_db",
					"charset":   "utf8",
					"collation": "utf8_general_ci",
				},
			},
		},
		PlanOnly: true,
	})

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify additional databases will be created
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_flexible_database.additional[\"analytics_db\"]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_flexible_database.additional[\"logging_db\"]")
}

func TestMySQLDatabaseUsers(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                "test_db",
			"resource_group_name": "test-rg",
			"mysql_server_name":   "test-mysql-server",
			"use_flexible_server": false, // Users only supported on Single Server
			"database_users": []map[string]interface{}{
				{
					"username": "app_user",
					"password": "SecurePassword123!",
					"privileges": []map[string]interface{}{
						{
							"type":     "SELECT",
							"database": "test_db",
						},
						{
							"type":     "INSERT",
							"database": "test_db",
						},
					},
				},
			},
		},
		PlanOnly: true,
	})

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify database user will be created
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_user.users[\"app_user\"]")
}

func TestMySQLDatabaseMonitoring(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                         "test_db",
			"resource_group_name":          "test-rg",
			"mysql_server_name":            "test-mysql-server",
			"enable_monitoring":            true,
			"action_group_id":              "/subscriptions/test/resourceGroups/test/providers/microsoft.insights/actionGroups/test",
			"connection_alert_threshold":   100,
			"storage_alert_threshold":      80,
		},
		PlanOnly: true,
	})

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify monitoring resources will be created
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_monitor_metric_alert.database_connections[0]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_monitor_metric_alert.database_storage[0]")
}

func TestMySQLDatabasePerformanceConfig(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                "test_db",
			"resource_group_name": "test-rg",
			"mysql_server_name":   "test-mysql-server",
			"use_flexible_server": false, // Performance configs only for Single Server
			"performance_configurations": map[string]interface{}{
				"innodb_buffer_pool_size": "75",
				"max_connections":         "200",
				"slow_query_log":          "ON",
				"long_query_time":         "2",
			},
		},
		PlanOnly: true,
	})

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify performance configurations will be applied
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_configuration.performance_configs[\"innodb_buffer_pool_size\"]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_configuration.performance_configs[\"max_connections\"]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_configuration.performance_configs[\"slow_query_log\"]")
}

func TestMySQLDatabaseAuditLogging(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                  "test_db",
			"resource_group_name":   "test-rg",
			"mysql_server_name":     "test-mysql-server",
			"use_flexible_server":   false, // Audit logging only for Single Server
			"enable_audit_logging":  true,
			"audit_log_events":      "CONNECTION,DML,DDL",
			"enable_slow_query_log": true,
			"slow_query_threshold":  2,
		},
		PlanOnly: true,
	})

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify audit logging configurations will be applied
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_configuration.audit_log[0]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_configuration.audit_log_events[0]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_configuration.slow_query_log[0]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_configuration.long_query_time[0]")
}