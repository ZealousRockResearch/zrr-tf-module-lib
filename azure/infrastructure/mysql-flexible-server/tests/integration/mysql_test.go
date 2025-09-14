package test

import (
	"crypto/tls"
	"database/sql"
	"fmt"
	"net"
	"testing"
	"time"

	"github.com/go-sql-driver/mysql"
	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestMySQLFlexibleServerBasicIntegration(t *testing.T) {
	t.Parallel()

	// Generate unique names
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-mysql-basic-%s", uniqueID)
	mysqlServerName := fmt.Sprintf("test-mysql-%s", uniqueID)
	location := "East US"

	// Create resource group
	subscriptionID := azure.GetSubscriptionIDFromEnvironment(t)
	azure.CreateResourceGroup(t, subscriptionID, resourceGroupName, location)

	defer func() {
		// Clean up resource group
		azure.DeleteResourceGroup(t, subscriptionID, resourceGroupName)
	}()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"resource_group_name":    resourceGroupName,
			"mysql_server_name":      mysqlServerName,
			"administrator_password": "TestPassword123!",
			"location":               location,
			"mysql_version":          "8.0.21",
			"sku_name":               "GP_Standard_D2ds_v4",
			"storage_size_gb":        100,
			"backup_retention_days":  7,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	// Apply the Terraform configuration
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	mysqlServerID := terraform.Output(t, terraformOptions, "mysql_server_id")
	mysqlServerFQDN := terraform.Output(t, terraformOptions, "mysql_server_fqdn")
	mysqlServerNameOutput := terraform.Output(t, terraformOptions, "mysql_server_name")

	// Verify outputs are not empty
	assert.NotEmpty(t, mysqlServerID, "MySQL server ID should not be empty")
	assert.NotEmpty(t, mysqlServerFQDN, "MySQL server FQDN should not be empty")
	assert.Equal(t, mysqlServerName, mysqlServerNameOutput, "MySQL server name should match input")

	// Verify the MySQL server exists in Azure
	server := azure.GetMySQLServer(t, subscriptionID, resourceGroupName, mysqlServerName)
	assert.Equal(t, mysqlServerName, *server.Name, "Server name should match")
	assert.Equal(t, "Ready", string(server.UserVisibleState), "Server should be in Ready state")

	// Test basic connectivity (with retry logic)
	testDatabaseConnectivity(t, mysqlServerFQDN, "mysqladmin", "TestPassword123!", "mysql", 5)
}

func TestMySQLFlexibleServerAdvancedIntegration(t *testing.T) {
	t.Parallel()

	// Generate unique names
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-mysql-advanced-%s", uniqueID)
	mysqlServerName := fmt.Sprintf("test-mysql-adv-%s", uniqueID)
	location := "East US"

	// Create resource group
	subscriptionID := azure.GetSubscriptionIDFromEnvironment(t)
	azure.CreateResourceGroup(t, subscriptionID, resourceGroupName, location)

	defer func() {
		// Clean up resource group
		azure.DeleteResourceGroup(t, subscriptionID, resourceGroupName)
	}()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/advanced",
		Vars: map[string]interface{}{
			"resource_group_name":           resourceGroupName,
			"mysql_server_name":             mysqlServerName,
			"administrator_password":        "TestPassword123!",
			"location":                      location,
			"sku_name":                      "MO_Standard_E4ds_v4",
			"mysql_version":                 "8.0.21",
			"storage_size_gb":               1000,
			"storage_iops":                  3000,
			"availability_zone":             "1",
			"high_availability_mode":        "ZoneRedundant",
			"standby_availability_zone":     "2",
			"backup_retention_days":         35,
			"geo_redundant_backup_enabled":  true,
			"public_network_access_enabled": true, // Enable for testing
			"enable_monitoring":             true,
			"enable_diagnostic_settings":    false, // Disable to avoid workspace requirement
			"enable_private_endpoint":       false, // Disable for testing
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
	})

	defer terraform.Destroy(t, terraformOptions)

	// Apply the Terraform configuration
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	mysqlServerID := terraform.Output(t, terraformOptions, "mysql_server_id")
	mysqlServerFQDN := terraform.Output(t, terraformOptions, "mysql_server_fqdn")
	haEnabled := terraform.Output(t, terraformOptions, "high_availability_enabled")
	haMode := terraform.Output(t, terraformOptions, "high_availability_mode")
	standbyZone := terraform.Output(t, terraformOptions, "standby_availability_zone")
	actionGroupID := terraform.Output(t, terraformOptions, "action_group_id")

	// Verify outputs
	assert.NotEmpty(t, mysqlServerID, "MySQL server ID should not be empty")
	assert.NotEmpty(t, mysqlServerFQDN, "MySQL server FQDN should not be empty")
	assert.Equal(t, "true", haEnabled, "High availability should be enabled")
	assert.Equal(t, "ZoneRedundant", haMode, "HA mode should be ZoneRedundant")
	assert.Equal(t, "2", standbyZone, "Standby zone should be 2")
	assert.NotEmpty(t, actionGroupID, "Action group ID should not be empty")

	// Verify the MySQL server exists with correct configuration
	server := azure.GetMySQLServer(t, subscriptionID, resourceGroupName, mysqlServerName)
	assert.Equal(t, mysqlServerName, *server.Name, "Server name should match")
	assert.Equal(t, "Ready", string(server.UserVisibleState), "Server should be in Ready state")

	// Test database connectivity and verify databases were created
	testDatabaseConnectivity(t, mysqlServerFQDN, "mysqladmin", "TestPassword123!", "app_db", 5)
	testDatabaseConnectivity(t, mysqlServerFQDN, "mysqladmin", "TestPassword123!", "analytics_db", 5)

	// Test database operations
	testDatabaseOperations(t, mysqlServerFQDN, "mysqladmin", "TestPassword123!", "app_db")
}

func TestMySQLFlexibleServerHighAvailabilityFailover(t *testing.T) {
	t.Parallel()

	// This test verifies HA configuration but doesn't trigger actual failover
	// as that would require complex setup and long test duration

	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-mysql-ha-%s", uniqueID)
	mysqlServerName := fmt.Sprintf("test-mysql-ha-%s", uniqueID)
	location := "East US"

	subscriptionID := azure.GetSubscriptionIDFromEnvironment(t)
	azure.CreateResourceGroup(t, subscriptionID, resourceGroupName, location)

	defer func() {
		azure.DeleteResourceGroup(t, subscriptionID, resourceGroupName)
	}()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                       mysqlServerName,
			"resource_group_name":        resourceGroupName,
			"administrator_password":     "TestPassword123!",
			"location":                   location,
			"high_availability_mode":     "ZoneRedundant",
			"availability_zone":          "1",
			"standby_availability_zone":  "2",
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Verify HA configuration
	haEnabled := terraform.Output(t, terraformOptions, "high_availability_enabled")
	haMode := terraform.Output(t, terraformOptions, "high_availability_mode")
	primaryZone := terraform.Output(t, terraformOptions, "availability_zone")
	standbyZone := terraform.Output(t, terraformOptions, "standby_availability_zone")

	assert.Equal(t, "true", haEnabled, "High availability should be enabled")
	assert.Equal(t, "ZoneRedundant", haMode, "HA mode should be ZoneRedundant")
	assert.Equal(t, "1", primaryZone, "Primary zone should be 1")
	assert.Equal(t, "2", standbyZone, "Standby zone should be 2")

	// Verify server is accessible
	mysqlServerFQDN := terraform.Output(t, terraformOptions, "mysql_server_fqdn")
	testDatabaseConnectivity(t, mysqlServerFQDN, "mysqladmin", "TestPassword123!", "mysql", 3)
}

func TestMySQLFlexibleServerBackupRestore(t *testing.T) {
	t.Parallel()

	// This test verifies backup configuration
	// Point-in-time restore testing would require a separate test setup

	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-mysql-backup-%s", uniqueID)
	mysqlServerName := fmt.Sprintf("test-mysql-backup-%s", uniqueID)
	location := "East US"

	subscriptionID := azure.GetSubscriptionIDFromEnvironment(t)
	azure.CreateResourceGroup(t, subscriptionID, resourceGroupName, location)

	defer func() {
		azure.DeleteResourceGroup(t, subscriptionID, resourceGroupName)
	}()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                          mysqlServerName,
			"resource_group_name":           resourceGroupName,
			"administrator_password":        "TestPassword123!",
			"location":                      location,
			"backup_retention_days":         30,
			"geo_redundant_backup_enabled":  true,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Verify server was created and is accessible
	mysqlServerFQDN := terraform.Output(t, terraformOptions, "mysql_server_fqdn")
	testDatabaseConnectivity(t, mysqlServerFQDN, "mysqladmin", "TestPassword123!", "mysql", 3)

	// Verify backup configuration through Azure API
	server := azure.GetMySQLServer(t, subscriptionID, resourceGroupName, mysqlServerName)
	assert.Equal(t, int32(30), *server.Backup.BackupRetentionDays, "Backup retention should be 30 days")
	assert.Equal(t, true, *server.Backup.GeoRedundantBackup, "Geo-redundant backup should be enabled")
}

// Helper function to test database connectivity with retry logic
func testDatabaseConnectivity(t *testing.T, host, username, password, database string, maxRetries int) {
	var db *sql.DB
	var err error

	// Configure MySQL driver for SSL
	mysql.RegisterTLSConfig("azure", &tls.Config{
		InsecureSkipVerify: true,
	})

	// Connection string for Azure MySQL
	dsn := fmt.Sprintf("%s:%s@tcp(%s:3306)/%s?tls=azure&allowNativePasswords=true",
		username, password, host, database)

	// Retry connection with exponential backoff
	for i := 0; i < maxRetries; i++ {
		db, err = sql.Open("mysql", dsn)
		if err == nil {
			// Test the connection
			err = db.Ping()
			if err == nil {
				break
			}
		}

		if i < maxRetries-1 {
			waitTime := time.Duration(i+1) * 30 * time.Second
			t.Logf("Connection attempt %d failed, retrying in %v. Error: %v", i+1, waitTime, err)
			time.Sleep(waitTime)
		}
	}

	require.NoError(t, err, "Should be able to connect to MySQL server")
	defer db.Close()

	// Test a simple query
	var version string
	err = db.QueryRow("SELECT VERSION()").Scan(&version)
	require.NoError(t, err, "Should be able to query MySQL version")
	assert.Contains(t, version, "8.0", "MySQL version should be 8.0.x")

	t.Logf("Successfully connected to MySQL server %s, version: %s", host, version)
}

// Helper function to test basic database operations
func testDatabaseOperations(t *testing.T, host, username, password, database string) {
	mysql.RegisterTLSConfig("azure", &tls.Config{
		InsecureSkipVerify: true,
	})

	dsn := fmt.Sprintf("%s:%s@tcp(%s:3306)/%s?tls=azure&allowNativePasswords=true",
		username, password, host, database)

	db, err := sql.Open("mysql", dsn)
	require.NoError(t, err, "Should be able to open database connection")
	defer db.Close()

	// Create a test table
	_, err = db.Exec(`CREATE TABLE IF NOT EXISTS test_table (
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

	// Clean up test table
	_, err = db.Exec("DROP TABLE test_table")
	require.NoError(t, err, "Should be able to drop test table")

	t.Logf("Database operations test completed successfully for database: %s", database)
}

// Helper function to test network connectivity
func testNetworkConnectivity(t *testing.T, host string, port int, timeout time.Duration) {
	address := fmt.Sprintf("%s:%d", host, port)
	conn, err := net.DialTimeout("tcp", address, timeout)
	require.NoError(t, err, "Should be able to connect to MySQL port")
	defer conn.Close()

	t.Logf("Network connectivity test passed for %s", address)
}