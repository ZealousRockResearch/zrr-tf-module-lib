package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestContainerInstanceCreation(t *testing.T) {
	t.Parallel()

	// Generate a random suffix for unique resource names
	randomSuffix := strings.ToLower(random.UniqueId())
	containerName := fmt.Sprintf("test-container-%s", randomSuffix)
	resourceGroupName := fmt.Sprintf("test-container-rg-%s", randomSuffix)

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"container_name":      containerName,
			"resource_group_name": resourceGroupName,
			"dns_name_label":      fmt.Sprintf("test-container-%s", randomSuffix),
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
	containerGroupID := terraform.Output(t, terraformOptions, "container_group_id")
	assert.NotEmpty(t, containerGroupID)

	containerGroupName := terraform.Output(t, terraformOptions, "container_group_name")
	assert.Equal(t, containerName, containerGroupName)

	ipAddress := terraform.Output(t, terraformOptions, "ip_address")
	assert.NotEmpty(t, ipAddress)

	fqdn := terraform.Output(t, terraformOptions, "fqdn")
	assert.NotEmpty(t, fqdn)
	assert.Contains(t, fqdn, fmt.Sprintf("test-container-%s", randomSuffix))

	containerCount := terraform.Output(t, terraformOptions, "container_count")
	assert.Equal(t, "1", containerCount)

	totalCPU := terraform.Output(t, terraformOptions, "total_cpu_allocation")
	assert.Equal(t, "1", totalCPU)

	totalMemory := terraform.Output(t, terraformOptions, "total_memory_allocation")
	assert.Equal(t, "1.5", totalMemory)
}

func TestContainerInstanceWithMultipleContainers(t *testing.T) {
	t.Parallel()

	randomSuffix := strings.ToLower(random.UniqueId())
	containerName := fmt.Sprintf("multi-container-%s", randomSuffix)
	resourceGroupName := fmt.Sprintf("test-multi-rg-%s", randomSuffix)

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                containerName,
			"location":            "East US",
			"resource_group_name": resourceGroupName,
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
					"environment_variables": map[string]string{
						"NGINX_PORT": "80",
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
			"dns_name_label": fmt.Sprintf("multi-container-%s", randomSuffix),
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
				"TestID":      randomSuffix,
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate container group
	containerGroupID := terraform.Output(t, terraformOptions, "id")
	assert.NotEmpty(t, containerGroupID)

	containerGroupName := terraform.Output(t, terraformOptions, "name")
	assert.Equal(t, containerName, containerGroupName)

	// Validate multiple containers
	containerCount := terraform.Output(t, terraformOptions, "container_count")
	assert.Equal(t, "2", containerCount)

	primaryContainerName := terraform.Output(t, terraformOptions, "primary_container_name")
	assert.Equal(t, "frontend", primaryContainerName)

	// Validate resource allocation
	totalCPU := terraform.Output(t, terraformOptions, "total_cpu_allocation")
	assert.Equal(t, "1.5", totalCPU)

	totalMemory := terraform.Output(t, terraformOptions, "total_memory_allocation")
	assert.Equal(t, "2.5", totalMemory)

	// Validate IP and FQDN
	ipAddress := terraform.Output(t, terraformOptions, "ip_address")
	assert.NotEmpty(t, ipAddress)

	fqdn := terraform.Output(t, terraformOptions, "fqdn")
	assert.NotEmpty(t, fqdn)
}

func TestContainerInstanceWithMonitoring(t *testing.T) {
	t.Parallel()

	randomSuffix := strings.ToLower(random.UniqueId())
	containerName := fmt.Sprintf("monitored-container-%s", randomSuffix)
	resourceGroupName := fmt.Sprintf("test-monitoring-rg-%s", randomSuffix)

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                   containerName,
			"location":               "East US",
			"resource_group_name":    resourceGroupName,
			"enable_monitoring":      true,
			"cpu_alert_threshold":    75,
			"memory_alert_threshold": 80,
			"log_retention_days":     30,
			"containers": []map[string]interface{}{
				{
					"name":   "monitored-app",
					"image":  "nginx:latest",
					"cpu":    1,
					"memory": 1.5,
				},
			},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
				"TestID":      randomSuffix,
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate monitoring configuration
	monitoringEnabled := terraform.Output(t, terraformOptions, "monitoring_enabled")
	assert.Equal(t, "true", monitoringEnabled)

	logAnalyticsWorkspaceID := terraform.Output(t, terraformOptions, "log_analytics_workspace_id")
	assert.NotEmpty(t, logAnalyticsWorkspaceID)

	cpuAlertID := terraform.Output(t, terraformOptions, "cpu_alert_id")
	assert.NotEmpty(t, cpuAlertID)

	memoryAlertID := terraform.Output(t, terraformOptions, "memory_alert_id")
	assert.NotEmpty(t, memoryAlertID)

	// Validate alert thresholds
	alertThresholds := terraform.OutputMap(t, terraformOptions, "alert_thresholds")
	assert.Equal(t, "75", alertThresholds["cpu_threshold"])
	assert.Equal(t, "80", alertThresholds["memory_threshold"])
}

func TestContainerInstanceNamingConvention(t *testing.T) {
	t.Parallel()

	randomSuffix := strings.ToLower(random.UniqueId())
	baseName := fmt.Sprintf("test-%s", randomSuffix)
	resourceGroupName := fmt.Sprintf("test-naming-rg-%s", randomSuffix)
	environment := "dev"
	locationShort := "eus"

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                   baseName,
			"location":               "East US",
			"resource_group_name":    resourceGroupName,
			"use_naming_convention":  true,
			"environment":            environment,
			"location_short":         locationShort,
			"containers": []map[string]interface{}{
				{
					"name":   "test-container",
					"image":  "nginx:latest",
					"cpu":    1,
					"memory": 1.5,
				},
			},
			"common_tags": map[string]string{
				"Environment": environment,
				"Project":     "terratest",
				"TestID":      randomSuffix,
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate naming convention
	containerGroupName := terraform.Output(t, terraformOptions, "name")
	expectedName := fmt.Sprintf("aci-%s-%s-%s", baseName, environment, locationShort)
	assert.Equal(t, expectedName, containerGroupName)

	// Validate naming details
	nameDetails := terraform.OutputMap(t, terraformOptions, "container_name_details")
	assert.Equal(t, baseName, nameDetails["original_name"])
	assert.Equal(t, expectedName, nameDetails["final_name"])
	assert.Equal(t, environment, nameDetails["environment"])
	assert.Equal(t, locationShort, nameDetails["location_short"])
	assert.Equal(t, "true", nameDetails["naming_convention"])
}

func TestContainerInstanceWithVolumes(t *testing.T) {
	t.Parallel()

	randomSuffix := strings.ToLower(random.UniqueId())
	containerName := fmt.Sprintf("volume-container-%s", randomSuffix)
	resourceGroupName := fmt.Sprintf("test-volume-rg-%s", randomSuffix)

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                containerName,
			"location":            "East US",
			"resource_group_name": resourceGroupName,
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
						{
							"name":       "config-volume",
							"mount_path": "/app/config",
							"read_only":  true,
						},
					},
				},
			},
			"volumes": []map[string]interface{}{
				{
					"name":      "data-volume",
					"empty_dir": true,
				},
				{
					"name":      "config-volume",
					"empty_dir": true,
				},
			},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
				"TestID":      randomSuffix,
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate volume configuration
	volumeCount := terraform.Output(t, terraformOptions, "volume_count")
	assert.Equal(t, "2", volumeCount)

	volumesConfigured := terraform.OutputMapOfObjects(t, terraformOptions, "volumes_configured")
	require.Contains(t, volumesConfigured, "data-volume")
	require.Contains(t, volumesConfigured, "config-volume")

	dataVolume := volumesConfigured["data-volume"].(map[string]interface{})
	assert.Equal(t, true, dataVolume["empty_dir"])

	configVolume := volumesConfigured["config-volume"].(map[string]interface{})
	assert.Equal(t, true, configVolume["empty_dir"])
}

func TestContainerInstanceWithHealthChecks(t *testing.T) {
	t.Parallel()

	randomSuffix := strings.ToLower(random.UniqueId())
	containerName := fmt.Sprintf("health-container-%s", randomSuffix)
	resourceGroupName := fmt.Sprintf("test-health-rg-%s", randomSuffix)

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                containerName,
			"location":            "East US",
			"resource_group_name": resourceGroupName,
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
								"path": "/",
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
								"path": "/",
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
				"TestID":      randomSuffix,
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate health check configuration
	livenessProbes := terraform.Output(t, terraformOptions, "containers_with_liveness_probes")
	assert.Equal(t, "1", livenessProbes)

	readinessProbes := terraform.Output(t, terraformOptions, "containers_with_readiness_probes")
	assert.Equal(t, "1", readinessProbes)
}

func TestContainerInstanceTagging(t *testing.T) {
	t.Parallel()

	randomSuffix := strings.ToLower(random.UniqueId())
	containerName := fmt.Sprintf("tagging-container-%s", randomSuffix)
	resourceGroupName := fmt.Sprintf("test-tagging-rg-%s", randomSuffix)

	commonTags := map[string]string{
		"Environment": "test",
		"Project":     "terratest",
		"Owner":       "platform-team",
		"TestID":      randomSuffix,
	}

	containerInstanceTags := map[string]string{
		"Application": "test-app",
		"Purpose":     "testing",
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                     containerName,
			"location":                 "East US",
			"resource_group_name":      resourceGroupName,
			"common_tags":              commonTags,
			"container_instance_tags":  containerInstanceTags,
			"containers": []map[string]interface{}{
				{
					"name":   "tagged-app",
					"image":  "nginx:latest",
					"cpu":    1,
					"memory": 1.5,
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate tags are applied
	appliedTags := terraform.OutputMap(t, terraformOptions, "tags")

	// Check common tags
	for key, value := range commonTags {
		assert.Equal(t, value, appliedTags[key])
	}

	// Check container instance specific tags
	for key, value := range containerInstanceTags {
		assert.Equal(t, value, appliedTags[key])
	}

	// Check automatic tags
	assert.Equal(t, "Terraform", appliedTags["ManagedBy"])
	assert.Equal(t, "zrr-tf-module-lib/azure/application/container-instance", appliedTags["Module"])
	assert.Equal(t, "application", appliedTags["Layer"])
}