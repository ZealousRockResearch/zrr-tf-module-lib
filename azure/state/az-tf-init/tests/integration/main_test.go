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

// TestAzTfInitBasicExample tests the basic Terraform state initialization configuration
func TestAzTfInitBasicExample(t *testing.T) {
	t.Parallel()

	// Generate a random suffix to ensure uniqueness
	uniqueId := random.UniqueId()
	projectName := fmt.Sprintf("test%s", strings.ToLower(uniqueId)[0:6])

	// Azure region for testing
	azureRegion := "East US"

	// Construct the terraform options with default retryable errors
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/basic",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"project_name":    projectName,
			"environment":     "test",
			"location":        azureRegion,
			"location_short":  "eus",
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
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	containerName := terraform.Output(t, terraformOptions, "container_name")

	assert.NotEmpty(t, storageAccountName)
	assert.NotEmpty(t, resourceGroupName)
	assert.Equal(t, "tfstate", containerName)

	// Test that the storage account exists in Azure
	assert.True(t, azure.StorageAccountExists(t, storageAccountName, resourceGroupName, ""))

	// Test storage account properties
	storageAccount := azure.GetStorageAccount(t, storageAccountName, resourceGroupName, "")
	assert.Equal(t, "Standard_LRS", storageAccount.Sku.Name)
	assert.True(t, *storageAccount.EnableHTTPSTrafficOnly)

	// Test backend configuration
	backendConfig := terraform.OutputMap(t, terraformOptions, "terraform_backend_config")
	assert.Equal(t, resourceGroupName, backendConfig["resource_group_name"])
	assert.Equal(t, storageAccountName, backendConfig["storage_account_name"])
	assert.Equal(t, containerName, backendConfig["container_name"])
	assert.Equal(t, "terraform.tfstate", backendConfig["key"])
}

// TestAzTfInitAdvancedExample tests the advanced enterprise configuration
func TestAzTfInitAdvancedExample(t *testing.T) {
	t.Parallel()

	// Generate a random suffix to ensure uniqueness
	uniqueId := random.UniqueId()
	projectName := fmt.Sprintf("test%s", strings.ToLower(uniqueId)[0:6])

	// Azure region for testing
	azureRegion := "East US"

	// Construct the terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/advanced",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"project_name":                projectName,
			"environment":                 "test",
			"location":                    azureRegion,
			"location_short":              "eus",
			"create_automation_identity":  false, // Disable to simplify test
			"allowed_ip_ranges":          []string{}, // Empty for test
			"terraform_contributors":      []string{},
			"terraform_readers":          []string{},
			"terraform_admins":           []string{},
			"terraform_users":            []string{},
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

	// Test that the infrastructure was created successfully
	storageDetails := terraform.OutputMap(t, terraformOptions, "storage_account_details")
	keyVaultDetails := terraform.OutputMap(t, terraformOptions, "key_vault_details")
	monitoringDetails := terraform.OutputMap(t, terraformOptions, "monitoring_details")

	assert.NotEmpty(t, storageDetails["name"])
	assert.NotEmpty(t, keyVaultDetails["name"])
	assert.NotEmpty(t, monitoringDetails["log_analytics_workspace_name"])

	// Test that the storage account exists with correct configuration
	storageAccountName := storageDetails["name"]
	resourceGroupName := storageDetails["resource_group_name"]

	assert.True(t, azure.StorageAccountExists(t, storageAccountName, resourceGroupName, ""))

	// Test storage account properties for enterprise configuration
	storageAccount := azure.GetStorageAccount(t, storageAccountName, resourceGroupName, "")
	assert.Equal(t, "Standard_GZRS", storageAccount.Sku.Name) // Geo-zone redundant
	assert.True(t, *storageAccount.EnableHTTPSTrafficOnly)

	// Test security summary
	securitySummary := terraform.OutputMap(t, terraformOptions, "security_summary")
	storageSecurityMap := securitySummary["storage_security"].(map[string]interface{})
	keyVaultSecurityMap := securitySummary["key_vault_security"].(map[string]interface{})

	assert.Equal(t, true, storageSecurityMap["shared_access_keys_disabled"])
	assert.Equal(t, true, storageSecurityMap["public_access_disabled"])
	assert.Equal(t, true, storageSecurityMap["network_restrictions_enabled"])
	assert.Equal(t, true, storageSecurityMap["blob_versioning_enabled"])
	assert.Equal(t, float64(90), storageSecurityMap["soft_delete_retention_days"])

	assert.Equal(t, "premium", keyVaultSecurityMap["sku"])
	assert.Equal(t, true, keyVaultSecurityMap["rbac_enabled"])
	assert.Equal(t, true, keyVaultSecurityMap["purge_protection"])
}

// TestAzTfInitBasicConfiguration tests basic module configuration without examples
func TestAzTfInitBasicConfiguration(t *testing.T) {
	t.Parallel()

	// Generate a random suffix to ensure uniqueness
	uniqueId := random.UniqueId()
	projectName := fmt.Sprintf("test%s", strings.ToLower(uniqueId)[0:6])

	// Create a temporary resource group for testing
	resourceGroupName := fmt.Sprintf("rg-test-%s", projectName)
	azure.CreateResourceGroup(t, resourceGroupName, "East US")

	// At the end of the test, clean up
	defer func() {
		azure.DeleteResourceGroup(t, resourceGroupName, "")
	}()

	// Construct the terraform options for direct module testing
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"project_name":           projectName,
			"environment":            "test",
			"location":               "East US",
			"location_short":         "eus",
			"use_naming_convention":  false,
			"resource_group_name":    resourceGroupName,
			"storage_account_name":   fmt.Sprintf("sa%s", projectName),
			"enable_key_vault":       false,
			"enable_monitoring":      false,
		},

		EnvVars: map[string]string{
			"ARM_SUBSCRIPTION_ID": azure.GetSubscriptionID(),
		},
	})

	// Apply the configuration
	terraform.InitAndApply(t, terraformOptions)

	// Clean up
	defer terraform.Destroy(t, terraformOptions)

	// Test outputs
	storageAccountId := terraform.Output(t, terraformOptions, "storage_account_id")
	storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
	containerName := terraform.Output(t, terraformOptions, "container_name")

	assert.NotEmpty(t, storageAccountId)
	assert.Equal(t, fmt.Sprintf("sa%s", projectName), storageAccountName)
	assert.Equal(t, "tfstate", containerName)
}

// TestAzTfInitSecurityConfiguration tests security features
func TestAzTfInitSecurityConfiguration(t *testing.T) {
	t.Parallel()

	// Generate a random suffix to ensure uniqueness
	uniqueId := random.UniqueId()
	projectName := fmt.Sprintf("sec%s", strings.ToLower(uniqueId)[0:6])

	// Construct the terraform options for security testing
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"project_name":                         projectName,
			"environment":                          "test",
			"location":                             "East US",
			"enable_shared_access_key":             false,
			"enable_blob_versioning":               true,
			"blob_soft_delete_retention_days":      30,
			"container_soft_delete_retention_days": 30,
			"enable_key_vault":                     false,
			"enable_monitoring":                    false,
		},

		EnvVars: map[string]string{
			"ARM_SUBSCRIPTION_ID": azure.GetSubscriptionID(),
		},
	})

	// Apply the configuration
	terraform.InitAndApply(t, terraformOptions)

	// Clean up
	defer terraform.Destroy(t, terraformOptions)

	// Test that security features are properly configured
	configSummary := terraform.OutputMap(t, terraformOptions, "configuration_summary")

	assert.Equal(t, false, configSummary["public_access_enabled"])
	assert.Equal(t, true, configSummary["blob_versioning_enabled"])
	assert.Equal(t, true, configSummary["state_locking_enabled"])
}

// TestAzTfInitNamingConvention tests the naming convention functionality
func TestAzTfInitNamingConvention(t *testing.T) {
	t.Parallel()

	// Generate a random suffix to ensure uniqueness
	uniqueId := random.UniqueId()
	projectName := fmt.Sprintf("test%s", strings.ToLower(uniqueId)[0:6])

	// Construct the terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"project_name":          projectName,
			"environment":           "dev",
			"location":              "East US",
			"location_short":        "eus",
			"use_naming_convention": true,
			"enable_key_vault":      false,
			"enable_monitoring":     false,
		},

		EnvVars: map[string]string{
			"ARM_SUBSCRIPTION_ID": azure.GetSubscriptionID(),
		},
	})

	// Apply the configuration
	terraform.InitAndApply(t, terraformOptions)

	// Clean up
	defer terraform.Destroy(t, terraformOptions)

	// Get the actual resource names
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")

	// Test that the naming convention was applied
	expectedRgPrefix := fmt.Sprintf("rg-%s-dev-tfstate-eus", projectName)
	assert.Contains(t, resourceGroupName, expectedRgPrefix)

	expectedSaPrefix := fmt.Sprintf("sa%sdevtfstateeus", projectName)
	assert.Contains(t, storageAccountName, expectedSaPrefix)

	// Verify the resources exist with the generated names
	assert.True(t, azure.StorageAccountExists(t, storageAccountName, resourceGroupName, ""))
}

// TestAzTfInitBackendConfiguration tests the generated backend configuration
func TestAzTfInitBackendConfiguration(t *testing.T) {
	t.Parallel()

	// Generate a random suffix to ensure uniqueness
	uniqueId := random.UniqueId()
	projectName := fmt.Sprintf("test%s", strings.ToLower(uniqueId)[0:6])

	// Construct the terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"project_name":     projectName,
			"environment":      "test",
			"location":         "East US",
			"enable_key_vault": false,
			"enable_monitoring": false,
		},

		EnvVars: map[string]string{
			"ARM_SUBSCRIPTION_ID": azure.GetSubscriptionID(),
		},
	})

	// Apply the configuration
	terraform.InitAndApply(t, terraformOptions)

	// Clean up
	defer terraform.Destroy(t, terraformOptions)

	// Test backend configuration outputs
	backendConfig := terraform.OutputMap(t, terraformOptions, "terraform_backend_config")
	backendHcl := terraform.Output(t, terraformOptions, "terraform_backend_hcl")
	backendCommand := terraform.Output(t, terraformOptions, "terraform_backend_command")

	// Verify backend configuration
	assert.NotEmpty(t, backendConfig["resource_group_name"])
	assert.NotEmpty(t, backendConfig["storage_account_name"])
	assert.Equal(t, "tfstate", backendConfig["container_name"])
	assert.Equal(t, "terraform.tfstate", backendConfig["key"])

	// Verify HCL and command outputs contain expected values
	assert.Contains(t, backendHcl, "backend \"azurerm\"")
	assert.Contains(t, backendHcl, backendConfig["storage_account_name"])
	assert.Contains(t, backendCommand, "terraform init")
	assert.Contains(t, backendCommand, backendConfig["storage_account_name"])
}