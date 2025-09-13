package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestResourceGroupCreation(t *testing.T) {
	t.Parallel()

	// Generate a random suffix for unique resource names
	randomSuffix := strings.ToLower(random.UniqueId())
	resourceGroupName := fmt.Sprintf("test-rg-%s", randomSuffix)
	location := "eastus"

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",
		
		Vars: map[string]interface{}{
			"location": location,
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
				"TestID":      randomSuffix,
			},
		},
		
		// Retry configuration for handling transient errors
		RetryableTerraformErrors: map[string]string{
			".*": "Transient error occurred",
		},
		MaxRetries: 3,
	}

	// Clean up resources after test
	defer terraform.Destroy(t, terraformOptions)

	// Initialize and apply Terraform
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	resourceGroupID := terraform.Output(t, terraformOptions, "resource_group_id")
	assert.NotEmpty(t, resourceGroupID)
	
	resourceGroupName = terraform.Output(t, terraformOptions, "resource_group_name")
	assert.Contains(t, resourceGroupName, "example-resource-group")
	
	resourceGroupLocation := terraform.Output(t, terraformOptions, "resource_group_location")
	assert.Equal(t, location, resourceGroupLocation)
	
	// Validate tags
	resourceGroupTags := terraform.OutputMap(t, terraformOptions, "resource_group_tags")
	assert.Equal(t, "test", resourceGroupTags["Environment"])
	assert.Equal(t, "terratest", resourceGroupTags["Project"])
	assert.Equal(t, "Terraform", resourceGroupTags["ManagedBy"])
	assert.Equal(t, "infrastructure", resourceGroupTags["Layer"])
}

func TestResourceGroupWithLock(t *testing.T) {
	t.Parallel()

	randomSuffix := strings.ToLower(random.UniqueId())
	location := "eastus"

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		
		Vars: map[string]interface{}{
			"name":     fmt.Sprintf("test-locked-%s", randomSuffix),
			"location": location,
			"enable_resource_lock": true,
			"lock_level": "CanNotDelete",
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify resource lock is created
	lockID := terraform.Output(t, terraformOptions, "lock_id")
	assert.NotEmpty(t, lockID)
	
	lockLevel := terraform.Output(t, terraformOptions, "lock_level")
	assert.Equal(t, "CanNotDelete", lockLevel)
	
	isLocked := terraform.Output(t, terraformOptions, "is_locked")
	assert.Equal(t, "true", isLocked)
}

func TestResourceGroupWithBudget(t *testing.T) {
	t.Parallel()

	randomSuffix := strings.ToLower(random.UniqueId())
	location := "eastus"
	budgetAmount := 1000.0

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		
		Vars: map[string]interface{}{
			"name":     fmt.Sprintf("test-budget-%s", randomSuffix),
			"location": location,
			"enable_budget_alert": true,
			"budget_amount": budgetAmount,
			"budget_threshold_percentage": 80,
			"budget_contact_emails": []string{"test@example.com"},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify budget is created
	budgetID := terraform.Output(t, terraformOptions, "budget_id")
	assert.NotEmpty(t, budgetID)
	
	outputBudgetAmount := terraform.Output(t, terraformOptions, "budget_amount")
	assert.Equal(t, fmt.Sprintf("%v", budgetAmount), outputBudgetAmount)
	
	hasBudget := terraform.Output(t, terraformOptions, "has_budget_alert")
	assert.Equal(t, "true", hasBudget)
}

func TestResourceGroupNamingConvention(t *testing.T) {
	t.Parallel()

	randomSuffix := strings.ToLower(random.UniqueId())
	baseName := fmt.Sprintf("test-%s", randomSuffix)
	location := "eastus"
	environment := "dev"
	locationShort := "eus"

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		
		Vars: map[string]interface{}{
			"name":                  baseName,
			"location":              location,
			"environment":           environment,
			"location_short":        locationShort,
			"use_naming_convention": true,
			"common_tags": map[string]string{
				"Environment": environment,
				"Project":     "terratest",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify naming convention is applied
	resourceGroupName := terraform.Output(t, terraformOptions, "name")
	expectedName := fmt.Sprintf("rg-%s-%s-%s", environment, baseName, locationShort)
	assert.Equal(t, expectedName, resourceGroupName)
}

func TestResourceGroupValidation(t *testing.T) {
	t.Parallel()

	// Test invalid location
	t.Run("InvalidLocation", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../../",
			
			Vars: map[string]interface{}{
				"name":     "test-validation",
				"location": "invalid-location",
				"common_tags": map[string]string{
					"Environment": "test",
					"Project":     "terratest",
				},
			},
		}

		_, err := terraform.InitAndPlanE(t, terraformOptions)
		require.Error(t, err)
		assert.Contains(t, err.Error(), "Location must be a valid Azure region")
	})

	// Test invalid name
	t.Run("InvalidName", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../../",
			
			Vars: map[string]interface{}{
				"name":     "invalid@name!",
				"location": "eastus",
				"common_tags": map[string]string{
					"Environment": "test",
					"Project":     "terratest",
				},
			},
		}

		_, err := terraform.InitAndPlanE(t, terraformOptions)
		require.Error(t, err)
		assert.Contains(t, err.Error(), "Name must be 1-90 characters")
	})

	// Test missing required tags
	t.Run("MissingRequiredTags", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../../",
			
			Vars: map[string]interface{}{
				"name":     "test-validation",
				"location": "eastus",
				"common_tags": map[string]string{
					"Owner": "test",
				},
			},
		}

		_, err := terraform.InitAndPlanE(t, terraformOptions)
		require.Error(t, err)
		assert.Contains(t, err.Error(), "Common tags must include")
	})
}

func TestAdvancedExample(t *testing.T) {
	t.Parallel()

	randomSuffix := strings.ToLower(random.UniqueId())

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/advanced",
		
		Vars: map[string]interface{}{
			"budget_contact_emails": []string{"test@example.com"},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     fmt.Sprintf("terratest-%s", randomSuffix),
				"TestRun":     "true",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate production resource group
	prodResourceGroup := terraform.OutputMap(t, terraformOptions, "production_resource_group")
	assert.NotEmpty(t, prodResourceGroup["id"])
	assert.Contains(t, prodResourceGroup["name"], "critical-production-app")
	assert.Equal(t, "eastus", prodResourceGroup["location"])
	assert.Equal(t, "true", prodResourceGroup["locked"])
	assert.Equal(t, "true", prodResourceGroup["budget"])

	// Validate DR resource group
	drResourceGroup := terraform.OutputMap(t, terraformOptions, "dr_resource_group")
	assert.NotEmpty(t, drResourceGroup["id"])
	assert.Contains(t, drResourceGroup["name"], "critical-production-app-dr")
	assert.Equal(t, "westus2", drResourceGroup["location"])
	assert.Equal(t, "true", drResourceGroup["locked"])
	assert.Equal(t, "true", drResourceGroup["budget"])

	// Validate subscription info
	subscriptionInfo := terraform.OutputMap(t, terraformOptions, "subscription_info")
	assert.NotEmpty(t, subscriptionInfo["subscription_id"])
	assert.NotEmpty(t, subscriptionInfo["tenant_id"])
}

// Helper function to check if resource group exists
func resourceGroupExists(t *testing.T, subscriptionID string, resourceGroupName string) bool {
	exists, err := azure.ResourceGroupExistsE(resourceGroupName, subscriptionID)
	require.NoError(t, err)
	return exists
}