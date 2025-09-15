package test

import (
	"database/sql"
	"fmt"
	"testing"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestMySQLDatabaseBasicIntegration(t *testing.T) {
	t.Parallel()

	// Generate unique names
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-mysql-db-basic-%s", uniqueID)
	mysqlServerName := fmt.Sprintf("test-mysql-%s", uniqueID)
	databaseName := fmt.Sprintf("test_db_%s", uniqueID)
	location := "East US"

	// Create resource group and MySQL server for testing
	subscriptionID := azure.GetSubscriptionIDFromEnvironment(t)
	azure.CreateResourceGroup(t, subscriptionID, resourceGroupName, location)

	defer func() {
		// Clean up resource group
		azure.DeleteResourceGroup(t, subscriptionID, resourceGroupName)
	}()

	// First create a MySQL Flexible Server for the database
	serverOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../../mysql-flexible-server/examples/basic",
		Vars: map[string]interface{}{
			"mysql_server_name":    mysqlServerName,
			"resource_group_name":  resourceGroupName,
			"administrator_password": "TestPassword123!",
			"location":             location,
			"mysql_version":        "8.0.21",
			"sku_name":             "GP_Standard_D2ds_v4",
			"storage_size_gb":      100,
		},
	})

	defer terraform.Destroy(t, serverOptions)
	terraform.InitAndApply(t, serverOptions)

	// Now test the database module
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"database_name":       databaseName,
			"resource_group_name": resourceGroupName,
			"mysql_server_name":   mysqlServerName,
			"use_flexible_server": true,
			"charset":             "utf8mb4",
			"collation":          "utf8mb4_unicode_ci",
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	// Apply the Terraform configuration
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	databaseID := terraform.Output(t, terraformOptions, "database_id")
	databaseNameOutput := terraform.Output(t, terraformOptions, "database_name")
	serverNameOutput := terraform.Output(t, terraformOptions, "server_name")
	charsetOutput := terraform.Output(t, terraformOptions, "charset")
	collationOutput := terraform.Output(t, terraformOptions, "collation")

	// Verify outputs
	assert.NotEmpty(t, databaseID, "Database ID should not be empty")
	assert.Equal(t, databaseName, databaseNameOutput, "Database name should match input")
	assert.Equal(t, mysqlServerName, serverNameOutput, "Server name should match")
	assert.Equal(t, "utf8mb4", charsetOutput, "Charset should be utf8mb4")
	assert.Equal(t, "utf8mb4_unicode_ci", collationOutput, "Collation should be utf8mb4_unicode_ci")

	// Get server FQDN for database connection testing
	serverFQDN := terraform.Output(t, serverOptions, "mysql_server_fqdn")

	// Test database connectivity and verify database was created
	testDatabaseExists(t, serverFQDN, "mysqladmin", "TestPassword123!", databaseName)
}

func TestMySQLDatabaseAdvancedIntegration(t *testing.T) {
	t.Parallel()

	// Generate unique names
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-mysql-db-adv-%s", uniqueID)
	mysqlServerName := fmt.Sprintf("test-mysql-adv-%s", uniqueID)
	primaryDatabase := fmt.Sprintf("primary_db_%s", uniqueID)
	location := "East US"

	// Create resource group and MySQL server for testing
	subscriptionID := azure.GetSubscriptionIDFromEnvironment(t)
	azure.CreateResourceGroup(t, subscriptionID, resourceGroupName, location)

	defer func() {
		// Clean up resource group
		azure.DeleteResourceGroup(t, subscriptionID, resourceGroupName)
	}()

	// Create a MySQL Single Server for advanced features
	serverOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../../mysql-server/examples/basic", // Assuming Single Server module exists
		Vars: map[string]interface{}{
			"mysql_server_name":       mysqlServerName,
			"resource_group_name":     resourceGroupName,
			"administrator_password":  "TestPassword123!",
			"location":                location,
			"mysql_version":           "8.0",
			"sku_name":                "GP_Gen5_2",
			"storage_mb":              51200,
		},
	})

	// Skip server creation if Single Server module doesn't exist
	// defer terraform.Destroy(t, serverOptions)
	// terraform.InitAndApply(t, serverOptions)

	// Test the advanced database module configuration
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/advanced",
		Vars: map[string]interface{}{
			"database_name":       primaryDatabase,
			"resource_group_name": resourceGroupName,
			"mysql_server_name":   mysqlServerName,
			"use_flexible_server": false,
			"charset":             "utf8mb4",
			"collation":          "utf8mb4_unicode_ci",
			"additional_databases": []map[string]interface{}{
				{
					"name":      "analytics_db",
					"charset":   "utf8mb4",
					"collation": "utf8mb4_unicode_ci",
				},
				{
					"name":      "logging_db",
					"charset":   "utf8mb4",
					"collation": "utf8mb4_unicode_ci",
				},
			},
			"enable_monitoring":       false, // Disable to avoid Action Group requirement
			"enable_audit_logging":    true,
			"enable_slow_query_log":   true,
			"slow_query_threshold":    2,
		},
		PlanOnly: true, // Only test planning since we don't have a real server
	})

	// Run terraform plan to validate configuration
	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify that advanced resources would be created
	resourceCounts := terraform.GetResourceCount(t, planStruct)
	assert.Greater(t, resourceCounts.Add, 5, "Should plan to create multiple databases and configurations")

	// Verify specific advanced resources are planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.mysql_database_advanced.azurerm_mysql_database.main[0]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.mysql_database_advanced.azurerm_mysql_database.additional[\"analytics_db\"]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.mysql_database_advanced.azurerm_mysql_database.additional[\"logging_db\"]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.mysql_database_advanced.azurerm_mysql_configuration.audit_log[0]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "module.mysql_database_advanced.azurerm_mysql_configuration.slow_query_log[0]")
}

func TestMySQLDatabaseMultipleDatabases(t *testing.T) {
	t.Parallel()

	// Test multiple database creation and configuration
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                "primary_db",
			"resource_group_name": "test-rg",
			"mysql_server_name":   "test-mysql-server",
			"use_flexible_server": true,
			"charset":             "utf8mb4",
			"collation":          "utf8mb4_unicode_ci",
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
				{
					"name":      "reporting_db",
					"charset":   "latin1",
					"collation": "latin1_swedish_ci",
				},
			},
		},
		PlanOnly: true,
	})

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify all databases will be created
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_flexible_database.main[0]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_flexible_database.additional[\"analytics_db\"]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_flexible_database.additional[\"logging_db\"]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_flexible_database.additional[\"reporting_db\"]")

	// Verify charset and collation configurations
	analyticsDB := terraform.PlannedValuesForResource(t, planStruct, "azurerm_mysql_flexible_database.additional[\"analytics_db\"]")
	assert.Equal(t, "utf8mb4", analyticsDB["charset"], "Analytics DB should use utf8mb4")
	assert.Equal(t, "utf8mb4_unicode_ci", analyticsDB["collation"], "Analytics DB should use utf8mb4_unicode_ci")

	loggingDB := terraform.PlannedValuesForResource(t, planStruct, "azurerm_mysql_flexible_database.additional[\"logging_db\"]")
	assert.Equal(t, "utf8", loggingDB["charset"], "Logging DB should use utf8")
	assert.Equal(t, "utf8_general_ci", loggingDB["collation"], "Logging DB should use utf8_general_ci")
}

func TestMySQLDatabaseUserManagement(t *testing.T) {
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
						{
							"type":     "UPDATE",
							"database": "test_db",
						},
					},
				},
				{
					"username": "readonly_user",
					"password": "ReadOnlyPassword456!",
					"privileges": []map[string]interface{}{
						{
							"type":     "SELECT",
							"database": "test_db",
						},
					},
				},
			},
		},
		PlanOnly: true,
	})

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify users will be created
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_user.users[\"app_user\"]")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_mysql_user.users[\"readonly_user\"]")

	// Verify user configurations
	appUser := terraform.PlannedValuesForResource(t, planStruct, "azurerm_mysql_user.users[\"app_user\"]")
	assert.Equal(t, "app_user", appUser["name"], "App user name should match")

	readOnlyUser := terraform.PlannedValuesForResource(t, planStruct, "azurerm_mysql_user.users[\"readonly_user\"]")
	assert.Equal(t, "readonly_user", readOnlyUser["name"], "Read-only user name should match")
}

func TestMySQLDatabaseNamingConvention(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                   "myapp",
			"resource_group_name":    "test-rg",
			"mysql_server_name":      "test-mysql-server",
			"use_naming_convention":  true,
			"environment":            "prod",
			"location_short":         "eus",
		},
		PlanOnly: true,
	})

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify naming convention is applied
	database := terraform.PlannedValuesForResource(t, planStruct, "azurerm_mysql_flexible_database.main[0]")
	expectedName := "myapp-db-prod-eus"
	assert.Equal(t, expectedName, database["name"], "Database name should follow naming convention")
}

// Helper function to test database connectivity and existence
func testDatabaseExists(t *testing.T, host, username, password, database string) {
	// Connection string for Azure MySQL
	dsn := fmt.Sprintf("%s:%s@tcp(%s:3306)/%s?tls=skip-verify", username, password, host, "mysql")

	db, err := sql.Open("mysql", dsn)
	require.NoError(t, err, "Should be able to open MySQL connection")
	defer db.Close()

	// Test the connection
	err = db.Ping()
	require.NoError(t, err, "Should be able to ping MySQL server")

	// Check if database exists
	var count int
	query := "SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = ?"
	err = db.QueryRow(query, database).Scan(&count)
	require.NoError(t, err, "Should be able to query database existence")
	assert.Equal(t, 1, count, "Database should exist")

	t.Logf("Successfully verified database %s exists on server %s", database, host)
}

// Helper function to test database operations
func testDatabaseOperations(t *testing.T, host, username, password, database string) {
	dsn := fmt.Sprintf("%s:%s@tcp(%s:3306)/%s?tls=skip-verify", username, password, host, database)

	db, err := sql.Open("mysql", dsn)
	require.NoError(t, err, "Should be able to open database connection")
	defer db.Close()

	// Create a test table
	_, err = db.Exec(`CREATE TABLE test_table (
		id INT AUTO_INCREMENT PRIMARY KEY,
		name VARCHAR(100) NOT NULL,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	)`)
	require.NoError(t, err, "Should be able to create test table")

	// Insert test data
	result, err := db.Exec("INSERT INTO test_table (name) VALUES (?)", "test_entry")
	require.NoError(t, err, "Should be able to insert data")

	lastInsertID, err := result.LastInsertId()
	require.NoError(t, err, "Should be able to get last insert ID")
	assert.Greater(t, lastInsertID, int64(0), "Last insert ID should be greater than 0")

	// Query test data
	var count int
	err = db.QueryRow("SELECT COUNT(*) FROM test_table WHERE name = ?", "test_entry").Scan(&count)
	require.NoError(t, err, "Should be able to query data")
	assert.Equal(t, 1, count, "Should find one test entry")

	// Test character set and collation
	var charset, collation string
	err = db.QueryRow(`SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME
		FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = ?`, database).Scan(&charset, &collation)
	require.NoError(t, err, "Should be able to query database charset and collation")

	t.Logf("Database charset: %s, collation: %s", charset, collation)

	// Clean up test table
	_, err = db.Exec("DROP TABLE test_table")
	require.NoError(t, err, "Should be able to drop test table")

	t.Logf("Database operations test completed successfully for database: %s", database)
}