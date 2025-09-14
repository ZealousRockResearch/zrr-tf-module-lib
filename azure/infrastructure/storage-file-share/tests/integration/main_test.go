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

// TestStorageFileShareCreation tests basic file share creation
func TestStorageFileShareCreation(t *testing.T) {
	t.Parallel()

	// Generate random names to avoid conflicts
	uniqueID := random.UniqueId()
	expectedName := fmt.Sprintf("test-share-%s", strings.ToLower(uniqueID))
	location := "East US"

	// Expected tags
	expectedTags := map[string]string{
		"Environment": "test",
		"Project":     "terratest",
		"Owner":       "automation",
		"ManagedBy":   "Terraform",
		"Module":      "zrr-tf-module-lib/azure/infrastructure/storage-file-share",
		"Layer":       "infrastructure",
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"file_share_name":      expectedName,
			"storage_account_name": "teststorageaccount", // This needs to be a real storage account for integration tests
			"resource_group_name":  "test-rg",            // This needs to be a real resource group for integration tests
			"location":             location,
			"quota_gb":             100,
			"enable_backup":        false, // Disable backup for simpler testing
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
				"Owner":       "automation",
			},
			"file_share_tags": map[string]string{
				"Purpose": "testing",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	fileShareID := terraform.Output(t, terraformOptions, "file_share_id")
	assert.NotEmpty(t, fileShareID, "File share ID should not be empty")

	fileShareName := terraform.Output(t, terraformOptions, "file_share_name")
	assert.Equal(t, expectedName, fileShareName, "File share name should match expected")

	fileShareURL := terraform.Output(t, terraformOptions, "file_share_url")
	assert.Contains(t, fileShareURL, expectedName, "File share URL should contain the name")
	assert.Contains(t, fileShareURL, "file.core.windows.net", "File share URL should be a valid Azure Files URL")

	// Validate tags output
	actualTags := terraform.OutputMap(t, terraformOptions, "tags")

	// Check required tags are present
	for key, expectedValue := range expectedTags {
		if key == "Owner" {
			// Owner comes from common_tags
			continue
		}
		actualValue, exists := actualTags[key]
		assert.True(t, exists, fmt.Sprintf("Tag %s should exist", key))
		if exists {
			assert.Equal(t, expectedValue, actualValue, fmt.Sprintf("Tag %s should have value %s", key, expectedValue))
		}
	}

	// Check custom tag
	assert.Equal(t, "testing", actualTags["Purpose"])
}

// TestStorageFileShareWithBackup tests file share creation with backup enabled
func TestStorageFileShareWithBackup(t *testing.T) {
	t.Parallel()

	// Generate random names to avoid conflicts
	uniqueID := random.UniqueId()
	expectedName := fmt.Sprintf("test-backup-%s", strings.ToLower(uniqueID))
	location := "East US"

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"file_share_name":      expectedName,
			"storage_account_name": "teststorageaccount", // This needs to be a real storage account
			"resource_group_name":  "test-rg",            // This needs to be a real resource group
			"location":             location,
			"quota_gb":             50,
			"enable_backup":        true,
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest-backup",
				"Owner":       "automation",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate file share outputs
	fileShareID := terraform.Output(t, terraformOptions, "file_share_id")
	assert.NotEmpty(t, fileShareID, "File share ID should not be empty")

	// Validate backup outputs
	backupVaultID := terraform.Output(t, terraformOptions, "backup_vault_id")
	assert.NotEmpty(t, backupVaultID, "Backup vault ID should not be empty when backup is enabled")

	// Extract subscription ID and resource group from file share ID for Azure API calls
	subscriptionID := azure.GetSubscriptionIDFromResourceID(t, fileShareID)
	resourceGroupName := azure.GetResourceGroupNameFromResourceID(t, fileShareID)

	// Verify the backup vault exists in Azure
	backupVault := azure.GetRecoveryServicesVault(t, subscriptionID, resourceGroupName, terraform.Output(t, terraformOptions, "backup_vault_name"))
	assert.NotNil(t, backupVault, "Backup vault should exist in Azure")
	assert.Equal(t, location, *backupVault.Location, "Backup vault should be in the correct location")
}

// TestStorageFileShareWithDirectories tests file share with custom directories
func TestStorageFileShareWithDirectories(t *testing.T) {
	t.Parallel()

	// Generate random names to avoid conflicts
	uniqueID := random.UniqueId()
	expectedName := fmt.Sprintf("test-dirs-%s", strings.ToLower(uniqueID))

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                 expectedName,
			"storage_account_name": "teststorageaccount", // This needs to be a real storage account
			"resource_group_name":  "test-rg",            // This needs to be a real resource group
			"location":             "East US",
			"quota_gb":             100,
			"enable_backup":        false,
			"directories": []map[string]interface{}{
				{
					"name": "documents",
					"metadata": map[string]string{
						"purpose": "document-storage",
					},
				},
				{
					"name": "backups",
					"metadata": map[string]string{
						"purpose": "backup-storage",
					},
				},
			},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest-dirs",
				"Owner":       "automation",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate directories output
	directories := terraform.OutputMap(t, terraformOptions, "directories")
	assert.Len(t, directories, 2, "Should create exactly 2 directories")

	// Check that both directories exist in the output
	assert.Contains(t, directories, "documents", "Should contain documents directory")
	assert.Contains(t, directories, "backups", "Should contain backups directory")
}

// TestStorageFileShareValidation tests input validation
func TestStorageFileShareValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                 "invalid@name!",
			"storage_account_name": "teststorageaccount",
			"resource_group_name":  "test-rg",
			"location":             "East US",
		},
	}

	// This should fail due to invalid name
	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "validation failed", "Should fail validation for invalid file share name")
}

// TestStorageFileShareQuotaValidation tests quota validation
func TestStorageFileShareQuotaValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                 "test-quota",
			"storage_account_name": "teststorageaccount",
			"resource_group_name":  "test-rg",
			"location":             "East US",
			"quota_gb":             0, // Invalid quota
		},
	}

	// This should fail due to invalid quota
	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "validation failed", "Should fail validation for invalid quota")
}

// TestStorageFileShareAccessTierValidation tests access tier validation
func TestStorageFileShareAccessTierValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                 "test-tier",
			"storage_account_name": "teststorageaccount",
			"resource_group_name":  "test-rg",
			"location":             "East US",
			"access_tier":          "InvalidTier", // Invalid access tier
		},
	}

	// This should fail due to invalid access tier
	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "validation failed", "Should fail validation for invalid access tier")
}

// TestStorageFileShareEmailValidation tests email address validation
func TestStorageFileShareEmailValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                   "test-email",
			"storage_account_name":   "teststorageaccount",
			"resource_group_name":    "test-rg",
			"location":               "East US",
			"enable_monitoring":      true,
			"alert_email_addresses": []string{"invalid-email", "admin@company.com"}, // One invalid email
		},
	}

	// This should fail due to invalid email address
	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "validation failed", "Should fail validation for invalid email address")
}

// TestStorageFileShareTagsValidation tests required tags validation
func TestStorageFileShareTagsValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                 "test-tags",
			"storage_account_name": "teststorageaccount",
			"resource_group_name":  "test-rg",
			"location":             "East US",
			"common_tags": map[string]string{
				"ManagedBy": "Terraform", // Missing required Environment and Project tags
			},
		},
	}

	// This should fail due to missing required tags
	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "validation failed", "Should fail validation for missing required tags")
}

// Helper function to generate random string
func generateRandomString(length int) string {
	const charset = "abcdefghijklmnopqrstuvwxyz0123456789"
	return random.UniqueId()[:length]
}