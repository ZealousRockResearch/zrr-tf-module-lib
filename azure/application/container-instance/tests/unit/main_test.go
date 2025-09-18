package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestContainerInstanceUnitValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                "test-container",
			"location":            "East US",
			"resource_group_name": "test-rg",
			"containers": []map[string]interface{}{
				{
					"name":   "test-app",
					"image":  "nginx:latest",
					"cpu":    1,
					"memory": 1.5,
				},
			},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
			},
		},

		// Only run terraform plan for unit tests
		PlanFilePath: "./unit-test.tfplan",
	}

	// Run terraform plan
	terraform.Plan(t, terraformOptions)

	// Test basic outputs (plan outputs)
	planStruct := terraform.InitAndPlanAndShow(t, terraformOptions)

	// Validate planned resources exist
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_container_group.main")
}

func TestContainerInstanceWithMultipleContainers(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                "test-multi-container",
			"location":            "East US",
			"resource_group_name": "test-rg",
			"containers": []map[string]interface{}{
				{
					"name":   "frontend",
					"image":  "nginx:latest",
					"cpu":    1,
					"memory": 1.5,
					"ports": []map[string]interface{}{
						{
							"port":     80,
							"protocol": "TCP",
						},
					},
				},
				{
					"name":   "backend",
					"image":  "node:16-alpine",
					"cpu":    0.5,
					"memory": 1,
					"ports": []map[string]interface{}{
						{
							"port":     3000,
							"protocol": "TCP",
						},
					},
					"environment_variables": map[string]string{
						"NODE_ENV": "production",
						"PORT":     "3000",
					},
				},
			},
			"ip_address_type": "Public",
			"exposed_ports": []map[string]interface{}{
				{
					"port":     80,
					"protocol": "TCP",
				},
				{
					"port":     3000,
					"protocol": "TCP",
				},
			},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
			},
		},
	}

	planStruct := terraform.InitAndPlanAndShow(t, terraformOptions)

	// Validate container group is planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_container_group.main")
}

func TestContainerInstanceWithPrivateNetworking(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                "test-private-container",
			"location":            "East US",
			"resource_group_name": "test-rg",
			"containers": []map[string]interface{}{
				{
					"name":   "private-app",
					"image":  "nginx:latest",
					"cpu":    1,
					"memory": 1.5,
				},
			},
			"ip_address_type": "Private",
			"subnet_id":       "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet",
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
			},
		},
	}

	planStruct := terraform.InitAndPlanAndShow(t, terraformOptions)

	// Validate container group is planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_container_group.main")
}

func TestContainerInstanceWithMonitoring(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                "test-monitored-container",
			"location":            "East US",
			"resource_group_name": "test-rg",
			"containers": []map[string]interface{}{
				{
					"name":   "monitored-app",
					"image":  "nginx:latest",
					"cpu":    1,
					"memory": 1.5,
				},
			},
			"enable_monitoring":       true,
			"action_group_id":         "/subscriptions/test/resourceGroups/test/providers/microsoft.insights/actionGroups/test",
			"cpu_alert_threshold":     80,
			"memory_alert_threshold":  85,
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
			},
		},
	}

	planStruct := terraform.InitAndPlanAndShow(t, terraformOptions)

	// Validate container group is planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_container_group.main")

	// Validate monitoring resources are planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_log_analytics_workspace.container_logs")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_monitor_metric_alert.container_cpu")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_monitor_metric_alert.container_memory")
}

func TestContainerInstanceWithVolumes(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                "test-container-volumes",
			"location":            "East US",
			"resource_group_name": "test-rg",
			"containers": []map[string]interface{}{
				{
					"name":   "app-with-storage",
					"image":  "nginx:latest",
					"cpu":    1,
					"memory": 1.5,
					"volume_mounts": []map[string]interface{}{
						{
							"name":       "data-volume",
							"mount_path": "/app/data",
							"read_only":  false,
						},
					},
				},
			},
			"volumes": []map[string]interface{}{
				{
					"name":                 "data-volume",
					"storage_account_name": "teststorageaccount",
					"storage_account_key":  "test-key",
					"share_name":          "test-share",
				},
			},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
			},
		},
	}

	planStruct := terraform.InitAndPlanAndShow(t, terraformOptions)

	// Validate container group is planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_container_group.main")
}

func TestContainerInstanceNamingConvention(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                   "test-app",
			"location":               "East US",
			"resource_group_name":    "test-rg",
			"use_naming_convention":  true,
			"environment":            "dev",
			"location_short":         "eus",
			"containers": []map[string]interface{}{
				{
					"name":   "test-container",
					"image":  "nginx:latest",
					"cpu":    1,
					"memory": 1.5,
				},
			},
			"common_tags": map[string]string{
				"Environment": "dev",
				"Project":     "terratest",
			},
		},
	}

	planStruct := terraform.InitAndPlanAndShow(t, terraformOptions)

	// Validate container group is planned with naming convention
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_container_group.main")

	// Extract planned values to verify naming convention
	plannedValues := terraform.GetPlannedValues(t, planStruct)
	containerGroup := plannedValues.RootModule.Resources["azurerm_container_group.main"]

	// Verify naming convention is applied: aci-name-environment-location_short
	expectedName := "aci-test-app-dev-eus"
	actualName := containerGroup.AttributeValues["name"].(string)
	assert.Equal(t, expectedName, actualName, "Container group name should follow naming convention")
}

func TestContainerInstanceWithHealthChecks(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                "test-health-checks",
			"location":            "East US",
			"resource_group_name": "test-rg",
			"containers": []map[string]interface{}{
				{
					"name":   "health-checked-app",
					"image":  "nginx:latest",
					"cpu":    1,
					"memory": 1.5,
					"ports": []map[string]interface{}{
						{
							"port":     80,
							"protocol": "TCP",
						},
					},
					"liveness_probe": map[string]interface{}{
						"http_get": []map[string]interface{}{
							{
								"path": "/health",
								"port": 80,
							},
						},
						"initial_delay_seconds": 30,
						"period_seconds":       10,
						"failure_threshold":    3,
					},
					"readiness_probe": map[string]interface{}{
						"http_get": []map[string]interface{}{
							{
								"path": "/ready",
								"port": 80,
							},
						},
						"initial_delay_seconds": 5,
						"period_seconds":       5,
						"failure_threshold":    3,
					},
				},
			},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
			},
		},
	}

	planStruct := terraform.InitAndPlanAndShow(t, terraformOptions)

	// Validate container group is planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_container_group.main")
}

func TestContainerInstanceVariableValidation(t *testing.T) {
	testCases := []struct {
		name        string
		vars        map[string]interface{}
		expectError bool
	}{
		{
			name: "Valid basic configuration",
			vars: map[string]interface{}{
				"name":                "valid-container",
				"location":            "East US",
				"resource_group_name": "valid-rg",
				"containers": []map[string]interface{}{
					{
						"name":   "valid-app",
						"image":  "nginx:latest",
						"cpu":    1,
						"memory": 1.5,
					},
				},
				"common_tags": map[string]string{
					"Environment": "test",
					"Project":     "terratest",
				},
			},
			expectError: false,
		},
		{
			name: "Invalid container name",
			vars: map[string]interface{}{
				"name":                "invalid..container",
				"location":            "East US",
				"resource_group_name": "valid-rg",
				"containers": []map[string]interface{}{
					{
						"name":   "valid-app",
						"image":  "nginx:latest",
						"cpu":    1,
						"memory": 1.5,
					},
				},
				"common_tags": map[string]string{
					"Environment": "test",
					"Project":     "terratest",
				},
			},
			expectError: true,
		},
		{
			name: "Invalid location",
			vars: map[string]interface{}{
				"name":                "valid-container",
				"location":            "Invalid Location",
				"resource_group_name": "valid-rg",
				"containers": []map[string]interface{}{
					{
						"name":   "valid-app",
						"image":  "nginx:latest",
						"cpu":    1,
						"memory": 1.5,
					},
				},
				"common_tags": map[string]string{
					"Environment": "test",
					"Project":     "terratest",
				},
			},
			expectError: true,
		},
		{
			name: "Missing required tags",
			vars: map[string]interface{}{
				"name":                "valid-container",
				"location":            "East US",
				"resource_group_name": "valid-rg",
				"containers": []map[string]interface{}{
					{
						"name":   "valid-app",
						"image":  "nginx:latest",
						"cpu":    1,
						"memory": 1.5,
					},
				},
				"common_tags": map[string]string{
					"Owner": "test",
				},
			},
			expectError: true,
		},
		{
			name: "Empty containers list",
			vars: map[string]interface{}{
				"name":                "valid-container",
				"location":            "East US",
				"resource_group_name": "valid-rg",
				"containers":          []map[string]interface{}{},
				"common_tags": map[string]string{
					"Environment": "test",
					"Project":     "terratest",
				},
			},
			expectError: true,
		},
		{
			name: "Invalid CPU allocation",
			vars: map[string]interface{}{
				"name":                "valid-container",
				"location":            "East US",
				"resource_group_name": "valid-rg",
				"containers": []map[string]interface{}{
					{
						"name":   "valid-app",
						"image":  "nginx:latest",
						"cpu":    5, // Invalid: > 4
						"memory": 1.5,
					},
				},
				"common_tags": map[string]string{
					"Environment": "test",
					"Project":     "terratest",
				},
			},
			expectError: true,
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			terraformOptions := &terraform.Options{
				TerraformDir: "../../",
				Vars:         tc.vars,
			}

			if tc.expectError {
				_, err := terraform.InitAndPlanE(t, terraformOptions)
				assert.Error(t, err, "Expected validation error for %s", tc.name)
			} else {
				terraform.InitAndPlan(t, terraformOptions)
			}
		})
	}
}