package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestApplicationInsightsAdvanced(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-adv-rg-%s", uniqueId)
	workspaceName := fmt.Sprintf("test-adv-workspace-%s", uniqueId)
	appInsightsName := fmt.Sprintf("test-adv-insights-%s", uniqueId)
	actionGroupName := fmt.Sprintf("test-adv-actiongroup-%s", uniqueId)

	// Azure region for testing
	region := "East US"

	// Create workspace ID path for the test
	subscriptionID := azure.GetSubscriptionIDFromCLI(t)
	workspaceId := fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.OperationalInsights/workspaces/%s",
		subscriptionID, resourceGroupName, workspaceName)
	actionGroupId := fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Insights/actionGroups/%s",
		subscriptionID, resourceGroupName, actionGroupName)

	// Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/advanced",
		Vars: map[string]interface{}{
			"name":                                     appInsightsName,
			"location":                                 region,
			"resource_group_name":                      resourceGroupName,
			"application_type":                         "web",
			"workspace_id":                             workspaceId,
			"environment":                              "prod",
			"criticality":                              "critical",
			"retention_in_days":                        730,
			"daily_data_cap_gb":                        10,
			"daily_data_cap_notifications_disabled":   false,
			"sampling_percentage":                      100,
			"disable_ip_masking":                       false,
			"local_authentication_disabled":           true,
			"internet_ingestion_enabled":               true,
			"internet_query_enabled":                   true,
			"force_customer_storage_for_profiler":     false,
			"enable_standard_alerts":                   true,
			"alert_severity":                           1,
			"server_response_time_threshold":           3000,
			"failure_rate_threshold":                   5,
			"exception_rate_threshold":                 3,
			"action_group_ids":                         []string{actionGroupId},
			"enable_continuous_export":                 true,
			"compliance_requirements":                  []string{"SOX", "PCI-DSS", "ISO27001"},
			"data_governance": map[string]interface{}{
				"data_classification":   "confidential",
				"data_retention_policy": "extended",
				"pii_detection_enabled": true,
				"data_masking_enabled":  true,
			},
			"common_tags": map[string]interface{}{
				"Environment":  "prod",
				"Project":      "enterprise-platform",
				"Owner":        "platform-team",
				"CostCenter":   "engineering",
				"BusinessUnit": "technology",
				"DataClass":    "confidential",
				"Compliance":   "required",
			},
		},
	})

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Create prerequisite resources
	// Create resource group
	azure.CreateResourceGroup(t, resourceGroupName, region, subscriptionID)
	defer azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)

	// Create Log Analytics workspace
	azure.CreateLogAnalyticsWorkspace(t, workspaceName, resourceGroupName, region, subscriptionID)

	// Create action group for alerts
	azure.CreateActionGroup(t, actionGroupName, resourceGroupName, subscriptionID)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	appInsightsId := terraform.Output(t, terraformOptions, "application_insights_id")
	appInsightsName := terraform.Output(t, terraformOptions, "application_insights_name")
	appId := terraform.Output(t, terraformOptions, "app_id")

	// Assert outputs are not empty
	assert.NotEmpty(t, appInsightsId)
	assert.NotEmpty(t, appInsightsName)
	assert.NotEmpty(t, appId)

	// Validate Application Insights exists in Azure with advanced configuration
	appInsights := azure.GetAppInsights(t, appInsightsName, resourceGroupName, subscriptionID)
	assert.NotNil(t, appInsights)
	assert.Equal(t, "web", *appInsights.ApplicationType)
	assert.Equal(t, int32(730), *appInsights.RetentionInDays)

	// Validate advanced monitoring configuration
	monitoringConfig := terraform.OutputMap(t, terraformOptions, "monitoring_config")
	assert.NotEmpty(t, monitoringConfig)
	assert.Equal(t, "true", monitoringConfig["alerts_enabled"])

	// Validate enterprise governance
	dataGovernance := terraform.OutputMap(t, terraformOptions, "data_governance")
	assert.NotEmpty(t, dataGovernance)
	assert.Equal(t, "confidential", dataGovernance["data_classification"])
	assert.Equal(t, "extended", dataGovernance["data_retention_policy"])
	assert.Equal(t, "true", dataGovernance["pii_detection_enabled"])

	// Validate security configuration
	securityConfig := terraform.OutputMap(t, terraformOptions, "security_config")
	assert.NotEmpty(t, securityConfig)
	assert.Equal(t, "true", securityConfig["local_auth_disabled"])
	assert.Equal(t, "true", securityConfig["internet_ingestion_enabled"])

	// Validate web tests
	webTests := terraform.OutputMap(t, terraformOptions, "web_tests")
	assert.NotEmpty(t, webTests)

	// Validate custom alerts
	customAlerts := terraform.OutputMap(t, terraformOptions, "custom_alerts")
	assert.NotEmpty(t, customAlerts)

	// Validate smart detection rules
	smartDetection := terraform.OutputMap(t, terraformOptions, "smart_detection_rules")
	assert.NotEmpty(t, smartDetection)

	// Validate analytics items
	analyticsItems := terraform.OutputMap(t, terraformOptions, "analytics_items")
	assert.NotEmpty(t, analyticsItems)

	// Validate API keys
	apiKeys := terraform.OutputMap(t, terraformOptions, "api_keys")
	assert.NotEmpty(t, apiKeys)

	// Validate workbook templates
	workbookTemplates := terraform.OutputMap(t, terraformOptions, "workbook_templates")
	assert.NotEmpty(t, workbookTemplates)

	// Validate continuous export configuration
	continuousExport := terraform.OutputMap(t, terraformOptions, "continuous_export_config")
	assert.NotEmpty(t, continuousExport)
	assert.Equal(t, "true", continuousExport["enabled"])

	// Validate enterprise summary
	enterpriseSummary := terraform.OutputMap(t, terraformOptions, "enterprise_summary")
	assert.NotEmpty(t, enterpriseSummary)
}

func TestApplicationInsightsWebTests(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-webtests-rg-%s", uniqueId)
	workspaceName := fmt.Sprintf("test-webtests-workspace-%s", uniqueId)
	appInsightsName := fmt.Sprintf("test-webtests-insights-%s", uniqueId)

	// Azure region for testing
	region := "West US 2"

	// Create workspace ID path for the test
	subscriptionID := azure.GetSubscriptionIDFromCLI(t)
	workspaceId := fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.OperationalInsights/workspaces/%s",
		subscriptionID, resourceGroupName, workspaceName)

	// Terraform options with web tests
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/advanced",
		Vars: map[string]interface{}{
			"name":                 appInsightsName,
			"location":             region,
			"resource_group_name":  resourceGroupName,
			"application_type":     "web",
			"workspace_id":         workspaceId,
			"environment":          "test",
			"criticality":          "high",
			"enable_standard_alerts": false, // Disable standard alerts for this test
			"web_tests": map[string]interface{}{
				"homepage": map[string]interface{}{
					"kind":          "ping",
					"frequency":     300,
					"timeout":       30,
					"enabled":       true,
					"retry_enabled": true,
					"geo_locations": []string{"us-il-ch1-azr", "us-ca-sjc-azr"},
					"description":   "Homepage availability test",
					"configuration": `<WebTest Name="Homepage Test" Id="12345678-1234-1234-1234-123456789012" Enabled="True" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010"><Items><Request Method="GET" Url="https://example.com" /></Items></WebTest>`,
				},
			},
			"common_tags": map[string]interface{}{
				"Environment": "test",
				"Project":     "webtests",
				"Owner":       "automation",
			},
		},
	})

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Create prerequisite resources
	azure.CreateResourceGroup(t, resourceGroupName, region, subscriptionID)
	defer azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)

	azure.CreateLogAnalyticsWorkspace(t, workspaceName, resourceGroupName, region, subscriptionID)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Validate web tests were created
	webTests := terraform.OutputMap(t, terraformOptions, "web_tests")
	assert.NotEmpty(t, webTests)

	// Validate specific web test properties
	webTestsOutput := terraform.Output(t, terraformOptions, "web_tests")
	assert.Contains(t, webTestsOutput, "homepage")
}

func TestApplicationInsightsCustomAlerts(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-alerts-rg-%s", uniqueId)
	workspaceName := fmt.Sprintf("test-alerts-workspace-%s", uniqueId)
	appInsightsName := fmt.Sprintf("test-alerts-insights-%s", uniqueId)
	actionGroupName := fmt.Sprintf("test-alerts-actiongroup-%s", uniqueId)

	// Azure region for testing
	region := "Central US"

	// Create workspace and action group IDs
	subscriptionID := azure.GetSubscriptionIDFromCLI(t)
	workspaceId := fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.OperationalInsights/workspaces/%s",
		subscriptionID, resourceGroupName, workspaceName)
	actionGroupId := fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Insights/actionGroups/%s",
		subscriptionID, resourceGroupName, actionGroupName)

	// Terraform options with custom alerts
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/advanced",
		Vars: map[string]interface{}{
			"name":                   appInsightsName,
			"location":               region,
			"resource_group_name":    resourceGroupName,
			"application_type":       "web",
			"workspace_id":           workspaceId,
			"environment":            "test",
			"criticality":            "high",
			"enable_standard_alerts": false, // Disable standard alerts
			"action_group_ids":       []string{actionGroupId},
			"custom_alerts": map[string]interface{}{
				"high_cpu": map[string]interface{}{
					"description":      "High CPU usage alert",
					"severity":         1,
					"frequency":        "PT1M",
					"window_size":      "PT5M",
					"enabled":          true,
					"metric_namespace": "Microsoft.Insights/components",
					"metric_name":      "performanceCounters/processCpuPercentage",
					"aggregation":      "Average",
					"operator":         "GreaterThan",
					"threshold":        80,
					"dimensions":       []interface{}{},
				},
			},
			"common_tags": map[string]interface{}{
				"Environment": "test",
				"Project":     "alerts-test",
				"Owner":       "automation",
			},
		},
	})

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Create prerequisite resources
	azure.CreateResourceGroup(t, resourceGroupName, region, subscriptionID)
	defer azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)

	azure.CreateLogAnalyticsWorkspace(t, workspaceName, resourceGroupName, region, subscriptionID)
	azure.CreateActionGroup(t, actionGroupName, resourceGroupName, subscriptionID)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Validate custom alerts were created
	customAlerts := terraform.OutputMap(t, terraformOptions, "custom_alerts")
	assert.NotEmpty(t, customAlerts)

	// Validate monitoring configuration
	monitoringConfig := terraform.OutputMap(t, terraformOptions, "monitoring_config")
	assert.Equal(t, "false", monitoringConfig["alerts_enabled"]) // Standard alerts disabled
	assert.Equal(t, "1", monitoringConfig["custom_alerts_count"])
}

func TestApplicationInsightsAnalyticsItems(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-analytics-rg-%s", uniqueId)
	workspaceName := fmt.Sprintf("test-analytics-workspace-%s", uniqueId)
	appInsightsName := fmt.Sprintf("test-analytics-insights-%s", uniqueId)

	// Azure region for testing
	region := "East US 2"

	// Create workspace ID path
	subscriptionID := azure.GetSubscriptionIDFromCLI(t)
	workspaceId := fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.OperationalInsights/workspaces/%s",
		subscriptionID, resourceGroupName, workspaceName)

	// Terraform options with analytics items
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/advanced",
		Vars: map[string]interface{}{
			"name":                   appInsightsName,
			"location":               region,
			"resource_group_name":    resourceGroupName,
			"application_type":       "web",
			"workspace_id":           workspaceId,
			"environment":            "test",
			"criticality":            "medium",
			"enable_standard_alerts": false,
			"analytics_items": map[string]interface{}{
				"error_analysis": map[string]interface{}{
					"type":           "query",
					"scope":          "shared",
					"content":        "exceptions | where timestamp > ago(24h) | summarize count() by type",
					"function_alias": "",
				},
				"get_error_rate": map[string]interface{}{
					"type":           "function",
					"scope":          "shared",
					"content":        "requests | summarize total = count(), errors = countif(success == false)",
					"function_alias": "GetErrorRate",
				},
			},
			"common_tags": map[string]interface{}{
				"Environment": "test",
				"Project":     "analytics-test",
				"Owner":       "automation",
			},
		},
	})

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Create prerequisite resources
	azure.CreateResourceGroup(t, resourceGroupName, region, subscriptionID)
	defer azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)

	azure.CreateLogAnalyticsWorkspace(t, workspaceName, resourceGroupName, region, subscriptionID)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Validate analytics items were created
	analyticsItems := terraform.OutputMap(t, terraformOptions, "analytics_items")
	assert.NotEmpty(t, analyticsItems)
}

func TestApplicationInsightsAPIKeys(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-apikeys-rg-%s", uniqueId)
	workspaceName := fmt.Sprintf("test-apikeys-workspace-%s", uniqueId)
	appInsightsName := fmt.Sprintf("test-apikeys-insights-%s", uniqueId)

	// Azure region for testing
	region := "West US"

	// Create workspace ID path
	subscriptionID := azure.GetSubscriptionIDFromCLI(t)
	workspaceId := fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.OperationalInsights/workspaces/%s",
		subscriptionID, resourceGroupName, workspaceName)

	// Terraform options with API keys
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/advanced",
		Vars: map[string]interface{}{
			"name":                   appInsightsName,
			"location":               region,
			"resource_group_name":    resourceGroupName,
			"application_type":       "web",
			"workspace_id":           workspaceId,
			"environment":            "test",
			"criticality":            "medium",
			"enable_standard_alerts": false,
			"api_keys": map[string]interface{}{
				"monitoring": map[string]interface{}{
					"read_permissions":  []string{"aggregate", "api", "search"},
					"write_permissions": []string{"annotations"},
				},
				"dashboard": map[string]interface{}{
					"read_permissions":  []string{"api", "search"},
					"write_permissions": []string{},
				},
			},
			"common_tags": map[string]interface{}{
				"Environment": "test",
				"Project":     "apikeys-test",
				"Owner":       "automation",
			},
		},
	})

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Create prerequisite resources
	azure.CreateResourceGroup(t, resourceGroupName, region, subscriptionID)
	defer azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)

	azure.CreateLogAnalyticsWorkspace(t, workspaceName, resourceGroupName, region, subscriptionID)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Validate API keys were created
	apiKeys := terraform.OutputMap(t, terraformOptions, "api_keys")
	assert.NotEmpty(t, apiKeys)

	// Verify API key values exist (but are sensitive)
	require.NotPanics(t, func() {
		terraform.Output(t, terraformOptions, "api_key_values")
	}, "API key values should be accessible as sensitive output")
}

func TestApplicationInsightsEnterprise(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-enterprise-rg-%s", uniqueId)
	workspaceName := fmt.Sprintf("test-enterprise-workspace-%s", uniqueId)
	appInsightsName := fmt.Sprintf("test-enterprise-insights-%s", uniqueId)

	// Azure region for testing
	region := "North Central US"

	// Create workspace ID path
	subscriptionID := azure.GetSubscriptionIDFromCLI(t)
	workspaceId := fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.OperationalInsights/workspaces/%s",
		subscriptionID, resourceGroupName, workspaceName)

	// Terraform options with full enterprise configuration
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/advanced",
		Vars: map[string]interface{}{
			"name":                                     appInsightsName,
			"location":                                 region,
			"resource_group_name":                      resourceGroupName,
			"application_type":                         "web",
			"workspace_id":                             workspaceId,
			"environment":                              "prod",
			"criticality":                              "critical",
			"retention_in_days":                        730,
			"daily_data_cap_gb":                        10,
			"sampling_percentage":                      100,
			"local_authentication_disabled":           true,
			"disable_ip_masking":                       false,
			"enable_standard_alerts":                   false, // Disable for test simplicity
			"enable_continuous_export":                 true,
			"compliance_requirements":                  []string{"SOX", "PCI-DSS", "ISO27001", "GDPR", "HIPAA"},
			"data_governance": map[string]interface{}{
				"data_classification":   "confidential",
				"data_retention_policy": "extended",
				"pii_detection_enabled": true,
				"data_masking_enabled":  true,
			},
			"common_tags": map[string]interface{}{
				"Environment":    "prod",
				"Project":        "enterprise-infrastructure",
				"Owner":          "platform-team",
				"CostCenter":     "engineering",
				"BusinessUnit":   "technology",
				"Application":    "core-services",
				"DataClass":      "confidential",
				"Compliance":     "required",
				"BackupSchedule": "daily",
				"MonitoringTier": "platinum",
				"SLA":            "99.99",
			},
		},
	})

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Create prerequisite resources
	azure.CreateResourceGroup(t, resourceGroupName, region, subscriptionID)
	defer azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)

	azure.CreateLogAnalyticsWorkspace(t, workspaceName, resourceGroupName, region, subscriptionID)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Validate all enterprise outputs
	enterpriseOutputs := []string{
		"application_insights_id",
		"application_insights_name",
		"app_id",
		"workspace_id",
		"monitoring_config",
		"data_governance",
		"security_config",
		"continuous_export_config",
		"resource_details",
		"enterprise_summary",
	}

	for _, output := range enterpriseOutputs {
		value := terraform.Output(t, terraformOptions, output)
		assert.NotEmpty(t, value, fmt.Sprintf("Enterprise output %s should not be empty", output))
	}

	// Validate enterprise-specific values
	assert.Equal(t, appInsightsName, terraform.Output(t, terraformOptions, "application_insights_name"))

	// Validate data governance compliance
	dataGovernance := terraform.OutputMap(t, terraformOptions, "data_governance")
	assert.Equal(t, "confidential", dataGovernance["data_classification"])
	assert.Equal(t, "extended", dataGovernance["data_retention_policy"])
	assert.Equal(t, "true", dataGovernance["pii_detection_enabled"])
	assert.Equal(t, "true", dataGovernance["data_masking_enabled"])

	// Validate security posture
	securityConfig := terraform.OutputMap(t, terraformOptions, "security_config")
	assert.Equal(t, "true", securityConfig["local_auth_disabled"])
	assert.Equal(t, "false", securityConfig["ip_masking_disabled"]) // IP masking enabled

	// Validate continuous export
	continuousExport := terraform.OutputMap(t, terraformOptions, "continuous_export_config")
	assert.Equal(t, "true", continuousExport["enabled"])

	// Validate enterprise summary structure
	enterpriseSummary := terraform.OutputMap(t, terraformOptions, "enterprise_summary")
	assert.Equal(t, "prod", enterpriseSummary["environment"])
	assert.Equal(t, "critical", enterpriseSummary["criticality"])

	// Validate Application Insights resource in Azure
	appInsights := azure.GetAppInsights(t, appInsightsName, resourceGroupName, subscriptionID)
	assert.Equal(t, int32(730), *appInsights.RetentionInDays)
	assert.Equal(t, float64(10), *appInsights.DailyDataCapInGB)

	// Validate enterprise tags
	tags := appInsights.Tags
	assert.Equal(t, "prod", *tags["Environment"])
	assert.Equal(t, "enterprise-infrastructure", *tags["Project"])
	assert.Equal(t, "confidential", *tags["DataClass"])
	assert.Equal(t, "required", *tags["Compliance"])
	assert.Equal(t, "99.99", *tags["SLA"])
}