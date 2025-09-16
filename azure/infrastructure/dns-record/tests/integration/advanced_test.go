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

func TestDNSRecordAdvanced(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-dns-rg-%s", uniqueId)
	privateDnsZoneName := fmt.Sprintf("internal-%s.local", uniqueId)
	recordName := "api"

	// Azure region for testing
	region := "East US"

	// Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/advanced",
		Vars: map[string]interface{}{
			"record_name":                           recordName,
			"record_type":                           "A",
			"records":                               []string{"10.0.1.10", "10.0.1.11"},
			"ttl":                                  300,
			"private_dns_zone_name":                privateDnsZoneName,
			"private_dns_zone_resource_group_name": resourceGroupName,
			"environment":                          "test",
			"criticality":                          "high",
			"enable_monitoring":                    true,
			"health_check_enabled":                 true,
			"alert_on_changes":                     true,
			"compliance_requirements":              []string{"ISO27001", "SOC2"},
			"security_config": map[string]interface{}{
				"access_restrictions":   []string{"10.0.0.0/8"},
				"change_protection":     true,
				"audit_logging":         true,
				"encryption_in_transit": true,
			},
			"record_lifecycle": map[string]interface{}{
				"auto_delete_after_days":    nil,
				"backup_enabled":           true,
				"change_approval_required": true,
				"scheduled_updates":        false,
			},
			"validation_rules": map[string]interface{}{
				"strict_format_checking": true,
				"allow_wildcard_records": false,
				"max_record_count":      10,
				"forbidden_values":      []string{"127.0.0.1"},
			},
			"common_tags": map[string]interface{}{
				"Environment": "test",
				"Project":     "terratest-advanced",
				"Owner":       "automation",
				"Compliance":  "required",
			},
			"dns_record_tags": map[string]interface{}{
				"Purpose":     "api-endpoint",
				"ServiceTier": "critical",
				"Monitoring":  "enabled",
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

	// Create private DNS zone
	azure.CreatePrivateDNSZone(t, privateDnsZoneName, resourceGroupName, subscriptionID)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	dnsRecordId := terraform.Output(t, terraformOptions, "dns_record_id")
	dnsRecordFqdn := terraform.Output(t, terraformOptions, "dns_record_fqdn")
	dnsRecordName := terraform.Output(t, terraformOptions, "dns_record_name")
	dnsRecordType := terraform.Output(t, terraformOptions, "dns_record_type")
	dnsZoneType := terraform.Output(t, terraformOptions, "dns_zone_type")

	// Assert basic outputs
	assert.NotEmpty(t, dnsRecordId)
	assert.NotEmpty(t, dnsRecordFqdn)
	assert.Equal(t, recordName, dnsRecordName)
	assert.Equal(t, "A", dnsRecordType)
	assert.Equal(t, "private", dnsZoneType)

	// Validate FQDN format for private zone
	expectedFqdn := fmt.Sprintf("%s.%s", recordName, privateDnsZoneName)
	assert.Equal(t, expectedFqdn, dnsRecordFqdn)

	// Validate advanced outputs
	recordManagement := terraform.OutputMap(t, terraformOptions, "record_management")
	assert.NotEmpty(t, recordManagement)

	validationStatus := terraform.OutputMap(t, terraformOptions, "validation_status")
	assert.NotEmpty(t, validationStatus)

	monitoringConfig := terraform.OutputMap(t, terraformOptions, "monitoring_config")
	assert.NotEmpty(t, monitoringConfig)

	complianceStatus := terraform.OutputMap(t, terraformOptions, "compliance_status")
	assert.NotEmpty(t, complianceStatus)

	securityPosture := terraform.OutputMap(t, terraformOptions, "security_posture")
	assert.NotEmpty(t, securityPosture)

	// Validate DNS record exists in Azure
	recordSet := azure.GetPrivateDNSRecordSet(t, resourceGroupName, privateDnsZoneName, recordName, "A", subscriptionID)
	assert.NotNil(t, recordSet)
	assert.Equal(t, int32(300), *recordSet.TTL)

	// Validate A records
	require.NotNil(t, recordSet.ARecords)
	assert.Len(t, *recordSet.ARecords, 2)

	expectedIPs := []string{"10.0.1.10", "10.0.1.11"}
	actualIPs := make([]string, len(*recordSet.ARecords))
	for i, record := range *recordSet.ARecords {
		actualIPs[i] = *record.Ipv4Address
	}

	assert.ElementsMatch(t, expectedIPs, actualIPs)
}

func TestDNSRecordMX(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-dns-rg-%s", uniqueId)
	dnsZoneName := fmt.Sprintf("test-zone-%s.com", uniqueId)
	recordName := "mail"

	// Azure region for testing
	region := "East US"

	// Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/advanced",
		Vars: map[string]interface{}{
			"record_name":                     recordName,
			"record_type":                     "MX",
			"records":                         []string{}, // Empty for MX records
			"ttl":                            3600,
			"dns_zone_name":                  dnsZoneName,
			"dns_zone_resource_group_name":   resourceGroupName,
			"mx_records": []map[string]interface{}{
				{
					"preference": 10,
					"exchange":   "mail1.example.com.",
				},
				{
					"preference": 20,
					"exchange":   "mail2.example.com.",
				},
			},
			"environment": "test",
			"criticality": "medium",
			"common_tags": map[string]interface{}{
				"Environment": "test",
				"Project":     "terratest-mx",
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

	// Create DNS zone
	azure.CreateDNSZone(t, dnsZoneName, resourceGroupName, subscriptionID)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	dnsRecordType := terraform.Output(t, terraformOptions, "dns_record_type")
	assert.Equal(t, "MX", dnsRecordType)

	// Validate DNS record exists in Azure
	recordSet := azure.GetDNSRecordSet(t, resourceGroupName, dnsZoneName, recordName, "MX", subscriptionID)
	assert.NotNil(t, recordSet)

	// Validate MX records
	require.NotNil(t, recordSet.MxRecords)
	assert.Len(t, *recordSet.MxRecords, 2)

	// Check MX record values
	mxRecords := *recordSet.MxRecords
	preferences := make([]int32, len(mxRecords))
	exchanges := make([]string, len(mxRecords))

	for i, mxRecord := range mxRecords {
		preferences[i] = *mxRecord.Preference
		exchanges[i] = *mxRecord.Exchange
	}

	assert.Contains(t, preferences, int32(10))
	assert.Contains(t, preferences, int32(20))
	assert.Contains(t, exchanges, "mail1.example.com.")
	assert.Contains(t, exchanges, "mail2.example.com.")
}

func TestDNSRecordSRV(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-dns-rg-%s", uniqueId)
	dnsZoneName := fmt.Sprintf("test-zone-%s.com", uniqueId)
	recordName := "_sip._tcp"

	// Azure region for testing
	region := "East US"

	// Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/advanced",
		Vars: map[string]interface{}{
			"record_name":                     recordName,
			"record_type":                     "SRV",
			"records":                         []string{}, // Empty for SRV records
			"ttl":                            1800,
			"dns_zone_name":                  dnsZoneName,
			"dns_zone_resource_group_name":   resourceGroupName,
			"srv_records": []map[string]interface{}{
				{
					"priority": 10,
					"weight":   60,
					"port":     5060,
					"target":   "sip1.example.com.",
				},
				{
					"priority": 10,
					"weight":   40,
					"port":     5060,
					"target":   "sip2.example.com.",
				},
			},
			"environment": "test",
			"criticality": "medium",
			"common_tags": map[string]interface{}{
				"Environment": "test",
				"Project":     "terratest-srv",
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

	// Create DNS zone
	azure.CreateDNSZone(t, dnsZoneName, resourceGroupName, subscriptionID)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	dnsRecordType := terraform.Output(t, terraformOptions, "dns_record_type")
	assert.Equal(t, "SRV", dnsRecordType)

	// Validate DNS record exists in Azure
	recordSet := azure.GetDNSRecordSet(t, resourceGroupName, dnsZoneName, recordName, "SRV", subscriptionID)
	assert.NotNil(t, recordSet)

	// Validate SRV records
	require.NotNil(t, recordSet.SrvRecords)
	assert.Len(t, *recordSet.SrvRecords, 2)

	// Check SRV record values
	srvRecords := *recordSet.SrvRecords
	priorities := make([]int32, len(srvRecords))
	weights := make([]int32, len(srvRecords))
	ports := make([]int32, len(srvRecords))
	targets := make([]string, len(srvRecords))

	for i, srvRecord := range srvRecords {
		priorities[i] = *srvRecord.Priority
		weights[i] = *srvRecord.Weight
		ports[i] = *srvRecord.Port
		targets[i] = *srvRecord.Target
	}

	assert.Contains(t, priorities, int32(10))
	assert.Contains(t, weights, int32(60))
	assert.Contains(t, weights, int32(40))
	assert.Contains(t, ports, int32(5060))
	assert.Contains(t, targets, "sip1.example.com.")
	assert.Contains(t, targets, "sip2.example.com.")
}

func TestDNSRecordEnterprise(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-dns-rg-%s", uniqueId)
	dnsZoneName := fmt.Sprintf("test-zone-%s.com", uniqueId)
	recordName := "enterprise"

	// Azure region for testing
	region := "East US"

	// Terraform options with all enterprise features
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/advanced",
		Vars: map[string]interface{}{
			"record_name":                     recordName,
			"record_type":                     "A",
			"records":                         []string{"203.0.113.100"},
			"ttl":                            60,
			"dns_zone_name":                  dnsZoneName,
			"dns_zone_resource_group_name":   resourceGroupName,
			"environment":                    "prod",
			"criticality":                    "critical",
			"enable_monitoring":              true,
			"health_check_enabled":           true,
			"alert_on_changes":               true,
			"compliance_requirements":        []string{"SOX", "PCI-DSS", "ISO27001", "GDPR", "HIPAA"},
			"security_config": map[string]interface{}{
				"access_restrictions":   []string{"10.0.0.0/8", "172.16.0.0/12"},
				"change_protection":     true,
				"audit_logging":         true,
				"encryption_in_transit": true,
			},
			"record_lifecycle": map[string]interface{}{
				"auto_delete_after_days":    nil,
				"backup_enabled":           true,
				"change_approval_required": true,
				"scheduled_updates":        false,
			},
			"validation_rules": map[string]interface{}{
				"strict_format_checking": true,
				"allow_wildcard_records": false,
				"max_record_count":      5,
				"forbidden_values":      []string{"127.0.0.1", "localhost", "0.0.0.0"},
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
			"dns_record_tags": map[string]interface{}{
				"Purpose":         "enterprise-endpoint",
				"ServiceTier":     "critical",
				"Monitoring":      "enabled",
				"Backup":          "daily",
				"LoadBalanced":    "true",
				"HealthCheck":     "enabled",
				"TrafficPattern":  "high-volume",
				"GeoDNS":          "enabled",
				"SecurityScan":    "weekly",
				"PerformanceTest": "daily",
				"Failover":        "automatic",
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

	// Create DNS zone
	azure.CreateDNSZone(t, dnsZoneName, resourceGroupName, subscriptionID)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Validate all enterprise outputs
	outputs := []string{
		"dns_record_id",
		"dns_record_fqdn",
		"dns_record_name",
		"dns_record_type",
		"dns_record_ttl",
		"dns_zone_type",
		"record_management",
		"validation_status",
		"monitoring_config",
		"compliance_status",
		"security_posture",
		"lifecycle_config",
		"health_check_status",
		"network_info",
	}

	for _, output := range outputs {
		value := terraform.Output(t, terraformOptions, output)
		assert.NotEmpty(t, value, "Output %s should not be empty", output)
	}

	// Validate specific values
	assert.Equal(t, recordName, terraform.Output(t, terraformOptions, "dns_record_name"))
	assert.Equal(t, "A", terraform.Output(t, terraformOptions, "dns_record_type"))
	assert.Equal(t, "60", terraform.Output(t, terraformOptions, "dns_record_ttl"))
	assert.Equal(t, "public", terraform.Output(t, terraformOptions, "dns_zone_type"))

	// Validate compliance status contains all required frameworks
	complianceStatus := terraform.OutputMap(t, terraformOptions, "compliance_status")
	assert.Contains(t, complianceStatus, "requirements")
	assert.Contains(t, complianceStatus, "status")

	// Validate security posture
	securityPosture := terraform.OutputMap(t, terraformOptions, "security_posture")
	assert.Contains(t, securityPosture, "access_restrictions")
	assert.Contains(t, securityPosture, "change_protection")
	assert.Contains(t, securityPosture, "audit_logging")

	// Validate monitoring configuration
	monitoringConfig := terraform.OutputMap(t, terraformOptions, "monitoring_config")
	assert.Contains(t, monitoringConfig, "enabled")
	assert.Contains(t, monitoringConfig, "health_check_enabled")
	assert.Contains(t, monitoringConfig, "alert_on_changes")
}