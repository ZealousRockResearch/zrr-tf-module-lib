package test

import (
	"fmt"
	"net"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestDNSRecordBasic(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-dns-rg-%s", uniqueId)
	dnsZoneName := fmt.Sprintf("test-zone-%s.com", uniqueId)
	recordName := "www"

	// Azure region for testing
	region := "East US"

	// Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"record_name":                     recordName,
			"record_type":                     "A",
			"records":                         []string{"203.0.113.1", "203.0.113.2"},
			"ttl":                            300,
			"dns_zone_name":                  dnsZoneName,
			"dns_zone_resource_group_name":   resourceGroupName,
			"environment":                    "test",
			"criticality":                    "low",
			"common_tags": map[string]interface{}{
				"Environment": "test",
				"Project":     "terratest",
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
	dnsRecordId := terraform.Output(t, terraformOptions, "dns_record_id")
	dnsRecordFqdn := terraform.Output(t, terraformOptions, "dns_record_fqdn")
	dnsRecordName := terraform.Output(t, terraformOptions, "dns_record_name")
	dnsRecordType := terraform.Output(t, terraformOptions, "dns_record_type")
	dnsRecordTtl := terraform.Output(t, terraformOptions, "dns_record_ttl")

	// Assert outputs are not empty
	assert.NotEmpty(t, dnsRecordId)
	assert.NotEmpty(t, dnsRecordFqdn)
	assert.Equal(t, recordName, dnsRecordName)
	assert.Equal(t, "A", dnsRecordType)
	assert.Equal(t, "300", dnsRecordTtl)

	// Validate FQDN format
	expectedFqdn := fmt.Sprintf("%s.%s", recordName, dnsZoneName)
	assert.Equal(t, expectedFqdn, dnsRecordFqdn)

	// Validate DNS record exists in Azure
	recordSet := azure.GetDNSRecordSet(t, resourceGroupName, dnsZoneName, recordName, "A", subscriptionID)
	assert.NotNil(t, recordSet)
	assert.Equal(t, int32(300), *recordSet.TTL)

	// Validate A records
	require.NotNil(t, recordSet.ARecords)
	assert.Len(t, *recordSet.ARecords, 2)

	expectedIPs := []string{"203.0.113.1", "203.0.113.2"}
	actualIPs := make([]string, len(*recordSet.ARecords))
	for i, record := range *recordSet.ARecords {
		actualIPs[i] = *record.Ipv4Address
	}

	assert.ElementsMatch(t, expectedIPs, actualIPs)

	// Validate DNS resolution (if public DNS)
	t.Run("DNS Resolution Test", func(t *testing.T) {
		// Wait for DNS propagation
		time.Sleep(30 * time.Second)

		// Attempt DNS lookup
		ips, err := net.LookupIP(dnsRecordFqdn)
		if err != nil {
			t.Logf("DNS lookup failed (expected in test environment): %v", err)
			return
		}

		// Validate resolved IPs
		var resolvedIPv4s []string
		for _, ip := range ips {
			if ipv4 := ip.To4(); ipv4 != nil {
				resolvedIPv4s = append(resolvedIPv4s, ipv4.String())
			}
		}

		if len(resolvedIPv4s) > 0 {
			assert.Subset(t, expectedIPs, resolvedIPv4s)
		}
	})
}

func TestDNSRecordCNAME(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-dns-rg-%s", uniqueId)
	dnsZoneName := fmt.Sprintf("test-zone-%s.com", uniqueId)
	recordName := "blog"
	targetDomain := "blog.example.org."

	// Azure region for testing
	region := "East US"

	// Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"record_name":                     recordName,
			"record_type":                     "CNAME",
			"records":                         []string{targetDomain},
			"ttl":                            3600,
			"dns_zone_name":                  dnsZoneName,
			"dns_zone_resource_group_name":   resourceGroupName,
			"environment":                    "test",
			"criticality":                    "low",
			"common_tags": map[string]interface{}{
				"Environment": "test",
				"Project":     "terratest",
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
	assert.Equal(t, "CNAME", dnsRecordType)

	// Validate DNS record exists in Azure
	recordSet := azure.GetDNSRecordSet(t, resourceGroupName, dnsZoneName, recordName, "CNAME", subscriptionID)
	assert.NotNil(t, recordSet)
	assert.Equal(t, int32(3600), *recordSet.TTL)

	// Validate CNAME record
	require.NotNil(t, recordSet.CnameRecord)
	assert.Equal(t, targetDomain, *recordSet.CnameRecord.Cname)
}

func TestDNSRecordTXT(t *testing.T) {
	t.Parallel()

	// Generate unique resource names
	uniqueId := random.UniqueId()
	resourceGroupName := fmt.Sprintf("test-dns-rg-%s", uniqueId)
	dnsZoneName := fmt.Sprintf("test-zone-%s.com", uniqueId)
	recordName := "@"
	txtRecord := "v=spf1 include:_spf.google.com ~all"

	// Azure region for testing
	region := "East US"

	// Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"record_name":                     recordName,
			"record_type":                     "TXT",
			"records":                         []string{txtRecord},
			"ttl":                            3600,
			"dns_zone_name":                  dnsZoneName,
			"dns_zone_resource_group_name":   resourceGroupName,
			"environment":                    "test",
			"criticality":                    "low",
			"common_tags": map[string]interface{}{
				"Environment": "test",
				"Project":     "terratest",
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
	assert.Equal(t, "TXT", dnsRecordType)

	// Validate DNS record exists in Azure
	recordSet := azure.GetDNSRecordSet(t, resourceGroupName, dnsZoneName, recordName, "TXT", subscriptionID)
	assert.NotNil(t, recordSet)

	// Validate TXT record
	require.NotNil(t, recordSet.TxtRecords)
	assert.Len(t, *recordSet.TxtRecords, 1)

	txtRecordValue := (*recordSet.TxtRecords)[0]
	require.NotNil(t, txtRecordValue.Value)
	assert.Contains(t, *txtRecordValue.Value, txtRecord)
}

func TestDNSRecordValidation(t *testing.T) {
	t.Parallel()

	// Test invalid record type
	t.Run("Invalid Record Type", func(t *testing.T) {
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: "../../examples/basic",
			Vars: map[string]interface{}{
				"record_type": "INVALID",
			},
		})

		_, err := terraform.InitAndPlanE(t, terraformOptions)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "Record type must be one of")
	})

	// Test invalid TTL
	t.Run("Invalid TTL", func(t *testing.T) {
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: "../../examples/basic",
			Vars: map[string]interface{}{
				"ttl": 30, // Below minimum
			},
		})

		_, err := terraform.InitAndPlanE(t, terraformOptions)
		assert.Error(t, err)
		assert.Contains(t, strings.ToLower(err.Error()), "ttl")
	})

	// Test invalid environment
	t.Run("Invalid Environment", func(t *testing.T) {
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: "../../examples/basic",
			Vars: map[string]interface{}{
				"environment": "invalid",
			},
		})

		_, err := terraform.InitAndPlanE(t, terraformOptions)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "Environment must be one of")
	})
}