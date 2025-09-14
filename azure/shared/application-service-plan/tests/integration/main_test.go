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

// TestAzureAppServicePlanCreation tests the basic creation of an Azure App Service Plan
func TestAzureAppServicePlanCreation(t *testing.T) {
	t.Parallel()

	// Generate random suffix for unique resource naming
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-asp-%s", uniqueID)
	servicePlanName := fmt.Sprintf("test-plan-%s", uniqueID)
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
			"resource_group_name": resourceGroupName,
			"location":           location,
			"os_type":            "Linux",
			"sku_name":           "B1",

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
	servicePlanID := terraform.Output(t, terraformOptions, "app_service_plan_id")
	assert.NotEmpty(t, servicePlanID)
	assert.Contains(t, servicePlanID, "example-service-plan")

	servicePlanNameOutput := terraform.Output(t, terraformOptions, "app_service_plan_name")
	assert.Equal(t, "example-service-plan", servicePlanNameOutput)

	osTypeOutput := terraform.Output(t, terraformOptions, "os_type")
	assert.Equal(t, "Linux", osTypeOutput)

	skuNameOutput := terraform.Output(t, terraformOptions, "sku_name")
	assert.Equal(t, "B1", skuNameOutput)

	// Verify the App Service Plan exists in Azure
	subscriptionID := azure.GetAccountSubscription(t)
	servicePlan := azure.GetAppServicePlan(t, subscriptionID, resourceGroupName, "example-service-plan")

	assert.Equal(t, "example-service-plan", *servicePlan.Name)
	assert.Equal(t, "Linux", string(servicePlan.Kind))
}

// TestAzureAppServicePlanAdvancedFeatures tests advanced App Service Plan features
func TestAzureAppServicePlanAdvancedFeatures(t *testing.T) {
	t.Parallel()

	// Generate random suffix for unique resource naming
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-asp-adv-%s", uniqueID)
	servicePlanName := fmt.Sprintf("test-adv-plan-%s", uniqueID)
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
			"service_plan_name":    servicePlanName,
			"resource_group_name": resourceGroupName,
			"location":            location,

			// Performance configuration
			"os_type":                      "Linux",
			"sku_name":                     "P1v3",
			"worker_count":                 2,
			"zone_balancing_enabled":       false, // Keep false for test cost optimization
			"per_site_scaling_enabled":     true,

			// Auto-scaling settings
			"enable_autoscaling": true,
			"autoscale_settings": map[string]interface{}{
				"default_instances":          2,
				"minimum_instances":         1,
				"maximum_instances":         5,
				"cpu_threshold_out":         70,
				"cpu_threshold_in":          25,
				"memory_threshold_out":      80,
				"memory_threshold_in":       60,
				"enable_memory_scaling":     true,
				"scale_out_cooldown":        5,
				"scale_in_cooldown":         10,
			},

			// Monitoring settings
			"enable_diagnostic_settings": true,
			"create_log_analytics":      true,
			"enable_alerts":             true,
			"create_action_group":       true,

			// Advanced features
			"create_application_insights":  true,
			"create_diagnostics_storage":   true,

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

	// Validate App Service Plan outputs
	servicePlanID := terraform.Output(t, terraformOptions, "app_service_plan_id")
	assert.NotEmpty(t, servicePlanID)
	assert.Contains(t, servicePlanID, servicePlanName)

	servicePlanNameOutput := terraform.Output(t, terraformOptions, "app_service_plan_name")
	assert.Equal(t, servicePlanName, servicePlanNameOutput)

	// Validate scaling configuration
	scalingSummary := terraform.OutputMap(t, terraformOptions, "scaling_summary")
	assert.Equal(t, "2", scalingSummary["worker_count"])
	assert.Equal(t, "true", scalingSummary["per_site_scaling_enabled"])
	assert.Equal(t, "true", scalingSummary["autoscaling_enabled"])

	// Validate monitoring configuration
	monitoringSummary := terraform.OutputMap(t, terraformOptions, "monitoring_summary")
	assert.Equal(t, "true", monitoringSummary["diagnostic_settings_enabled"])
	assert.Equal(t, "true", monitoringSummary["alerts_enabled"])

	// Validate advanced features
	advancedFeaturesSummary := terraform.OutputMap(t, terraformOptions, "advanced_features_summary")
	assert.Equal(t, "true", advancedFeaturesSummary["log_analytics_created"])
	assert.Equal(t, "true", advancedFeaturesSummary["application_insights_created"])
	assert.Equal(t, "true", advancedFeaturesSummary["action_group_created"])
	assert.Equal(t, "true", advancedFeaturesSummary["diagnostics_storage_created"])

	// Validate Log Analytics workspace creation
	logAnalyticsWorkspaceName := terraform.Output(t, terraformOptions, "log_analytics_workspace_name")
	assert.NotEmpty(t, logAnalyticsWorkspaceName)
	assert.Contains(t, logAnalyticsWorkspaceName, servicePlanName)

	// Validate Application Insights creation
	applicationInsightsID := terraform.Output(t, terraformOptions, "application_insights_id")
	assert.NotEmpty(t, applicationInsightsID)

	// Validate Action Group creation
	actionGroupName := terraform.Output(t, terraformOptions, "action_group_name")
	assert.NotEmpty(t, actionGroupName)
	assert.Contains(t, actionGroupName, servicePlanName)

	// Validate storage account creation
	diagnosticsStorageName := terraform.Output(t, terraformOptions, "diagnostics_storage_account_name")
	assert.NotEmpty(t, diagnosticsStorageName)

	// Verify the App Service Plan exists in Azure with correct configuration
	subscriptionID := azure.GetAccountSubscription(t)
	servicePlan := azure.GetAppServicePlan(t, subscriptionID, resourceGroupName, servicePlanName)

	assert.Equal(t, servicePlanName, *servicePlan.Name)
	assert.Equal(t, "app", string(servicePlan.Kind)) // Premium v3 plans show as "app"
}

// TestAzureAppServicePlanScalingConfiguration tests scaling-specific features
func TestAzureAppServicePlanScalingConfiguration(t *testing.T) {
	t.Parallel()

	// Generate random suffix for unique resource naming
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-asp-scaling-%s", uniqueID)
	servicePlanName := fmt.Sprintf("test-scaling-plan-%s", uniqueID)
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
			"resource_group_name": resourceGroupName,
			"location":           location,

			// Scaling configuration testing
			"os_type":                   "Linux",
			"sku_name":                 "S1", // Standard tier supports scaling
			"worker_count":             3,
			"per_site_scaling_enabled": true,

			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest-scaling",
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

	// Validate scaling configuration outputs
	scalingSummary := terraform.OutputMap(t, terraformOptions, "scaling_summary")
	assert.Equal(t, "3", scalingSummary["worker_count"])
	assert.Equal(t, "true", scalingSummary["per_site_scaling_enabled"])

	skuNameOutput := terraform.Output(t, terraformOptions, "sku_name")
	assert.Equal(t, "S1", skuNameOutput)

	// Verify the App Service Plan exists with correct scaling configuration
	subscriptionID := azure.GetAccountSubscription(t)
	servicePlan := azure.GetAppServicePlan(t, subscriptionID, resourceGroupName, "example-service-plan")

	assert.Equal(t, "example-service-plan", *servicePlan.Name)
}

// TestAzureAppServicePlanWindowsConfiguration tests Windows-specific configuration
func TestAzureAppServicePlanWindowsConfiguration(t *testing.T) {
	t.Parallel()

	// Generate random suffix for unique resource naming
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-asp-windows-%s", uniqueID)
	servicePlanName := fmt.Sprintf("test-windows-plan-%s", uniqueID)
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
			"resource_group_name": resourceGroupName,
			"location":           location,

			// Windows configuration testing
			"os_type":  "Windows",
			"sku_name": "B2", // Basic tier with more capacity for Windows

			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest-windows",
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

	// Validate Windows configuration outputs
	osTypeOutput := terraform.Output(t, terraformOptions, "os_type")
	assert.Equal(t, "Windows", osTypeOutput)

	skuNameOutput := terraform.Output(t, terraformOptions, "sku_name")
	assert.Equal(t, "B2", skuNameOutput)

	// Verify the App Service Plan exists with Windows configuration
	subscriptionID := azure.GetAccountSubscription(t)
	servicePlan := azure.GetAppServicePlan(t, subscriptionID, resourceGroupName, "example-service-plan")

	assert.Equal(t, "example-service-plan", *servicePlan.Name)
	// Windows plans typically show as "app" kind
	assert.Contains(t, strings.ToLower(string(servicePlan.Kind)), "app")
}

// Benchmark test for module performance
func BenchmarkAzureAppServicePlanModule(b *testing.B) {
	for i := 0; i < b.N; i++ {
		uniqueID := random.UniqueId()
		resourceGroupName := fmt.Sprintf("bench-asp-%s", uniqueID)

		terraformOptions := &terraform.Options{
			TerraformDir: "../../examples/basic",
			Vars: map[string]interface{}{
				"resource_group_name": resourceGroupName,
				"os_type":            "Linux",
				"sku_name":           "B1",
			},
		}

		// Measure terraform plan time
		terraform.InitAndPlan(b, terraformOptions)

		// Clean up
		subscriptionID := azure.GetAccountSubscription(b)
		azure.DeleteResourceGroup(b, resourceGroupName, subscriptionID)
	}
}

// TestAzureAppServicePlanTagsAndNaming tests proper tagging and naming conventions
func TestAzureAppServicePlanTagsAndNaming(t *testing.T) {
	t.Parallel()

	// Generate random suffix for unique resource naming
	uniqueID := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-asp-tags-%s", uniqueID)
	location := "East US"

	// Ensure cleanup
	defer func() {
		// Clean up resources
		subscriptionID := azure.GetAccountSubscription(t)
		azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)
	}()

	expectedTags := map[string]string{
		"Environment": "test",
		"Project":     "terratest-tags",
		"Owner":       "automation",
		"CostCenter":  "engineering",
		"ManagedBy":   "Terraform",
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"resource_group_name": resourceGroupName,
			"location":           location,
			"os_type":            "Linux",
			"sku_name":           "B1",

			"common_tags": expectedTags,

			"application_plan_tags": map[string]string{
				"Purpose": "testing",
				"Tier":    "basic",
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

	// Validate tags output
	tagsOutput := terraform.OutputMap(t, terraformOptions, "tags")

	// Check that all expected common tags are present
	for key, expectedValue := range expectedTags {
		actualValue, exists := tagsOutput[key]
		assert.True(t, exists, fmt.Sprintf("Tag %s should exist", key))
		assert.Equal(t, expectedValue, actualValue, fmt.Sprintf("Tag %s should have correct value", key))
	}

	// Check module-specific tags
	assert.Equal(t, "Terraform", tagsOutput["ManagedBy"])
	assert.Contains(t, tagsOutput["Module"], "zrr-tf-module-lib/azure/shared/application-service-plan")
	assert.Equal(t, "shared", tagsOutput["Layer"])

	// Check resource-specific tags
	assert.Equal(t, "testing", tagsOutput["Purpose"])
	assert.Equal(t, "basic", tagsOutput["Tier"])
}