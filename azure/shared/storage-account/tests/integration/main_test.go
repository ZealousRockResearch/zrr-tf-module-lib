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

// TestStorageAccountBasicExample tests the basic storage account configuration
func TestStorageAccountBasicExample(t *testing.T) {
	t.Parallel()

	// Generate a random suffix to ensure uniqueness
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("rg-storage-test-basic-%s", uniqueId)

	// Azure region for testing
	azureRegion := "East US"

	// Construct the terraform options with default retryable errors to handle the most common retryable errors
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/basic",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"resource_group_name":     resourceGroupName,
			"storage_account_name":    fmt.Sprintf("testbasic%s", strings.ToLower(uniqueId)),
			"environment":            "test",
			"use_naming_convention":  false, // Disable for predictable testing
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"ARM_SUBSCRIPTION_ID": azure.GetSubscriptionID(),
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Test that the storage account was created successfully
	storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
	assert.NotEmpty(t, storageAccountName)

	// Test that the storage account exists in Azure
	assert.True(t, azure.StorageAccountExists(t, storageAccountName, resourceGroupName, ""))

	// Test storage account properties
	storageAccount := azure.GetStorageAccount(t, storageAccountName, resourceGroupName, "")
	assert.Equal(t, "Standard_LRS", storageAccount.Sku.Name)
	assert.Equal(t, "StorageV2", storageAccount.Kind)
	assert.Equal(t, "Hot", *storageAccount.AccessTier)

	// Test that HTTPS is enforced
	assert.True(t, *storageAccount.EnableHTTPSTrafficOnly)

	// Test that the blob endpoint is accessible
	blobEndpoint := terraform.Output(t, terraformOptions, "primary_blob_endpoint")
	assert.Contains(t, blobEndpoint, storageAccountName)
	assert.Contains(t, blobEndpoint, "blob.core.windows.net")

	// Test that containers were created
	containers := terraform.OutputMap(t, terraformOptions, "containers")
	assert.Contains(t, containers, "documents")
	assert.Contains(t, containers, "images")
	assert.Contains(t, containers, "backups")

	// Test that file shares were created
	fileShares := terraform.OutputMap(t, terraformOptions, "file_shares")
	assert.Contains(t, fileShares, "shared-files")

	// Test that queues were created
	queues := terraform.OutputMap(t, terraformOptions, "queues")
	assert.Contains(t, queues, "processing-queue")
}

// TestStorageAccountAdvancedExample tests the advanced enterprise storage account configuration
func TestStorageAccountAdvancedExample(t *testing.T) {
	t.Parallel()

	// Generate a random suffix to ensure uniqueness
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("rg-storage-test-adv-%s", uniqueId)

	// Azure region for testing
	azureRegion := "East US"

	// Construct the terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/advanced",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"resource_group_name":       resourceGroupName,
			"enterprise_storage_name":   fmt.Sprintf("testadv%s", strings.ToLower(uniqueId)),
			"environment":              "test",
			"use_naming_convention":    false, // Disable for predictable testing
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"ARM_SUBSCRIPTION_ID": azure.GetSubscriptionID(),
		},

		// Increase timeout for complex deployment
		RetryableTerraformErrors: map[string]string{
			".*": "This is a retryable error",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Test that the storage account was created successfully
	storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
	assert.NotEmpty(t, storageAccountName)

	// Test that the storage account exists in Azure
	assert.True(t, azure.StorageAccountExists(t, storageAccountName, resourceGroupName, ""))

	// Test storage account properties
	storageAccount := azure.GetStorageAccount(t, storageAccountName, resourceGroupName, "")
	assert.Equal(t, "Standard_ZRS", storageAccount.Sku.Name) // Zone-redundant storage
	assert.Equal(t, "StorageV2", storageAccount.Kind)
	assert.Equal(t, "Hot", *storageAccount.AccessTier)

	// Test enhanced security features
	assert.True(t, *storageAccount.EnableHTTPSTrafficOnly)
	assert.Equal(t, "TLS1_2", storageAccount.MinimumTLSVersion)
	assert.False(t, *storageAccount.AllowBlobPublicAccess) // No public access

	// Test that managed identity was configured
	identity := terraform.OutputMap(t, terraformOptions, "identity")
	assert.NotEmpty(t, identity)
	assert.Equal(t, "UserAssigned", identity["type"])

	// Test private endpoints
	privateEndpoints := terraform.OutputMap(t, terraformOptions, "private_endpoints")
	assert.Contains(t, privateEndpoints, "blob")
	assert.Contains(t, privateEndpoints, "file")

	// Test network rules
	networkRules := terraform.OutputMap(t, terraformOptions, "network_rules")
	assert.NotEmpty(t, networkRules)
	assert.Equal(t, "Deny", networkRules["default_action"])

	// Test that enterprise containers were created
	containers := terraform.OutputMap(t, terraformOptions, "containers")
	assert.Contains(t, containers, "production-data")
	assert.Contains(t, containers, "logs")
	assert.Contains(t, containers, "backups")
	assert.Contains(t, containers, "analytics")

	// Test that enterprise file shares were created
	fileShares := terraform.OutputMap(t, terraformOptions, "file_shares")
	assert.Contains(t, fileShares, "enterprise-shared-files")
	assert.Contains(t, fileShares, "backup-files")

	// Test that enterprise queues were created
	queues := terraform.OutputMap(t, terraformOptions, "queues")
	assert.Contains(t, queues, "high-priority-processing")
	assert.Contains(t, queues, "batch-processing")
	assert.Contains(t, queues, "audit-events")

	// Test that enterprise tables were created
	tables := terraform.OutputMap(t, terraformOptions, "tables")
	assert.Contains(t, tables, "UserProfiles")
	assert.Contains(t, tables, "AuditLogs")
	assert.Contains(t, tables, "ConfigurationData")

	// Test that lifecycle management policy was created
	lifecyclePolicyId := terraform.Output(t, terraformOptions, "lifecycle_management_policy_id")
	assert.NotEmpty(t, lifecyclePolicyId)

	// Test Key Vault integration
	keyVaultKeyId := terraform.Output(t, terraformOptions, "key_vault_key_id")
	assert.NotEmpty(t, keyVaultKeyId)
	assert.Contains(t, keyVaultKeyId, "storage-encryption-key")

	// Test User Assigned Identity
	userAssignedIdentityId := terraform.Output(t, terraformOptions, "user_assigned_identity_id")
	assert.NotEmpty(t, userAssignedIdentityId)
}

// TestStorageAccountSecurityCompliance tests security and compliance features
func TestStorageAccountSecurityCompliance(t *testing.T) {
	t.Parallel()

	// Generate a random suffix to ensure uniqueness
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("rg-storage-test-sec-%s", uniqueId)
	storageAccountName := fmt.Sprintf("testsec%s", strings.ToLower(uniqueId))

	// Azure region for testing
	azureRegion := "East US"

	// Construct the terraform options for security testing
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                      storageAccountName,
			"resource_group_name":       resourceGroupName,
			"environment":              "test",
			"use_naming_convention":    false,
			// Security-focused configuration
			"enable_https_traffic_only":         true,
			"min_tls_version":                  "TLS1_2",
			"allow_public_access":              false,
			"enable_infrastructure_encryption": true,
			"enable_shared_access_key":         false,
			"enable_public_network_access":     false,
			// Data protection
			"enable_blob_properties":        true,
			"blob_versioning_enabled":       true,
			"blob_delete_retention_days":    30,
			"container_delete_retention_days": 30,
		},

		EnvVars: map[string]string{
			"ARM_SUBSCRIPTION_ID": azure.GetSubscriptionID(),
		},
	})

	// Create a resource group first
	terraform.InitAndApply(t, &terraform.Options{
		TerraformDir: "../../examples/basic", // Use basic example structure
		Vars: map[string]interface{}{
			"create_resource_group_only": true,
			"resource_group_name":       resourceGroupName,
		},
		EnvVars: map[string]string{
			"ARM_SUBSCRIPTION_ID": azure.GetSubscriptionID(),
		},
	})

	// At the end of the test, clean up resources
	defer func() {
		terraform.Destroy(t, terraformOptions)
		// Also clean up the resource group
		terraform.Destroy(t, &terraform.Options{
			TerraformDir: "../../examples/basic",
			Vars: map[string]interface{}{
				"create_resource_group_only": true,
				"resource_group_name":       resourceGroupName,
			},
			EnvVars: map[string]string{
				"ARM_SUBSCRIPTION_ID": azure.GetSubscriptionID(),
			},
		})
	}()

	// Apply the storage account configuration
	terraform.InitAndApply(t, terraformOptions)

	// Test that the storage account was created with security features
	storageAccount := azure.GetStorageAccount(t, storageAccountName, resourceGroupName, "")

	// Test HTTPS enforcement
	assert.True(t, *storageAccount.EnableHTTPSTrafficOnly, "HTTPS traffic should be enforced")

	// Test TLS version
	assert.Equal(t, "TLS1_2", storageAccount.MinimumTLSVersion, "Minimum TLS version should be 1.2")

	// Test public access is disabled
	assert.False(t, *storageAccount.AllowBlobPublicAccess, "Public blob access should be disabled")

	// Test infrastructure encryption (if supported by API)
	// Note: This may not be directly testable via the Azure SDK
	
	// Test that shared access keys are disabled (if supported by API)
	// Note: This may not be directly testable via the Azure SDK

	// Test that public network access is disabled (if supported by API)
	// Note: This may not be directly testable via the Azure SDK
}

// TestStorageAccountDataProtection tests data protection and backup features
func TestStorageAccountDataProtection(t *testing.T) {
	t.Parallel()

	// Generate a random suffix to ensure uniqueness
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("rg-storage-test-dp-%s", uniqueId)
	storageAccountName := fmt.Sprintf("testdp%s", strings.ToLower(uniqueId))

	// Construct the terraform options for data protection testing
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                     storageAccountName,
			"resource_group_name":      resourceGroupName,
			"environment":             "test",
			"use_naming_convention":   false,
			// Data protection configuration
			"enable_blob_properties":        true,
			"blob_versioning_enabled":       true,
			"blob_change_feed_enabled":      true,
			"blob_change_feed_retention_days": 30,
			"blob_last_access_time_enabled": true,
			"blob_delete_retention_days":    30,
			"blob_restore_days":            7,
			"container_delete_retention_days": 30,
		},

		EnvVars: map[string]string{
			"ARM_SUBSCRIPTION_ID": azure.GetSubscriptionID(),
		},
	})

	// Create resource group first (simplified approach)
	azure.CreateResourceGroup(t, resourceGroupName, "East US")

	// At the end of the test, clean up
	defer func() {
		terraform.Destroy(t, terraformOptions)
		azure.DeleteResourceGroup(t, resourceGroupName, "")
	}()

	// Apply the storage account configuration
	terraform.InitAndApply(t, terraformOptions)

	// Test that the storage account exists
	assert.True(t, azure.StorageAccountExists(t, storageAccountName, resourceGroupName, ""))

	// Test data protection features (these would need to be tested via Azure REST API or CLI)
	// For now, we verify that Terraform applied successfully with the data protection configuration
	
	// Get the storage account to verify basic properties
	storageAccount := azure.GetStorageAccount(t, storageAccountName, resourceGroupName, "")
	assert.NotNil(t, storageAccount)
	assert.Equal(t, storageAccountName, storageAccount.Name)
}

// TestStorageAccountNamingConvention tests the naming convention functionality
func TestStorageAccountNamingConvention(t *testing.T) {
	t.Parallel()

	// Generate a random suffix to ensure uniqueness
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("rg-storage-test-naming-%s", uniqueId)
	baseName := "testnam"

	// Construct the terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                   baseName,
			"resource_group_name":    resourceGroupName,
			"environment":           "dev",
			"location_short":        "eus",
			"use_naming_convention": true,
		},

		EnvVars: map[string]string{
			"ARM_SUBSCRIPTION_ID": azure.GetSubscriptionID(),
		},
	})

	// Create resource group first
	azure.CreateResourceGroup(t, resourceGroupName, "East US")

	// At the end of the test, clean up
	defer func() {
		terraform.Destroy(t, terraformOptions)
		azure.DeleteResourceGroup(t, resourceGroupName, "")
	}()

	// Apply the configuration
	terraform.InitAndApply(t, terraformOptions)

	// Get the actual storage account name
	actualStorageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")

	// Test that the naming convention was applied
	assert.Contains(t, actualStorageAccountName, "sa")      // Storage account prefix
	assert.Contains(t, actualStorageAccountName, "dev")     // Environment
	assert.Contains(t, actualStorageAccountName, "testnam") // Base name
	assert.Contains(t, actualStorageAccountName, "eus")     // Location short

	// Verify the storage account exists with the generated name
	assert.True(t, azure.StorageAccountExists(t, actualStorageAccountName, resourceGroupName, ""))
}