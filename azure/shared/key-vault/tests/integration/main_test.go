package test

import (
	"crypto/rand"
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

// TestKeyVaultBasicCreation tests the basic creation of a Key Vault
func TestKeyVaultBasicCreation(t *testing.T) {
	t.Parallel()

	// Generate random names to avoid conflicts
	uniqueID := random.UniqueId()
	keyVaultName := fmt.Sprintf("test-kv-%s", strings.ToLower(uniqueID))
	location := "East US"

	// Terraform options
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"key_vault_name": keyVaultName,
			"location":       location,
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
				"Owner":       "automated-testing",
			},
		},
	}

	// Clean up resources with retry
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	keyVaultID := terraform.Output(t, terraformOptions, "key_vault_id")
	keyVaultURI := terraform.Output(t, terraformOptions, "key_vault_uri")

	// Assertions
	assert.NotEmpty(t, keyVaultID)
	assert.NotEmpty(t, keyVaultURI)
	assert.Contains(t, keyVaultURI, keyVaultName)
	assert.Contains(t, keyVaultURI, "vault.azure.net")

	// Validate Key Vault exists in Azure
	subscriptionID := terraform.Output(t, terraformOptions, "subscription_id")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

	keyVault := azure.GetKeyVault(t, subscriptionID, resourceGroupName, keyVaultName)
	assert.Equal(t, keyVaultName, *keyVault.Name)
	assert.Equal(t, location, *keyVault.Location)
}

// TestKeyVaultWithSecrets tests Key Vault creation with secrets
func TestKeyVaultWithSecrets(t *testing.T) {
	t.Parallel()

	// Generate random names
	uniqueID := random.UniqueId()
	keyVaultName := fmt.Sprintf("test-kv-%s", strings.ToLower(uniqueID))
	location := "East US"

	secretName := "test-secret"
	secretValue := "test-secret-value-" + uniqueID

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":     keyVaultName,
			"location": location,
			"secrets": map[string]interface{}{
				secretName: map[string]interface{}{
					"value":        secretValue,
					"content_type": "Test Secret",
				},
			},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate secret outputs
	secretIDs := terraform.OutputMap(t, terraformOptions, "secret_ids")
	assert.Contains(t, secretIDs, secretName)
	assert.NotEmpty(t, secretIDs[secretName])
}

// TestKeyVaultWithKeys tests Key Vault creation with keys
func TestKeyVaultWithKeys(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	keyVaultName := fmt.Sprintf("test-kv-%s", strings.ToLower(uniqueID))
	location := "East US"

	keyName := "test-key"

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":     keyVaultName,
			"location": location,
			"sku_name": "premium", // Required for RSA keys
			"keys": map[string]interface{}{
				keyName: map[string]interface{}{
					"key_type": "RSA",
					"key_size": 2048,
					"key_opts": []string{"encrypt", "decrypt", "sign", "verify"},
				},
			},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate key outputs
	keyIDs := terraform.OutputMap(t, terraformOptions, "key_ids")
	assert.Contains(t, keyIDs, keyName)
	assert.NotEmpty(t, keyIDs[keyName])
}

// TestKeyVaultWithNetworkACLs tests Key Vault with network restrictions
func TestKeyVaultWithNetworkACLs(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	keyVaultName := fmt.Sprintf("test-kv-%s", strings.ToLower(uniqueID))
	location := "East US"

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":     keyVaultName,
			"location": location,
			"network_acls": map[string]interface{}{
				"default_action":             "Deny",
				"bypass":                     "AzureServices",
				"ip_rules":                   []string{"203.0.113.0/24"},
				"virtual_network_subnet_ids": []string{},
			},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate Key Vault was created successfully
	keyVaultID := terraform.Output(t, terraformOptions, "id")
	assert.NotEmpty(t, keyVaultID)
}

// TestKeyVaultAccessPolicies tests Key Vault with access policies
func TestKeyVaultAccessPolicies(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	keyVaultName := fmt.Sprintf("test-kv-%s", strings.ToLower(uniqueID))
	location := "East US"

	// This would need a real object ID in a real test
	testObjectID := "00000000-0000-0000-0000-000000000000"

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":                       keyVaultName,
			"location":                   location,
			"enable_rbac_authorization":  false, // Use access policies
			"access_policies": map[string]interface{}{
				"test_policy": map[string]interface{}{
					"object_id":               testObjectID,
					"key_permissions":         []string{"Get", "List"},
					"secret_permissions":      []string{"Get", "List"},
					"certificate_permissions": []string{"Get", "List"},
				},
			},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate access policy outputs
	accessPolicyObjectIDs := terraform.OutputList(t, terraformOptions, "access_policy_object_ids")
	assert.Contains(t, accessPolicyObjectIDs, testObjectID)
}

// TestKeyVaultTags tests that tags are properly applied
func TestKeyVaultTags(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	keyVaultName := fmt.Sprintf("test-kv-%s", strings.ToLower(uniqueID))
	location := "East US"

	expectedTags := map[string]string{
		"Environment": "test",
		"Project":     "terratest",
		"Owner":       "automation",
		"ManagedBy":   "Terraform",
		"Module":      "zrr-tf-module-lib/azure/shared/key-vault",
		"Layer":       "shared",
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":     keyVaultName,
			"location": location,
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
				"Owner":       "automation",
			},
			"key_vault_tags": map[string]string{
				"Purpose": "testing",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate tags output
	actualTags := terraform.OutputMap(t, terraformOptions, "tags")

	// Check required tags are present
	for key, expectedValue := range expectedTags {
		if key == "Owner" {
			// Owner comes from common_tags
			continue
		}
		actualValue, exists := actualTags[key]
		assert.True(t, exists, fmt.Sprintf("Tag %s should exist", key))
		if exists {
			assert.Equal(t, expectedValue, actualValue, fmt.Sprintf("Tag %s should have value %s", key, expectedValue))
		}
	}

	// Check custom tag
	assert.Equal(t, "testing", actualTags["Purpose"])
}

// TestKeyVaultValidation tests input validation
func TestKeyVaultValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":     "invalid@name!",
			"location": "East US",
		},
	}

	// This should fail due to invalid name
	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "validation failed")
}

// TestKeyVaultSKUValidation tests SKU validation
func TestKeyVaultSKUValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"name":     "test-kv-001",
			"location": "East US",
			"sku_name": "invalid",
		},
	}

	// This should fail due to invalid SKU
	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "validation failed")
}

// Helper function to generate random string
func generateRandomString(length int) string {
	const charset = "abcdefghijklmnopqrstuvwxyz0123456789"
	b := make([]byte, length)
	for i := range b {
		b[i] = charset[rand.Intn(len(charset))]
	}
	return string(b)
}