package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestDNSZoneUnitValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                "test.example.com",
			"resource_group_name": "test-rg",
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
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_dns_zone.main")
}

func TestDNSZoneWithRecords(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                "test-records.example.com",
			"resource_group_name": "test-rg",
			"a_records": []map[string]interface{}{
				{
					"name":    "www",
					"ttl":     3600,
					"records": []string{"1.2.3.4"},
				},
			},
			"cname_records": []map[string]interface{}{
				{
					"name":   "blog",
					"ttl":    3600,
					"record": "www.test-records.example.com",
				},
			},
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
			},
		},
	}

	planStruct := terraform.InitAndPlanAndShow(t, terraformOptions)

	// Validate DNS zone is planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_dns_zone.main")

	// Validate A record is planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_dns_a_record.a_records")

	// Validate CNAME record is planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_dns_cname_record.cname_records")
}

func TestDNSZoneWithDelegation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                "subdomain.example.com",
			"resource_group_name": "test-rg",
			"enable_delegation":   true,
			"parent_zone_name":    "example.com",
			"verify_delegation":   false, // Skip verification in unit tests
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
			},
		},
	}

	planStruct := terraform.InitAndPlanAndShow(t, terraformOptions)

	// Validate DNS zone is planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_dns_zone.main")

	// Validate delegation NS record is planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_dns_ns_record.delegation")
}

func TestDNSZoneWithMonitoring(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                         "monitored.example.com",
			"resource_group_name":          "test-rg",
			"enable_monitoring":            true,
			"action_group_id":              "/subscriptions/test/resourceGroups/test/providers/microsoft.insights/actionGroups/test",
			"query_volume_threshold":       5000,
			"record_set_count_threshold":   1000,
			"common_tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
			},
		},
	}

	planStruct := terraform.InitAndPlanAndShow(t, terraformOptions)

	// Validate DNS zone is planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_dns_zone.main")

	// Validate monitoring alerts are planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_monitor_metric_alert.dns_query_volume")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_monitor_metric_alert.dns_record_set_count")
}

func TestDNSZoneNamingConvention(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                   "test-app",
			"resource_group_name":    "test-rg",
			"use_naming_convention":  true,
			"environment":            "dev",
			"domain_suffix":          "internal",
			"common_tags": map[string]string{
				"Environment": "dev",
				"Project":     "terratest",
			},
		},
	}

	planStruct := terraform.InitAndPlanAndShow(t, terraformOptions)

	// Validate DNS zone is planned with naming convention
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_dns_zone.main")

	// Extract planned values to verify naming convention
	plannedValues := terraform.GetPlannedValues(t, planStruct)
	dnsZone := plannedValues.RootModule.Resources["azurerm_dns_zone.main"]

	// Verify naming convention is applied: name.environment.domain_suffix
	expectedName := "test-app.dev.internal"
	actualName := dnsZone.AttributeValues["name"].(string)
	assert.Equal(t, expectedName, actualName, "DNS zone name should follow naming convention")
}

func TestDNSZoneComplexRecords(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                "complex.example.com",
			"resource_group_name": "test-rg",

			// Multiple record types
			"a_records": []map[string]interface{}{
				{
					"name":    "www",
					"ttl":     3600,
					"records": []string{"1.2.3.4", "5.6.7.8"},
				},
			},
			"aaaa_records": []map[string]interface{}{
				{
					"name":    "www",
					"ttl":     3600,
					"records": []string{"2001:db8::1"},
				},
			},
			"mx_records": []map[string]interface{}{
				{
					"name": "@",
					"ttl":  3600,
					"records": []map[string]interface{}{
						{
							"preference": 10,
							"exchange":   "mail.complex.example.com",
						},
					},
				},
			},
			"txt_records": []map[string]interface{}{
				{
					"name":    "@",
					"ttl":     3600,
					"records": []string{"v=spf1 include:_spf.google.com ~all"},
				},
			},
			"srv_records": []map[string]interface{}{
				{
					"name": "_sip._tcp",
					"ttl":  3600,
					"records": []map[string]interface{}{
						{
							"priority": 10,
							"weight":   5,
							"port":     5060,
							"target":   "sip.complex.example.com",
						},
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

	// Validate all record types are planned
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_dns_zone.main")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_dns_a_record.a_records")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_dns_aaaa_record.aaaa_records")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_dns_mx_record.mx_records")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_dns_txt_record.txt_records")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_dns_srv_record.srv_records")
}

func TestDNSZoneVariableValidation(t *testing.T) {
	testCases := []struct {
		name        string
		vars        map[string]interface{}
		expectError bool
	}{
		{
			name: "Valid basic configuration",
			vars: map[string]interface{}{
				"name":                "valid.example.com",
				"resource_group_name": "valid-rg",
				"common_tags": map[string]string{
					"Environment": "test",
					"Project":     "terratest",
				},
			},
			expectError: false,
		},
		{
			name: "Invalid DNS zone name",
			vars: map[string]interface{}{
				"name":                "invalid..example.com",
				"resource_group_name": "valid-rg",
				"common_tags": map[string]string{
					"Environment": "test",
					"Project":     "terratest",
				},
			},
			expectError: true,
		},
		{
			name: "Invalid resource group name",
			vars: map[string]interface{}{
				"name":                "valid.example.com",
				"resource_group_name": "",
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
				"name":                "valid.example.com",
				"resource_group_name": "valid-rg",
				"common_tags": map[string]string{
					"Owner": "test",
				},
			},
			expectError: true,
		},
		{
			name: "Invalid TTL in A record",
			vars: map[string]interface{}{
				"name":                "valid.example.com",
				"resource_group_name": "valid-rg",
				"a_records": []map[string]interface{}{
					{
						"name":    "www",
						"ttl":     0, // Invalid TTL
						"records": []string{"1.2.3.4"},
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