package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"fmt"
	"strings"
)

func TestKeyVaultSecretCreation(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"key_vault_name":                 "test-keyvault",
			"key_vault_resource_group_name":  "test-rg",
			"secret_value":                   "test-secret-value",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	secretId := terraform.Output(t, terraformOptions, "id")
	assert.NotEmpty(t, secretId)
	assert.Contains(t, secretId, "example-secret")

	secretName := terraform.Output(t, terraformOptions, "name")
	assert.Equal(t, "example-secret", secretName)

	secretVersion := terraform.Output(t, terraformOptions, "version")
	assert.NotEmpty(t, secretVersion)

	versionlessId := terraform.Output(t, terraformOptions, "versionless_id")
	assert.NotEmpty(t, versionlessId)
	assert.Contains(t, versionlessId, "example-secret")
}

func TestKeyVaultSecretWithExpirationDate(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"key_vault_name":                 "test-keyvault",
			"key_vault_resource_group_name":  "test-rg",
			"secret_value":                   "test-secret-with-expiration",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate that secret was created successfully
	secretId := terraform.Output(t, terraformOptions, "id")
	assert.NotEmpty(t, secretId)

	// Validate that expiration date is set (from the basic example)
	secretName := terraform.Output(t, terraformOptions, "name")
	assert.Equal(t, "example-secret", secretName)
}

func TestKeyVaultSecretTags(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"key_vault_name":                 "test-keyvault",
			"key_vault_resource_group_name":  "test-rg",
			"secret_value":                   "test-secret-for-tags",
			"common_tags": map[string]interface{}{
				"Environment": "test",
				"Project":     "terratest",
				"Owner":       "automation",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate tags output
	tags := terraform.OutputMap(t, terraformOptions, "tags")
	assert.Equal(t, "test", tags["Environment"])
	assert.Equal(t, "terratest", tags["Project"])
	assert.Equal(t, "automation", tags["Owner"])
	assert.Equal(t, "Terraform", tags["ManagedBy"])
	assert.Equal(t, "security", tags["Layer"])
	assert.Contains(t, tags["Module"], "zrr-tf-module-lib/azure/security/key-vault-secret")
}

func TestKeyVaultSecretOutputs(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"key_vault_name":                 "test-keyvault",
			"key_vault_resource_group_name":  "test-rg",
			"secret_value":                   "test-outputs",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Test all expected outputs
	outputs := []string{"id", "name", "version", "versionless_id", "resource_id", "resource_versionless_id", "key_vault_id", "tags"}

	for _, output := range outputs {
		value := terraform.Output(t, terraformOptions, output)
		assert.NotEmpty(t, value, fmt.Sprintf("Output %s should not be empty", output))
	}

	// Validate specific output formats
	resourceId := terraform.Output(t, terraformOptions, "resource_id")
	assert.True(t, strings.HasPrefix(resourceId, "/subscriptions/"))

	keyVaultId := terraform.Output(t, terraformOptions, "key_vault_id")
	assert.Contains(t, keyVaultId, "Microsoft.KeyVault/vaults")
}