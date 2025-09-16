package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestMySQLFirewallRuleCreation(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"mysql_server_name":               "test-mysql-server",
			"mysql_server_resource_group_name": "test-rg",
			"firewall_rules": []map[string]interface{}{
				{
					"name":             "TestOfficeAccess",
					"start_ip_address": "203.0.113.0",
					"end_ip_address":   "203.0.113.255",
				},
			},
			"allow_azure_services": true,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	firewallRuleNames := terraform.OutputList(t, terraformOptions, "firewall_rule_names")
	assert.NotEmpty(t, firewallRuleNames)
	assert.Contains(t, firewallRuleNames, "TestOfficeAccess")

	firewallRulesCount := terraform.Output(t, terraformOptions, "firewall_rules_count")
	assert.NotEmpty(t, firewallRulesCount)

	azureServicesAllowed := terraform.Output(t, terraformOptions, "azure_services_allowed")
	assert.Equal(t, "true", azureServicesAllowed)
}

func TestMySQLFirewallRuleValidation(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"mysql_server_name":               "test-mysql-server",
			"mysql_server_resource_group_name": "test-rg",
			"firewall_rules": []map[string]interface{}{
				{
					"name":             "ValidRule1",
					"start_ip_address": "192.168.1.0",
					"end_ip_address":   "192.168.1.255",
				},
				{
					"name":             "ValidRule2",
					"start_ip_address": "10.0.0.0",
					"end_ip_address":   "10.0.0.255",
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate multiple rules are created
	firewallRuleNames := terraform.OutputList(t, terraformOptions, "firewall_rule_names")
	assert.Len(t, firewallRuleNames, 2)
	assert.Contains(t, firewallRuleNames, "ValidRule1")
	assert.Contains(t, firewallRuleNames, "ValidRule2")

	// Validate security configuration
	securityConfig := terraform.OutputMap(t, terraformOptions, "security_configuration")
	assert.NotEmpty(t, securityConfig)
	assert.Equal(t, "true", securityConfig["ip_range_validation_enabled"])
}

func TestMySQLFirewallRuleAdvanced(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/advanced",

		Vars: map[string]interface{}{
			"mysql_flexible_server_name":               "test-flexible-server",
			"mysql_flexible_server_resource_group_name": "test-rg",
			"environment":         "prod",
			"enable_monitoring":   true,
			"max_firewall_rules": 20,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate advanced features
	serverType := terraform.Output(t, terraformOptions, "server_type")
	assert.Equal(t, "flexible", serverType)

	officeIpsCount := terraform.Output(t, terraformOptions, "office_ips_count")
	assert.NotEqual(t, "0", officeIpsCount)

	developerIpsCount := terraform.Output(t, terraformOptions, "developer_ips_count")
	assert.NotEqual(t, "0", developerIpsCount)

	applicationSubnetsCount := terraform.Output(t, terraformOptions, "application_subnets_count")
	assert.NotEqual(t, "0", applicationSubnetsCount)

	// Validate compliance status
	complianceStatus := terraform.OutputMap(t, terraformOptions, "compliance_status")
	assert.NotEmpty(t, complianceStatus)
	assert.Equal(t, "true", complianceStatus["environment_validated"])
	assert.Equal(t, "true", complianceStatus["rule_count_within_limit"])
}

func TestMySQLFirewallRuleNetworkAccess(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/advanced",

		Vars: map[string]interface{}{
			"mysql_flexible_server_name":               "test-flexible-server",
			"mysql_flexible_server_resource_group_name": "test-rg",
			"allow_office_ips": []string{
				"203.0.113.0/24",
				"198.51.100.50",
			},
			"allow_developer_ips": []string{
				"192.0.2.10",
				"192.0.2.20",
			},
			"allow_application_subnets": []string{
				"10.1.0.0/24",
				"10.2.0.0/24",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate network access summary
	networkAccessSummary := terraform.OutputMap(t, terraformOptions, "network_access_summary")
	assert.NotEmpty(t, networkAccessSummary)
	assert.Equal(t, "2", networkAccessSummary["office_locations"])
	assert.Equal(t, "2", networkAccessSummary["developer_access_points"])
	assert.Equal(t, "2", networkAccessSummary["application_networks"])

	// Validate firewall rules details
	firewallRulesDetails := terraform.OutputMap(t, terraformOptions, "firewall_rules_details")
	assert.NotEmpty(t, firewallRulesDetails)
}

func TestMySQLFirewallRuleTags(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"mysql_server_name":               "test-mysql-server",
			"mysql_server_resource_group_name": "test-rg",
			"common_tags": map[string]interface{}{
				"Environment": "test",
				"Project":     "terratest",
				"Owner":       "automation",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate applied tags
	appliedTags := terraform.OutputMap(t, terraformOptions, "applied_tags")
	assert.NotEmpty(t, appliedTags)
	assert.Equal(t, "test", appliedTags["Environment"])
	assert.Equal(t, "terratest", appliedTags["Project"])
	assert.Equal(t, "Terraform", appliedTags["ManagedBy"])
	assert.Equal(t, "zrr-tf-module-lib/azure/security/mysql-firewall-rule", appliedTags["Module"])
}