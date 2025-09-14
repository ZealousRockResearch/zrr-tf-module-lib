package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestNetworkSecurityGroupCreation(t *testing.T) {
	t.Parallel()

	// Generate random names to avoid conflicts
	uniqueID := random.UniqueId()
	resourceGroupName := "test-nsg-" + uniqueID
	nsgName := "test-nsg-" + uniqueID
	location := "East US"

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"location":            location,
			"resource_group_name": resourceGroupName,
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
				"Owner":       "integration-test",
			},
		},
	}

	// Clean up resources with retry
	defer terraform.Destroy(t, terraformOptions)

	// Initialize and apply Terraform configuration
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	nsgID := terraform.Output(t, terraformOptions, "id")
	assert.NotEmpty(t, nsgID, "NSG ID should not be empty")

	nsgName = terraform.Output(t, terraformOptions, "name")
	assert.Contains(t, nsgName, "example-nsg", "NSG name should contain 'example-nsg'")

	nsgLocation := terraform.Output(t, terraformOptions, "location")
	assert.Equal(t, location, nsgLocation, "NSG location should match input")

	// Validate security rules were created
	securityRulesCount := terraform.Output(t, terraformOptions, "effective_security_rules_count")
	assert.Equal(t, "2", securityRulesCount, "Should have created 2 security rules")

	hasInboundRules := terraform.Output(t, terraformOptions, "has_inbound_rules")
	assert.Equal(t, "true", hasInboundRules, "Should have inbound rules")

	inboundRulesCount := terraform.Output(t, terraformOptions, "inbound_rules_count")
	assert.Equal(t, "2", inboundRulesCount, "Should have 2 inbound rules")
}

func TestNetworkSecurityGroupWithResourceGroup(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	resourceGroupName := "test-nsg-rg-" + uniqueID
	location := "West US"

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"location":              location,
			"resource_group_name":   resourceGroupName,
			"create_resource_group": true,
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest-rg",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate resource group was created
	resourceGroupID := terraform.Output(t, terraformOptions, "resource_group_id")
	assert.NotEmpty(t, resourceGroupID, "Resource group ID should not be empty")

	// Validate NSG was created in the new resource group
	nsgResourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	assert.Equal(t, resourceGroupName, nsgResourceGroupName, "NSG should be in the created resource group")
}

func TestAdvancedNetworkSecurityGroup(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	resourceGroupName := "test-advanced-nsg-" + uniqueID
	location := "Central US"

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/advanced",

		Vars: map[string]interface{}{
			"location":            location,
			"resource_group_name": resourceGroupName,
			"management_subnets":  []string{"10.0.1.0/24", "10.0.2.0/24"},
			"application_subnets": []string{"10.0.10.0/24", "10.0.11.0/24"},
			"enable_flow_logs":    false, // Disable flow logs for test
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest-advanced",
				"Owner":       "security-team",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate advanced configuration
	securityRulesCount := terraform.Output(t, terraformOptions, "effective_security_rules_count")
	assert.Equal(t, "6", securityRulesCount, "Should have created 6 security rules")

	hasInboundRules := terraform.Output(t, terraformOptions, "has_inbound_rules")
	assert.Equal(t, "true", hasInboundRules, "Should have inbound rules")

	hasOutboundRules := terraform.Output(t, terraformOptions, "has_outbound_rules")
	assert.Equal(t, "true", hasOutboundRules, "Should have outbound rules")

	inboundRulesCount := terraform.Output(t, terraformOptions, "inbound_rules_count")
	assert.Equal(t, "4", inboundRulesCount, "Should have 4 inbound rules")

	outboundRulesCount := terraform.Output(t, terraformOptions, "outbound_rules_count")
	assert.Equal(t, "2", outboundRulesCount, "Should have 2 outbound rules")
}

func TestNetworkSecurityGroupValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":     "test-nsg-validation",
			"location": "East US",
			"security_rules": []map[string]interface{}{
				{
					"name":                       "test-rule",
					"priority":                   1000,
					"direction":                  "Inbound",
					"access":                     "Allow",
					"protocol":                   "Tcp",
					"source_port_range":          "*",
					"destination_port_range":     "80",
					"source_address_prefix":      "*",
					"destination_address_prefix": "*",
					"description":                "Test rule for validation",
				},
			},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "validation",
			},
		},
	}

	// This should pass validation
	terraform.InitAndPlan(t, terraformOptions)
}

func TestNetworkSecurityGroupAzureIntegration(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	resourceGroupName := "test-nsg-integration-" + uniqueID
	nsgName := "test-nsg-integration-" + uniqueID
	location := "East US"
	subscriptionID := "" // Set this if running against real Azure

	// Skip if no subscription ID is provided
	if subscriptionID == "" {
		t.Skip("Skipping Azure integration test - no subscription ID provided")
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"location":            location,
			"resource_group_name": resourceGroupName,
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "azure-integration",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Get the actual NSG name from Terraform output
	actualNSGName := terraform.Output(t, terraformOptions, "name")

	// Validate using Azure Go SDK
	nsgExists := azure.NetworkSecurityGroupExists(t, actualNSGName, resourceGroupName, subscriptionID)
	require.True(t, nsgExists, "NSG should exist in Azure")

	// Validate NSG properties
	nsg := azure.GetNetworkSecurityGroup(t, actualNSGName, resourceGroupName, subscriptionID)
	assert.Equal(t, location, *nsg.Location, "NSG location should match")
	assert.NotEmpty(t, nsg.SecurityRules, "NSG should have security rules")
	assert.Len(t, *nsg.SecurityRules, 2, "NSG should have exactly 2 security rules")
}

func TestNetworkSecurityGroupPerformance(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	resourceGroupName := "test-perf-nsg-" + uniqueID

	// Test with many security rules to validate performance
	securityRules := make([]map[string]interface{}, 20)
	for i := 0; i < 20; i++ {
		securityRules[i] = map[string]interface{}{
			"name":                       fmt.Sprintf("rule-%d", i+1),
			"priority":                   1000 + i,
			"direction":                  "Inbound",
			"access":                     "Allow",
			"protocol":                   "Tcp",
			"source_port_range":          "*",
			"destination_port_range":     fmt.Sprintf("%d", 8000+i),
			"source_address_prefix":      "*",
			"destination_address_prefix": "*",
			"description":                fmt.Sprintf("Performance test rule %d", i+1),
		}
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                "perf-test-nsg",
			"location":            "East US",
			"resource_group_name": resourceGroupName,
			"security_rules":      securityRules,
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "performance",
			},
		},

		// Set longer timeout for performance test
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}

	startTime := time.Now()
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(startTime)

	// Validate that deployment completed in reasonable time (adjust as needed)
	assert.Less(t, duration.Minutes(), 10.0, "Deployment should complete within 10 minutes")

	// Validate all rules were created
	rulesCount := terraform.Output(t, terraformOptions, "effective_security_rules_count")
	assert.Equal(t, "20", rulesCount, "Should have created 20 security rules")
}