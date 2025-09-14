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

func TestVNetCreation(t *testing.T) {
	t.Parallel()

	// Generate a random suffix for unique resource names
	randomSuffix := strings.ToLower(random.UniqueId())
	resourceGroupName := fmt.Sprintf("rg-test-vnet-%s", randomSuffix)
	
	// Create resource group for testing
	subscriptionID := azure.GetSubscriptionIDFromCLI(t)
	azure.CreateResourceGroup(t, resourceGroupName, "eastus", subscriptionID)
	defer azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",
		
		Vars: map[string]interface{}{
			"resource_group_name": resourceGroupName,
			"environment":         "test",
			"location_short":      "eus",
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

	// Validate VNet outputs
	vnetID := terraform.Output(t, terraformOptions, "vnet_id")
	assert.NotEmpty(t, vnetID)
	assert.Contains(t, vnetID, "vnet-test-example-vnet-eus")
	
	vnetName := terraform.Output(t, terraformOptions, "vnet_name")
	assert.Contains(t, vnetName, "example-vnet")
	
	vnetAddressSpace := terraform.OutputList(t, terraformOptions, "vnet_address_space")
	assert.Equal(t, []string{"10.0.0.0/16"}, vnetAddressSpace)
	
	totalSubnets := terraform.Output(t, terraformOptions, "total_subnets")
	assert.Equal(t, "3", totalSubnets)
	
	// Validate subnet outputs
	subnetIDs := terraform.OutputMap(t, terraformOptions, "subnet_ids")
	assert.Len(t, subnetIDs, 3)
	assert.Contains(t, subnetIDs, "subnet-web")
	assert.Contains(t, subnetIDs, "subnet-app")
	assert.Contains(t, subnetIDs, "subnet-data")
	
	// Validate NSG outputs
	nsgIDs := terraform.OutputMap(t, terraformOptions, "nsg_ids")
	assert.Len(t, nsgIDs, 3)
}

func TestVNetWithCustomConfiguration(t *testing.T) {
	t.Parallel()

	randomSuffix := strings.ToLower(random.UniqueId())
	resourceGroupName := fmt.Sprintf("rg-test-custom-%s", randomSuffix)
	
	subscriptionID := azure.GetSubscriptionIDFromCLI(t)
	azure.CreateResourceGroup(t, resourceGroupName, "eastus", subscriptionID)
	defer azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		
		Vars: map[string]interface{}{
			"name":                "custom-vnet",
			"resource_group_name": resourceGroupName,
			"address_space":       []string{"192.168.0.0/16"},
			"environment":         "test",
			"location_short":      "eus",
			"dns_servers":         []string{"8.8.8.8", "1.1.1.1"},
			"subnets": []map[string]interface{}{
				{
					"name":             "subnet-custom",
					"address_prefixes": []string{"192.168.1.0/24"},
					"service_endpoints": []string{"Microsoft.Storage"},
					"create_nsg":       true,
				},
			},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest-custom",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate custom configuration
	vnetAddressSpace := terraform.OutputList(t, terraformOptions, "vnet_address_space")
	assert.Equal(t, []string{"192.168.0.0/16"}, vnetAddressSpace)
	
	vnetDNSServers := terraform.OutputList(t, terraformOptions, "vnet_dns_servers")
	assert.Equal(t, []string{"8.8.8.8", "1.1.1.1"}, vnetDNSServers)
	
	totalSubnets := terraform.Output(t, terraformOptions, "total_subnets")
	assert.Equal(t, "1", totalSubnets)
}

func TestVNetAutoCalculateSubnets(t *testing.T) {
	t.Parallel()

	randomSuffix := strings.ToLower(random.UniqueId())
	resourceGroupName := fmt.Sprintf("rg-test-auto-%s", randomSuffix)
	
	subscriptionID := azure.GetSubscriptionIDFromCLI(t)
	azure.CreateResourceGroup(t, resourceGroupName, "eastus", subscriptionID)
	defer azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		
		Vars: map[string]interface{}{
			"name":                   "auto-calc-vnet",
			"resource_group_name":    resourceGroupName,
			"address_space":          []string{"172.16.0.0/16"},
			"auto_calculate_subnets": true,
			"subnets": []map[string]interface{}{
				{
					"name":    "subnet-1",
					"newbits": 8,
				},
				{
					"name":    "subnet-2",
					"newbits": 8,
				},
			},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest-auto",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate auto-calculated subnets
	subnetAddresses := terraform.OutputMap(t, terraformOptions, "subnet_address_prefixes")
	assert.Len(t, subnetAddresses, 2)
	
	// Verify that subnets were auto-calculated from the VNet address space
	for _, addresses := range subnetAddresses {
		// Each subnet should be a /24 within 172.16.0.0/16
		assert.Contains(t, addresses, "172.16.")
		assert.Contains(t, addresses, "/24")
	}
}

func TestVNetValidation(t *testing.T) {
	t.Parallel()

	// Test invalid VNet name
	t.Run("InvalidVNetName", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../../",
			
			Vars: map[string]interface{}{
				"name":                "invalid@vnet!",
				"resource_group_name": "test-rg",
				"address_space":       []string{"10.0.0.0/16"},
				"common_tags": map[string]string{
					"Environment": "test",
					"Project":     "terratest",
				},
			},
		}

		_, err := terraform.InitAndPlanE(t, terraformOptions)
		require.Error(t, err)
		assert.Contains(t, err.Error(), "Name must be 1-64 characters")
	})

	// Test invalid address space
	t.Run("InvalidAddressSpace", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../../",
			
			Vars: map[string]interface{}{
				"name":                "test-vnet",
				"resource_group_name": "test-rg",
				"address_space":       []string{"invalid-cidr"},
				"common_tags": map[string]string{
					"Environment": "test",
					"Project":     "terratest",
				},
			},
		}

		_, err := terraform.InitAndPlanE(t, terraformOptions)
		require.Error(t, err)
		assert.Contains(t, err.Error(), "must be valid CIDR blocks")
	})

	// Test missing required tags
	t.Run("MissingRequiredTags", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../../",
			
			Vars: map[string]interface{}{
				"name":                "test-vnet",
				"resource_group_name": "test-rg",
				"address_space":       []string{"10.0.0.0/16"},
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

func TestVNetWithPeering(t *testing.T) {
	t.Parallel()

	randomSuffix := strings.ToLower(random.UniqueId())
	resourceGroupName := fmt.Sprintf("rg-test-peering-%s", randomSuffix)
	
	subscriptionID := azure.GetSubscriptionIDFromCLI(t)
	azure.CreateResourceGroup(t, resourceGroupName, "eastus", subscriptionID)
	defer azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)

	// First create a VNet to peer with
	hubTerraformOptions := &terraform.Options{
		TerraformDir: "../../",
		
		Vars: map[string]interface{}{
			"name":                fmt.Sprintf("hub-vnet-%s", randomSuffix),
			"resource_group_name": resourceGroupName,
			"address_space":       []string{"10.0.0.0/16"},
			"subnets": []map[string]interface{}{
				{
					"name":             "hub-subnet",
					"address_prefixes": []string{"10.0.1.0/24"},
				},
			},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest-hub",
			},
		},
	}

	defer terraform.Destroy(t, hubTerraformOptions)
	terraform.InitAndApply(t, hubTerraformOptions)
	
	hubVNetID := terraform.Output(t, hubTerraformOptions, "vnet_id")

	// Now create spoke VNet with peering
	spokeTerraformOptions := &terraform.Options{
		TerraformDir: "../../",
		
		Vars: map[string]interface{}{
			"name":                fmt.Sprintf("spoke-vnet-%s", randomSuffix),
			"resource_group_name": resourceGroupName,
			"address_space":       []string{"10.1.0.0/16"},
			"subnets": []map[string]interface{}{
				{
					"name":             "spoke-subnet",
					"address_prefixes": []string{"10.1.1.0/24"},
				},
			},
			"vnet_peerings": map[string]interface{}{
				"spoke-to-hub": map[string]interface{}{
					"remote_vnet_id":              hubVNetID,
					"allow_virtual_network_access": true,
					"allow_forwarded_traffic":     false,
				},
			},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest-spoke",
			},
		},
	}

	defer terraform.Destroy(t, spokeTerraformOptions)
	terraform.InitAndApply(t, spokeTerraformOptions)

	// Validate peering
	peeringIDs := terraform.OutputMap(t, spokeTerraformOptions, "peering_ids")
	assert.Len(t, peeringIDs, 1)
	assert.Contains(t, peeringIDs, "spoke-to-hub")
	
	peeringStates := terraform.OutputMap(t, spokeTerraformOptions, "peering_states")
	assert.Equal(t, "Connected", peeringStates["spoke-to-hub"])
}

// Helper function to check if VNet exists
func vnetExists(t *testing.T, resourceGroupName string, vnetName string, subscriptionID string) bool {
	exists, err := azure.VirtualNetworkExistsE(vnetName, resourceGroupName, subscriptionID)
	require.NoError(t, err)
	return exists
}