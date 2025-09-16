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

func TestDNSZoneCreation(t *testing.T) {
	t.Parallel()

	// Generate a random suffix for unique resource names
	randomSuffix := strings.ToLower(random.UniqueId())
	zoneName := fmt.Sprintf("test-%s.example.com", randomSuffix)
	resourceGroupName := fmt.Sprintf("test-dns-rg-%s", randomSuffix)

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",

		Vars: map[string]interface{}{
			"zone_name":           zoneName,
			"resource_group_name": resourceGroupName,
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
	dnsZoneID := terraform.Output(t, terraformOptions, "dns_zone_id")
	assert.NotEmpty(t, dnsZoneID)

	dnsZoneName := terraform.Output(t, terraformOptions, "dns_zone_name")
	assert.Equal(t, zoneName, dnsZoneName)

	nameServers := terraform.OutputList(t, terraformOptions, "name_servers")
	assert.NotEmpty(t, nameServers)
	assert.Len(t, nameServers, 4) // Azure DNS provides 4 name servers

	primaryNameServer := terraform.Output(t, terraformOptions, "primary_name_server")
	assert.NotEmpty(t, primaryNameServer)
	assert.Contains(t, nameServers, primaryNameServer)

	recordCount := terraform.Output(t, terraformOptions, "record_count")
	assert.Equal(t, "3", recordCount) // 2 A records + 1 CNAME record from basic example
}

func TestDNSZoneWithAdvancedFeatures(t *testing.T) {
	t.Parallel()

	randomSuffix := strings.ToLower(random.UniqueId())
	zoneName := fmt.Sprintf("advanced-%s.example.com", randomSuffix)
	resourceGroupName := fmt.Sprintf("test-dns-advanced-rg-%s", randomSuffix)

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                         zoneName,
			"resource_group_name":          resourceGroupName,
			"enable_monitoring":            true,
			"query_volume_threshold":       5000,
			"record_set_count_threshold":   1000,

			// Test various record types
			"a_records": []map[string]interface{}{
				{
					"name":    "www",
					"ttl":     3600,
					"records": []string{"1.2.3.4", "5.6.7.8"},
				},
				{
					"name":    "api",
					"ttl":     300,
					"records": []string{"10.0.1.100"},
				},
			},
			"aaaa_records": []map[string]interface{}{
				{
					"name":    "www",
					"ttl":     3600,
					"records": []string{"2001:db8::1"},
				},
			},
			"cname_records": []map[string]interface{}{
				{
					"name":   "blog",
					"ttl":    3600,
					"record": fmt.Sprintf("www.%s", zoneName),
				},
			},
			"mx_records": []map[string]interface{}{
				{
					"name": "@",
					"ttl":  3600,
					"records": []map[string]interface{}{
						{
							"preference": 10,
							"exchange":   fmt.Sprintf("mail.%s", zoneName),
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
							"target":   fmt.Sprintf("sip.%s", zoneName),
						},
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

	// Validate DNS zone
	dnsZoneID := terraform.Output(t, terraformOptions, "id")
	assert.NotEmpty(t, dnsZoneID)

	zoneName = terraform.Output(t, terraformOptions, "name")
	assert.NotEmpty(t, zoneName)

	// Validate record creation
	aRecords := terraform.OutputMapOfObjects(t, terraformOptions, "a_records")
	assert.Len(t, aRecords, 2)

	aaaaRecords := terraform.OutputMapOfObjects(t, terraformOptions, "aaaa_records")
	assert.Len(t, aaaaRecords, 1)

	cnameRecords := terraform.OutputMapOfObjects(t, terraformOptions, "cname_records")
	assert.Len(t, cnameRecords, 1)

	mxRecords := terraform.OutputMapOfObjects(t, terraformOptions, "mx_records")
	assert.Len(t, mxRecords, 1)

	txtRecords := terraform.OutputMapOfObjects(t, terraformOptions, "txt_records")
	assert.Len(t, txtRecords, 1)

	srvRecords := terraform.OutputMapOfObjects(t, terraformOptions, "srv_records")
	assert.Len(t, srvRecords, 1)

	// Validate monitoring
	monitoringEnabled := terraform.Output(t, terraformOptions, "monitoring_enabled")
	assert.Equal(t, "true", monitoringEnabled)

	queryVolumeAlertID := terraform.Output(t, terraformOptions, "query_volume_alert_id")
	assert.NotEmpty(t, queryVolumeAlertID)

	recordCountAlertID := terraform.Output(t, terraformOptions, "record_count_alert_id")
	assert.NotEmpty(t, recordCountAlertID)

	// Validate record count
	recordTypesSum := terraform.OutputMapOfObjects(t, terraformOptions, "record_types_summary")
	totalRecords := 0
	for _, count := range recordTypesSum {
		if countFloat, ok := count.(float64); ok {
			totalRecords += int(countFloat)
		}
	}
	assert.Equal(t, 6, totalRecords) // 2A + 1AAAA + 1CNAME + 1MX + 1TXT + 1SRV
}

func TestDNSZoneNamingConvention(t *testing.T) {
	t.Parallel()

	randomSuffix := strings.ToLower(random.UniqueId())
	baseName := fmt.Sprintf("test-%s", randomSuffix)
	resourceGroupName := fmt.Sprintf("test-naming-rg-%s", randomSuffix)
	environment := "dev"
	domainSuffix := "internal"

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                   baseName,
			"resource_group_name":    resourceGroupName,
			"use_naming_convention":  true,
			"environment":            environment,
			"domain_suffix":          domainSuffix,
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
	zoneName := terraform.Output(t, terraformOptions, "name")
	expectedName := fmt.Sprintf("%s.%s.%s", baseName, environment, domainSuffix)
	assert.Equal(t, expectedName, zoneName)

	// Validate naming details
	zoneNameDetails := terraform.OutputMap(t, terraformOptions, "zone_name_details")
	assert.Equal(t, baseName, zoneNameDetails["original_name"])
	assert.Equal(t, expectedName, zoneNameDetails["final_zone_name"])
	assert.Equal(t, environment, zoneNameDetails["environment"])
	assert.Equal(t, domainSuffix, zoneNameDetails["domain_suffix"])
	assert.Equal(t, "true", zoneNameDetails["naming_convention"])
}

func TestDNSZoneRecordValidation(t *testing.T) {
	t.Parallel()

	randomSuffix := strings.ToLower(random.UniqueId())
	zoneName := fmt.Sprintf("validation-%s.example.com", randomSuffix)
	resourceGroupName := fmt.Sprintf("test-validation-rg-%s", randomSuffix)

	// Test with complex record configurations
	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                zoneName,
			"resource_group_name": resourceGroupName,

			// Test multiple records with different TTLs
			"a_records": []map[string]interface{}{
				{
					"name":    "www",
					"ttl":     3600,
					"records": []string{"1.2.3.4"},
				},
				{
					"name":    "api",
					"ttl":     300, // Short TTL for API
					"records": []string{"5.6.7.8"},
				},
			},
			// Test CNAME with special characters
			"cname_records": []map[string]interface{}{
				{
					"name":   "test-app",
					"ttl":    7200,
					"record": fmt.Sprintf("www.%s", zoneName),
				},
			},
			// Test MX with multiple preferences
			"mx_records": []map[string]interface{}{
				{
					"name": "@",
					"ttl":  3600,
					"records": []map[string]interface{}{
						{
							"preference": 10,
							"exchange":   fmt.Sprintf("mail1.%s", zoneName),
						},
						{
							"preference": 20,
							"exchange":   fmt.Sprintf("mail2.%s", zoneName),
						},
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

	// Validate A records with different TTLs
	aRecords := terraform.OutputMapOfObjects(t, terraformOptions, "a_records")
	require.Contains(t, aRecords, "www")
	require.Contains(t, aRecords, "api")

	wwwRecord := aRecords["www"].(map[string]interface{})
	assert.Equal(t, float64(3600), wwwRecord["ttl"])

	apiRecord := aRecords["api"].(map[string]interface{})
	assert.Equal(t, float64(300), apiRecord["ttl"])

	// Validate CNAME records
	cnameRecords := terraform.OutputMapOfObjects(t, terraformOptions, "cname_records")
	require.Contains(t, cnameRecords, "test-app")

	testAppRecord := cnameRecords["test-app"].(map[string]interface{})
	assert.Equal(t, float64(7200), testAppRecord["ttl"])

	// Validate MX records
	mxRecords := terraform.OutputMapOfObjects(t, terraformOptions, "mx_records")
	require.Contains(t, mxRecords, "@")

	// Validate record count summary
	recordTypesSum := terraform.OutputMap(t, terraformOptions, "record_types_summary")
	assert.Equal(t, "2", recordTypesSum["a_records"])
	assert.Equal(t, "1", recordTypesSum["cname_records"])
	assert.Equal(t, "1", recordTypesSum["mx_records"])
}

func TestDNSZoneTagging(t *testing.T) {
	t.Parallel()

	randomSuffix := strings.ToLower(random.UniqueId())
	zoneName := fmt.Sprintf("tagging-%s.example.com", randomSuffix)
	resourceGroupName := fmt.Sprintf("test-tagging-rg-%s", randomSuffix)

	commonTags := map[string]string{
		"Environment": "test",
		"Project":     "terratest",
		"Owner":       "platform-team",
		"TestID":      randomSuffix,
	}

	dnsZoneTags := map[string]string{
		"DNSType": "public",
		"Purpose": "testing",
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../../",

		Vars: map[string]interface{}{
			"name":                zoneName,
			"resource_group_name": resourceGroupName,
			"common_tags":         commonTags,
			"dns_zone_tags":       dnsZoneTags,
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

	// Check DNS zone specific tags
	for key, value := range dnsZoneTags {
		assert.Equal(t, value, appliedTags[key])
	}

	// Check automatic tags
	assert.Equal(t, "Terraform", appliedTags["ManagedBy"])
	assert.Equal(t, "zrr-tf-module-lib/azure/infrastructure/dns-zone", appliedTags["Module"])
	assert.Equal(t, "infrastructure", appliedTags["Layer"])
}

// Helper function to check if DNS zone exists
func dnsZoneExists(t *testing.T, subscriptionID string, resourceGroupName string, zoneName string) bool {
	exists, err := azure.DNSZoneExistsE(zoneName, resourceGroupName, subscriptionID)
	require.NoError(t, err)
	return exists
}