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

func TestApplicationInsightsBasic(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-appinsights-rg-%s", uniqueId)
	workspaceName := fmt.Sprintf("test-workspace-%s", uniqueId)
	appInsightsName := fmt.Sprintf("test-insights-%s", uniqueId)

	// Azure region for testing
	region := "East US"

	// Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"name":                              appInsightsName,
			"location":                          region,
			"resource_group_name":               resourceGroupName,
			"application_type":                  "web",
			"workspace_name":                    workspaceName,
			"workspace_resource_group_name":     resourceGroupName,
			"environment":                       "test",
			"criticality":                       "medium",
			"retention_in_days":                 90,
			"enable_standard_alerts":            true,
			"common_tags": map[string]interface{}{
				"Environment": "test",
				"Project":     "terratest",
				"Owner":       "automation",
			},
		},
	})

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Create prerequisite resources
	subscriptionID := azure.GetSubscriptionIDFromCLI(t)

	// Create resource group
	azure.CreateResourceGroup(t, resourceGroupName, region, subscriptionID)
	defer azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)

	// Create Log Analytics workspace
	azure.CreateLogAnalyticsWorkspace(t, workspaceName, resourceGroupName, region, subscriptionID)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	appInsightsId := terraform.Output(t, terraformOptions, "application_insights_id")
	appInsightsName := terraform.Output(t, terraformOptions, "application_insights_name")
	appId := terraform.Output(t, terraformOptions, "app_id")
	workspaceId := terraform.Output(t, terraformOptions, "workspace_id")

	// Assert outputs are not empty
	assert.NotEmpty(t, appInsightsId)
	assert.NotEmpty(t, appInsightsName)
	assert.NotEmpty(t, appId)
	assert.NotEmpty(t, workspaceId)

	// Validate Application Insights exists in Azure
	appInsights := azure.GetAppInsights(t, appInsightsName, resourceGroupName, subscriptionID)
	assert.NotNil(t, appInsights)
	assert.Equal(t, "web", *appInsights.ApplicationType)
	assert.Equal(t, region, *appInsights.Location)

	// Validate integration with Log Analytics workspace
	assert.Contains(t, workspaceId, workspaceName)

	// Validate monitoring configuration
	monitoringConfig := terraform.OutputMap(t, terraformOptions, "monitoring_config")
	assert.NotEmpty(t, monitoringConfig)
	assert.Equal(t, "true", monitoringConfig["alerts_enabled"])

	// Validate data governance
	dataGovernance := terraform.OutputMap(t, terraformOptions, "data_governance")
	assert.NotEmpty(t, dataGovernance)
	assert.Equal(t, "internal", dataGovernance["data_classification"])

	// Validate security configuration
	securityConfig := terraform.OutputMap(t, terraformOptions, "security_config")
	assert.NotEmpty(t, securityConfig)
	assert.Equal(t, "true", securityConfig["local_auth_disabled"])
}

func TestApplicationInsightsJavaApp(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-java-rg-%s", uniqueId)
	workspaceName := fmt.Sprintf("test-java-workspace-%s", uniqueId)
	appInsightsName := fmt.Sprintf("test-java-insights-%s", uniqueId)

	// Azure region for testing
	region := "West US 2"

	// Terraform options for Java application
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"name":                              appInsightsName,
			"location":                          region,
			"resource_group_name":               resourceGroupName,
			"application_type":                  "java",
			"workspace_name":                    workspaceName,
			"workspace_resource_group_name":     resourceGroupName,
			"environment":                       "test",
			"criticality":                       "high",
			"retention_in_days":                 180,
			"enable_standard_alerts":            true,
			"common_tags": map[string]interface{}{
				"Environment": "test",
				"Project":     "java-app",
				"Owner":       "dev-team",
			},
		},
	})

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Create prerequisite resources
	subscriptionID := azure.GetSubscriptionIDFromCLI(t)

	// Create resource group
	azure.CreateResourceGroup(t, resourceGroupName, region, subscriptionID)
	defer azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)

	// Create Log Analytics workspace
	azure.CreateLogAnalyticsWorkspace(t, workspaceName, resourceGroupName, region, subscriptionID)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Validate Java application type
	appInsights := azure.GetAppInsights(t, appInsightsName, resourceGroupName, subscriptionID)
	assert.Equal(t, "java", *appInsights.ApplicationType)

	// Validate retention period
	assert.Equal(t, int32(180), *appInsights.RetentionInDays)
}

func TestApplicationInsightsMobileApp(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-mobile-rg-%s", uniqueId)
	workspaceName := fmt.Sprintf("test-mobile-workspace-%s", uniqueId)
	appInsightsName := fmt.Sprintf("test-mobile-insights-%s", uniqueId)

	// Azure region for testing
	region := "Central US"

	// Test iOS application type
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"name":                              appInsightsName,
			"location":                          region,
			"resource_group_name":               resourceGroupName,
			"application_type":                  "ios",
			"workspace_name":                    workspaceName,
			"workspace_resource_group_name":     resourceGroupName,
			"environment":                       "prod",
			"criticality":                       "high",
			"retention_in_days":                 365,
			"enable_standard_alerts":            true,
			"common_tags": map[string]interface{}{
				"Environment": "prod",
				"Project":     "mobile-app",
				"Owner":       "mobile-team",
			},
		},
	})

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Create prerequisite resources
	subscriptionID := azure.GetSubscriptionIDFromCLI(t)

	// Create resource group
	azure.CreateResourceGroup(t, resourceGroupName, region, subscriptionID)
	defer azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)

	// Create Log Analytics workspace
	azure.CreateLogAnalyticsWorkspace(t, workspaceName, resourceGroupName, region, subscriptionID)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Validate iOS application type
	appInsights := azure.GetAppInsights(t, appInsightsName, resourceGroupName, subscriptionID)
	assert.Equal(t, "ios", *appInsights.ApplicationType)

	// Validate production retention period
	assert.Equal(t, int32(365), *appInsights.RetentionInDays)
}

func TestApplicationInsightsValidation(t *testing.T) {
	t.Parallel()

	// Test invalid application type
	t.Run("Invalid Application Type", func(t *testing.T) {
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: "../../examples/basic",
			Vars: map[string]interface{}{
				"application_type": "invalid-type",
			},
		})

		_, err := terraform.InitAndPlanE(t, terraformOptions)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "Application type must be one of")
	})

	// Test invalid environment
	t.Run("Invalid Environment", func(t *testing.T) {
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: "../../examples/basic",
			Vars: map[string]interface{}{
				"environment": "invalid-env",
			},
		})

		_, err := terraform.InitAndPlanE(t, terraformOptions)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "Environment must be one of")
	})

	// Test invalid criticality
	t.Run("Invalid Criticality", func(t *testing.T) {
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: "../../examples/basic",
			Vars: map[string]interface{}{
				"criticality": "invalid-criticality",
			},
		})

		_, err := terraform.InitAndPlanE(t, terraformOptions)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "Criticality must be one of")
	})

	// Test invalid retention period
	t.Run("Invalid Retention Period", func(t *testing.T) {
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: "../../examples/basic",
			Vars: map[string]interface{}{
				"retention_in_days": 45, // Invalid retention period
			},
		})

		_, err := terraform.InitAndPlanE(t, terraformOptions)
		assert.Error(t, err)
		assert.Contains(t, strings.ToLower(err.Error()), "retention")
	})

	// Test invalid name format
	t.Run("Invalid Name Format", func(t *testing.T) {
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: "../../examples/basic",
			Vars: map[string]interface{}{
				"name": "invalid@name!",
			},
		})

		_, err := terraform.InitAndPlanE(t, terraformOptions)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "Name must be")
	})
}

func TestApplicationInsightsOutputs(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-outputs-rg-%s", uniqueId)
	workspaceName := fmt.Sprintf("test-outputs-workspace-%s", uniqueId)
	appInsightsName := fmt.Sprintf("test-outputs-insights-%s", uniqueId)

	// Azure region for testing
	region := "East US 2"

	// Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"name":                              appInsightsName,
			"location":                          region,
			"resource_group_name":               resourceGroupName,
			"application_type":                  "web",
			"workspace_name":                    workspaceName,
			"workspace_resource_group_name":     resourceGroupName,
			"environment":                       "test",
			"criticality":                       "low",
			"retention_in_days":                 30,
			"enable_standard_alerts":            false, // Disable for testing
			"common_tags": map[string]interface{}{
				"Environment": "test",
				"Project":     "outputs-test",
				"Owner":       "automation",
			},
		},
	})

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Create prerequisite resources
	subscriptionID := azure.GetSubscriptionIDFromCLI(t)

	// Create resource group
	azure.CreateResourceGroup(t, resourceGroupName, region, subscriptionID)
	defer azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)

	// Create Log Analytics workspace
	azure.CreateLogAnalyticsWorkspace(t, workspaceName, resourceGroupName, region, subscriptionID)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Test all basic outputs
	outputs := []string{
		"application_insights_id",
		"application_insights_name",
		"app_id",
		"workspace_id",
		"monitoring_config",
		"data_governance",
		"security_config",
	}

	for _, output := range outputs {
		value := terraform.Output(t, terraformOptions, output)
		assert.NotEmpty(t, value, fmt.Sprintf("Output %s should not be empty", output))
	}

	// Validate sensitive outputs exist (but don't access values)
	require.NotPanics(t, func() {
		terraform.Output(t, terraformOptions, "instrumentation_key")
		terraform.Output(t, terraformOptions, "connection_string")
	}, "Sensitive outputs should be accessible")

	// Validate monitoring configuration structure
	monitoringConfig := terraform.OutputMap(t, terraformOptions, "monitoring_config")
	expectedMonitoringKeys := []string{"alerts_enabled", "web_tests_count", "custom_alerts_count"}
	for _, key := range expectedMonitoringKeys {
		assert.Contains(t, monitoringConfig, key, fmt.Sprintf("Monitoring config should contain %s", key))
	}

	// Validate data governance structure
	dataGovernance := terraform.OutputMap(t, terraformOptions, "data_governance")
	expectedGovernanceKeys := []string{"data_classification", "data_retention_policy", "pii_detection_enabled"}
	for _, key := range expectedGovernanceKeys {
		assert.Contains(t, dataGovernance, key, fmt.Sprintf("Data governance should contain %s", key))
	}

	// Validate security configuration structure
	securityConfig := terraform.OutputMap(t, terraformOptions, "security_config")
	expectedSecurityKeys := []string{"local_auth_disabled", "internet_ingestion_enabled", "ip_masking_disabled"}
	for _, key := range expectedSecurityKeys {
		assert.Contains(t, securityConfig, key, fmt.Sprintf("Security config should contain %s", key))
	}
}

func TestApplicationInsightsResourceCreation(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-creation-rg-%s", uniqueId)
	workspaceName := fmt.Sprintf("test-creation-workspace-%s", uniqueId)
	appInsightsName := fmt.Sprintf("test-creation-insights-%s", uniqueId)

	// Azure region for testing
	region := "North Central US"

	// Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"name":                              appInsightsName,
			"location":                          region,
			"resource_group_name":               resourceGroupName,
			"application_type":                  "web",
			"workspace_name":                    workspaceName,
			"workspace_resource_group_name":     resourceGroupName,
			"environment":                       "dev",
			"criticality":                       "medium",
			"retention_in_days":                 60,
			"enable_standard_alerts":            true,
			"common_tags": map[string]interface{}{
				"Environment": "dev",
				"Project":     "resource-test",
				"Owner":       "automation",
				"Purpose":     "testing",
			},
		},
	})

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Create prerequisite resources
	subscriptionID := azure.GetSubscriptionIDFromCLI(t)

	// Create resource group
	azure.CreateResourceGroup(t, resourceGroupName, region, subscriptionID)
	defer azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)

	// Create Log Analytics workspace
	azure.CreateLogAnalyticsWorkspace(t, workspaceName, resourceGroupName, region, subscriptionID)

	// Wait for workspace to be fully provisioned
	time.Sleep(30 * time.Second)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Validate Application Insights resource exists and is configured correctly
	appInsights := azure.GetAppInsights(t, appInsightsName, resourceGroupName, subscriptionID)
	require.NotNil(t, appInsights)

	// Validate properties
	assert.Equal(t, appInsightsName, *appInsights.Name)
	assert.Equal(t, "web", *appInsights.ApplicationType)
	assert.Equal(t, region, *appInsights.Location)
	assert.Equal(t, int32(60), *appInsights.RetentionInDays)

	// Validate tags
	require.NotNil(t, appInsights.Tags)
	tags := appInsights.Tags
	assert.Equal(t, "dev", *tags["Environment"])
	assert.Equal(t, "resource-test", *tags["Project"])
	assert.Equal(t, "automation", *tags["Owner"])
	assert.Equal(t, "testing", *tags["Purpose"])
	assert.Equal(t, "Terraform", *tags["ManagedBy"])
	assert.Equal(t, "shared", *tags["Layer"])

	// Validate workspace integration
	workspaceId := terraform.Output(t, terraformOptions, "workspace_id")
	assert.Contains(t, workspaceId, workspaceName)
	assert.NotNil(t, appInsights.WorkspaceResourceID)
	assert.Contains(t, *appInsights.WorkspaceResourceID, workspaceName)
}