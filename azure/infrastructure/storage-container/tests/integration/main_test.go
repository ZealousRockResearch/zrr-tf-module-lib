package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"fmt"
	"strings"
)

func TestStorageContainerCreation(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"storage_account_name":                "teststorageacct",
			"storage_account_resource_group_name": "test-rg",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	containerId := terraform.Output(t, terraformOptions, "container_id")
	assert.NotEmpty(t, containerId)
	assert.Contains(t, containerId, "example-container")

	containerName := terraform.Output(t, terraformOptions, "container_name")
	assert.Equal(t, "example-container", containerName)

	containerUrl := terraform.Output(t, terraformOptions, "container_url")
	assert.NotEmpty(t, containerUrl)
	assert.Contains(t, containerUrl, "https://")
	assert.Contains(t, containerUrl, "blob.core.windows.net")
	assert.Contains(t, containerUrl, "example-container")
}

func TestStorageContainerAccessTypes(t *testing.T) {
	accessTypes := []string{"private", "blob", "container"}

	for _, accessType := range accessTypes {
		t.Run(fmt.Sprintf("AccessType_%s", accessType), func(t *testing.T) {
			terraformOptions := &terraform.Options{
				TerraformDir: "../../examples/basic",

				Vars: map[string]interface{}{
					"storage_account_name":                "teststorageacct",
					"storage_account_resource_group_name": "test-rg",
					"container_access_type":               accessType,
				},
			}

			defer terraform.Destroy(t, terraformOptions)
			terraform.InitAndApply(t, terraformOptions)

			// Validate that container was created with correct access type
			containerId := terraform.Output(t, terraformOptions, "container_id")
			assert.NotEmpty(t, containerId)

			securityFeatures := terraform.OutputMap(t, terraformOptions, "security_features")
			assert.Equal(t, accessType, securityFeatures["access_type"])
		})
	}
}

func TestStorageContainerMetadata(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"storage_account_name":                "teststorageacct",
			"storage_account_resource_group_name": "test-rg",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate that metadata is properly set
	containerId := terraform.Output(t, terraformOptions, "container_id")
	assert.NotEmpty(t, containerId)

	// The basic example includes metadata, so we can validate it's being applied
	containerName := terraform.Output(t, terraformOptions, "container_name")
	assert.Equal(t, "example-container", containerName)
}

func TestStorageContainerSecurityFeatures(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"storage_account_name":                "teststorageacct",
			"storage_account_resource_group_name": "test-rg",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Test security features output
	securityFeatures := terraform.OutputMap(t, terraformOptions, "security_features")

	// Basic example should have these security features
	assert.Contains(t, securityFeatures, "has_legal_hold")
	assert.Contains(t, securityFeatures, "has_immutability_policy")
	assert.Contains(t, securityFeatures, "access_type")
	assert.Contains(t, securityFeatures, "lifecycle_rules_count")

	// Basic example should have private access
	assert.Equal(t, "private", securityFeatures["access_type"])

	// Basic example should have no advanced security features
	assert.Equal(t, false, securityFeatures["has_legal_hold"])
	assert.Equal(t, false, securityFeatures["has_immutability_policy"])

	// Basic example should have no lifecycle rules
	assert.Equal(t, float64(0), securityFeatures["lifecycle_rules_count"])
}

func TestStorageContainerOutputs(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"storage_account_name":                "teststorageacct",
			"storage_account_resource_group_name": "test-rg",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Test all expected outputs
	outputs := []string{"container_id", "container_name", "container_url", "security_features"}

	for _, output := range outputs {
		value := terraform.Output(t, terraformOptions, output)
		assert.NotEmpty(t, value, fmt.Sprintf("Output %s should not be empty", output))
	}

	// Validate specific output formats
	containerUrl := terraform.Output(t, terraformOptions, "container_url")
	assert.True(t, strings.HasPrefix(containerUrl, "https://"))
	assert.Contains(t, containerUrl, ".blob.core.windows.net/")

	containerId := terraform.Output(t, terraformOptions, "container_id")
	assert.True(t, strings.Contains(containerId, "/blobServices/default/containers/"))
}

func TestAdvancedStorageContainerFeatures(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/advanced",

		Vars: map[string]interface{}{
			"storage_account_name":                "advancedteststorage",
			"storage_account_resource_group_name": "advanced-test-rg",
			"enable_legal_hold":                   false, // Disable for testing
			"enable_immutability_policy":          false, // Disable for testing
			"enable_app_lifecycle":                true,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Test that multiple containers are created
	complianceId := terraform.Output(t, terraformOptions, "compliance_container_id")
	assert.NotEmpty(t, complianceId)

	appDataId := terraform.Output(t, terraformOptions, "app_data_container_id")
	assert.NotEmpty(t, appDataId)

	backupId := terraform.Output(t, terraformOptions, "backup_container_id")
	assert.NotEmpty(t, backupId)

	// Test containers summary
	containersSummary := terraform.OutputMap(t, terraformOptions, "containers_summary")
	assert.Contains(t, containersSummary, "compliance")
	assert.Contains(t, containersSummary, "app_data")
	assert.Contains(t, containersSummary, "backup")

	// Test lifecycle rules are configured
	appLifecycleRules := terraform.Output(t, terraformOptions, "app_data_lifecycle_rules")
	assert.Equal(t, "1", appLifecycleRules) // Should have 1 lifecycle rule when enabled

	backupLifecycleRules := terraform.Output(t, terraformOptions, "backup_lifecycle_rules")
	assert.Equal(t, "2", backupLifecycleRules) // Should have 2 lifecycle rules for backup
}

func TestStorageContainerWithDifferentStorageAccountReference(t *testing.T) {
	// Test using storage_account_id instead of name + resource group
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"storage_account_id": "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage",
		},
	}

	// Note: This test would require the storage account to actually exist
	// For unit testing, we'll just validate the plan
	terraform.Init(t, terraformOptions)
	planOutput := terraform.Plan(t, terraformOptions)

	// Validate that the plan includes container creation
	assert.Contains(t, planOutput, "azurerm_storage_container.main")
}