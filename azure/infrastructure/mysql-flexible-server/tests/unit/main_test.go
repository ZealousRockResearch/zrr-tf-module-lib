package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestMySQLFlexibleServerUnit(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"resource_group_name":    "test-rg",
			"mysql_server_name":      "test-mysql-server",
			"administrator_password": "TestPassword123!",
			"location":               "East US",
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

	// Verify specific resources are planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.mysql_server_basic.azurerm_mysql_flexible_server.main")
}

func TestMySQLFlexibleServerAdvancedUnit(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/advanced",
		Vars: map[string]interface{}{
			"resource_group_name":           "test-rg",
			"mysql_server_name":             "test-mysql-advanced",
			"administrator_password":        "TestPassword123!",
			"location":                      "East US",
			"high_availability_mode":        "ZoneRedundant",
			"standby_availability_zone":     "2",
			"availability_zone":             "1",
			"backup_retention_days":         35,
			"geo_redundant_backup_enabled":  true,
			"public_network_access_enabled": false,
			"enable_monitoring":             true,
			"enable_diagnostic_settings":    true,
		},
		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	// Run terraform plan
	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify resources will be created
	resourceCounts := terraform.GetResourceCount(t, planStruct)
	assert.Greater(t, resourceCounts.Add, 5, "Should plan to create multiple resources for advanced config")
	assert.Equal(t, resourceCounts.Change, 0, "Should not plan to change existing resources")
	assert.Equal(t, resourceCounts.Destroy, 0, "Should not plan to destroy existing resources")

	// Verify key advanced resources are planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.mysql_server_advanced.azurerm_mysql_flexible_server.main")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.mysql_server_advanced.azurerm_monitor_action_group.main[0]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.mysql_server_advanced.azurerm_monitor_metric_alert.cpu[0]")
}

func TestMySQLFlexibleServerValidation(t *testing.T) {
	t.Parallel()

	// Test invalid SKU name
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                   "test-mysql",
			"resource_group_name":    "test-rg",
			"administrator_password": "TestPassword123!",
			"sku_name":               "InvalidSKU",
		},
		PlanOnly: true,
	})

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	assert.Error(t, err, "Should fail with invalid SKU name")

	// Test invalid MySQL version
	terraformOptions2 := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                   "test-mysql",
			"resource_group_name":    "test-rg",
			"administrator_password": "TestPassword123!",
			"mysql_version":          "7.0",
		},
		PlanOnly: true,
	})

	_, err2 := terraform.InitAndPlanE(t, terraformOptions2)
	assert.Error(t, err2, "Should fail with invalid MySQL version")

	// Test invalid backup retention
	terraformOptions3 := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                   "test-mysql",
			"resource_group_name":    "test-rg",
			"administrator_password": "TestPassword123!",
			"backup_retention_days":  50,
		},
		PlanOnly: true,
	})

	_, err3 := terraform.InitAndPlanE(t, terraformOptions3)
	assert.Error(t, err3, "Should fail with backup retention > 35 days")
}

func TestMySQLFlexibleServerHighAvailability(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                       "test-mysql-ha",
			"resource_group_name":        "test-rg",
			"administrator_password":     "TestPassword123!",
			"high_availability_mode":     "ZoneRedundant",
			"availability_zone":          "1",
			"standby_availability_zone":  "2",
		},
		PlanOnly: true,
	})

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify high availability configuration
	mysql := terraform.PlannedValuesForResource(t, planStruct, "azurerm_mysql_flexible_server.main")
	assert.Equal(t, "ZoneRedundant", mysql["high_availability_mode"], "High availability mode should be ZoneRedundant")
	assert.Equal(t, "1", mysql["availability_zone"], "Primary zone should be 1")
	assert.Equal(t, "2", mysql["standby_availability_zone"], "Standby zone should be 2")
}

func TestMySQLFlexibleServerBackupConfiguration(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                          "test-mysql-backup",
			"resource_group_name":           "test-rg",
			"administrator_password":        "TestPassword123!",
			"backup_retention_days":         30,
			"geo_redundant_backup_enabled":  true,
		},
		PlanOnly: true,
	})

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify backup configuration
	mysql := terraform.PlannedValuesForResource(t, planStruct, "azurerm_mysql_flexible_server.main")
	assert.Equal(t, float64(30), mysql["backup_retention_days"], "Backup retention should be 30 days")
	assert.Equal(t, true, mysql["geo_redundant_backup_enabled"], "Geo-redundant backup should be enabled")
}

func TestMySQLFlexibleServerDatabases(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                   "test-mysql-db",
			"resource_group_name":    "test-rg",
			"administrator_password": "TestPassword123!",
			"databases": []map[string]interface{}{
				{
					"name":      "app_db",
					"charset":   "utf8mb4",
					"collation": "utf8mb4_unicode_ci",
				},
				{
					"name":      "analytics_db",
					"charset":   "utf8mb4",
					"collation": "utf8mb4_unicode_ci",
				},
			},
		},
		PlanOnly: true,
	})

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify databases will be created
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_flexible_database.databases[\"app_db\"]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_flexible_database.databases[\"analytics_db\"]")
}

func TestMySQLFlexibleServerMonitoring(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                        "test-mysql-monitoring",
			"resource_group_name":         "test-rg",
			"administrator_password":      "TestPassword123!",
			"enable_monitoring":           true,
			"alert_email_addresses":       []string{"admin@test.com", "dba@test.com"},
			"cpu_alert_threshold":         85,
			"memory_alert_threshold":      90,
			"connection_alert_threshold":  150,
		},
		PlanOnly: true,
	})

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify monitoring resources will be created
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_monitor_action_group.main[0]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_monitor_metric_alert.cpu[0]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_monitor_metric_alert.memory[0]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_monitor_metric_alert.connections[0]")
}