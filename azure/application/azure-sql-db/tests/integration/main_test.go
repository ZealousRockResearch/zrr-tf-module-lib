package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestAzureSqlDatabaseCreation tests the basic creation of an Azure SQL Database
func TestAzureSqlDatabaseCreation(t *testing.T) {
	t.Parallel()

	// Generate random suffix for unique resource naming
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-azure-sql-db-%s", uniqueID)
	sqlServerName := fmt.Sprintf("test-server-%s", uniqueID)
	databaseName := fmt.Sprintf("test-database-%s", uniqueID)
	location := "East US"

	// Ensure cleanup
	defer func() {
		// Clean up resources
		subscriptionID := azure.GetAccountSubscription(t)
		azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)
	}()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"sql_server_name":     sqlServerName,
			"resource_group_name": resourceGroupName,
			"location":           location,
			"sku_name":           "GP_S_Gen5_1",
			"max_size_gb":        2,

			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
				"Owner":       "automation",
			},
		},

		// Retry up to 3 times, with 30 seconds between retries
		MaxRetries:         3,
		TimeBetweenRetries: 30 * time.Second,
	}

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	databaseID := terraform.Output(t, terraformOptions, "database_id")
	assert.NotEmpty(t, databaseID)
	assert.Contains(t, databaseID, databaseName)

	databaseNameOutput := terraform.Output(t, terraformOptions, "database_name")
	assert.Equal(t, databaseName, databaseNameOutput)

	skuNameOutput := terraform.Output(t, terraformOptions, "sku_name")
	assert.Equal(t, "GP_S_Gen5_1", skuNameOutput)

	maxSizeOutput := terraform.Output(t, terraformOptions, "max_size_gb")
	assert.Equal(t, "2", maxSizeOutput)

	// Verify the database exists in Azure
	subscriptionID := azure.GetAccountSubscription(t)
	database := azure.GetSQLDatabase(t, subscriptionID, resourceGroupName, sqlServerName, databaseName)

	assert.Equal(t, databaseName, *database.Name)
	assert.Equal(t, "GP_S_Gen5_1", string(*database.Sku.Name))
}

// TestAzureSqlDatabaseAdvancedFeatures tests advanced database features
func TestAzureSqlDatabaseAdvancedFeatures(t *testing.T) {
	t.Parallel()

	// Generate random suffix for unique resource naming
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-azure-sql-db-adv-%s", uniqueID)
	sqlServerName := fmt.Sprintf("test-adv-server-%s", uniqueID)
	databaseName := fmt.Sprintf("test-adv-database-%s", uniqueID)
	location := "East US"

	// Ensure cleanup
	defer func() {
		// Clean up resources
		subscriptionID := azure.GetAccountSubscription(t)
		azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)
	}()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/advanced",

		Vars: map[string]interface{}{
			"database_name":       databaseName,
			"sql_server_name":     sqlServerName,
			"resource_group_name": resourceGroupName,
			"location":           location,

			// Performance configuration
			"sku_name":           "GP_Gen5_2",
			"max_size_gb":        100,
			"zone_redundant":     false, // Keep false for test cost optimization
			"read_scale":         false, // Keep false for test cost optimization

			// Security settings
			"enable_threat_detection": true,
			"enable_auditing":        true,
			"transparent_data_encryption_enabled": true,

			// Backup settings
			"short_term_retention_days": 7,
			"geo_backup_enabled":       true,

			// Advanced example settings
			"create_audit_storage":      true,
			"create_log_analytics":     true,
			"enable_diagnostic_settings": true,
			"audit_storage_account_name": fmt.Sprintf("sqlaudit%s", strings.ToLower(uniqueID[:10])),

			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest-advanced",
				"Owner":       "automation",
			},
		},

		// Retry up to 3 times, with 30 seconds between retries
		MaxRetries:         3,
		TimeBetweenRetries: 30 * time.Second,
	}

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Validate database outputs
	databaseID := terraform.Output(t, terraformOptions, "database_id")
	assert.NotEmpty(t, databaseID)
	assert.Contains(t, databaseID, databaseName)

	databaseNameOutput := terraform.Output(t, terraformOptions, "database_name")
	assert.Equal(t, databaseName, databaseNameOutput)

	// Validate security configuration
	securitySummary := terraform.OutputMap(t, terraformOptions, "security_summary")
	assert.Equal(t, "true", securitySummary["transparent_data_encryption"])
	assert.Equal(t, "true", securitySummary["threat_detection"])
	assert.Equal(t, "true", securitySummary["auditing"])

	// Validate performance configuration
	performanceSummary := terraform.OutputMap(t, terraformOptions, "performance_summary")
	assert.Equal(t, "GP_Gen5_2", performanceSummary["sku_name"])
	assert.Equal(t, "100", performanceSummary["max_size_gb"])

	// Validate storage account creation
	auditStorageAccountName := terraform.Output(t, terraformOptions, "audit_storage_account_name")
	assert.NotEmpty(t, auditStorageAccountName)

	// Validate Log Analytics workspace creation
	logAnalyticsWorkspaceName := terraform.Output(t, terraformOptions, "log_analytics_workspace_name")
	assert.NotEmpty(t, logAnalyticsWorkspaceName)
	assert.Contains(t, logAnalyticsWorkspaceName, databaseName)

	// Validate diagnostic setting creation
	diagnosticSettingID := terraform.Output(t, terraformOptions, "diagnostic_setting_id")
	assert.NotEmpty(t, diagnosticSettingID)

	// Verify the database exists in Azure with correct configuration
	subscriptionID := azure.GetAccountSubscription(t)
	database := azure.GetSQLDatabase(t, subscriptionID, resourceGroupName, sqlServerName, databaseName)

	assert.Equal(t, databaseName, *database.Name)
	assert.Equal(t, "GP_Gen5_2", string(*database.Sku.Name))

	// Verify storage account exists
	storageAccount := azure.GetStorageAccount(t, subscriptionID, resourceGroupName, auditStorageAccountName)
	assert.Equal(t, auditStorageAccountName, *storageAccount.Name)
}

// TestAzureSqlDatabaseBackupConfiguration tests backup and retention settings
func TestAzureSqlDatabaseBackupConfiguration(t *testing.T) {
	t.Parallel()

	// Generate random suffix for unique resource naming
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-azure-sql-db-backup-%s", uniqueID)
	sqlServerName := fmt.Sprintf("test-backup-server-%s", uniqueID)
	databaseName := fmt.Sprintf("test-backup-database-%s", uniqueID)
	location := "East US"

	// Ensure cleanup
	defer func() {
		// Clean up resources
		subscriptionID := azure.GetAccountSubscription(t)
		azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)
	}()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"sql_server_name":     sqlServerName,
			"resource_group_name": resourceGroupName,
			"location":           location,

			// Backup configuration testing
			"short_term_retention_days": 14,
			"geo_backup_enabled":       true,
			"sku_name":                "GP_S_Gen5_1",
			"max_size_gb":             10,

			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest-backup",
				"Owner":       "automation",
			},
		},

		// Retry up to 3 times, with 30 seconds between retries
		MaxRetries:         3,
		TimeBetweenRetries: 30 * time.Second,
	}

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Validate backup configuration outputs
	shortTermRetention := terraform.Output(t, terraformOptions, "short_term_retention_days")
	assert.Equal(t, "14", shortTermRetention)

	geoBackupEnabled := terraform.Output(t, terraformOptions, "geo_backup_enabled")
	assert.Equal(t, "true", geoBackupEnabled)

	// Verify the database exists with correct backup configuration
	subscriptionID := azure.GetAccountSubscription(t)
	database := azure.GetSQLDatabase(t, subscriptionID, resourceGroupName, sqlServerName, databaseName)

	assert.Equal(t, databaseName, *database.Name)
	// Note: More detailed backup configuration validation would require
	// additional Azure SDK calls or CLI commands
}

// TestAzureSqlDatabaseSecurityFeatures tests security-specific features
func TestAzureSqlDatabaseSecurityFeatures(t *testing.T) {
	t.Parallel()

	// Generate random suffix for unique resource naming
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-azure-sql-db-security-%s", uniqueID)
	sqlServerName := fmt.Sprintf("test-security-server-%s", uniqueID)
	databaseName := fmt.Sprintf("test-security-database-%s", uniqueID)
	location := "East US"

	// Ensure cleanup
	defer func() {
		// Clean up resources
		subscriptionID := azure.GetAccountSubscription(t)
		azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)
	}()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"sql_server_name":     sqlServerName,
			"resource_group_name": resourceGroupName,
			"location":           location,

			// Security configuration testing
			"enable_threat_detection": true,
			"enable_auditing":        true,
			"sku_name":              "GP_S_Gen5_1",
			"max_size_gb":           5,

			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest-security",
				"Owner":       "automation",
			},
		},

		// Retry up to 3 times, with 30 seconds between retries
		MaxRetries:         3,
		TimeBetweenRetries: 30 * time.Second,
	}

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Validate security configuration outputs
	threatDetectionEnabled := terraform.Output(t, terraformOptions, "threat_detection_enabled")
	assert.Equal(t, "true", threatDetectionEnabled)

	auditingEnabled := terraform.Output(t, terraformOptions, "auditing_enabled")
	assert.Equal(t, "true", auditingEnabled)

	tdeEnabled := terraform.Output(t, terraformOptions, "transparent_data_encryption_enabled")
	assert.Equal(t, "true", tdeEnabled)

	// Verify the database exists
	subscriptionID := azure.GetAccountSubscription(t)
	database := azure.GetSQLDatabase(t, subscriptionID, resourceGroupName, sqlServerName, databaseName)

	assert.Equal(t, databaseName, *database.Name)
}

// Benchmark test for module performance
func BenchmarkAzureSqlDatabaseModule(b *testing.B) {
	for i := 0; i < b.N; i++ {
		uniqueID := random.UniqueId()
		resourceGroupName := fmt.Sprintf("bench-azure-sql-db-%s", uniqueID)

		terraformOptions := &terraform.Options{
			TerraformDir: "../../examples/basic",
			Vars: map[string]interface{}{
				"sql_server_name":     fmt.Sprintf("bench-server-%s", uniqueID),
				"resource_group_name": resourceGroupName,
				"sku_name":           "GP_S_Gen5_1",
				"max_size_gb":        1,
			},
		}

		// Measure terraform plan time
		terraform.InitAndPlan(b, terraformOptions)

		// Clean up
		subscriptionID := azure.GetAccountSubscription(b)
		azure.DeleteResourceGroup(b, resourceGroupName, subscriptionID)
	}
}