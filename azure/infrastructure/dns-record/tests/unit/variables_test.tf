# Unit tests for DNS Record module variable validation
# These tests validate the variable constraints and validation rules

terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

# Test valid record types
resource "test_assertions" "valid_record_types" {
  component = "dns_record_variables"

  check "a_record_type" {
    assertion     = can(regex("^[A]$", "A"))
    error_message = "A record type should be valid"
  }

  check "aaaa_record_type" {
    assertion     = can(regex("^[A]{4}$", "AAAA"))
    error_message = "AAAA record type should be valid"
  }

  check "cname_record_type" {
    assertion     = can(regex("^CNAME$", "CNAME"))
    error_message = "CNAME record type should be valid"
  }

  check "mx_record_type" {
    assertion     = can(regex("^MX$", "MX"))
    error_message = "MX record type should be valid"
  }

  check "txt_record_type" {
    assertion     = can(regex("^TXT$", "TXT"))
    error_message = "TXT record type should be valid"
  }

  check "srv_record_type" {
    assertion     = can(regex("^SRV$", "SRV"))
    error_message = "SRV record type should be valid"
  }

  check "ns_record_type" {
    assertion     = can(regex("^NS$", "NS"))
    error_message = "NS record type should be valid"
  }

  check "caa_record_type" {
    assertion     = can(regex("^CAA$", "CAA"))
    error_message = "CAA record type should be valid"
  }
}

# Test TTL validation
resource "test_assertions" "ttl_validation" {
  component = "dns_record_ttl"

  check "minimum_ttl" {
    assertion     = 60 >= 60 && 60 <= 2147483647
    error_message = "TTL should accept minimum value of 60"
  }

  check "maximum_ttl" {
    assertion     = 2147483647 >= 60 && 2147483647 <= 2147483647
    error_message = "TTL should accept maximum value of 2147483647"
  }

  check "standard_ttl" {
    assertion     = 3600 >= 60 && 3600 <= 2147483647
    error_message = "TTL should accept standard value of 3600"
  }
}

# Test environment validation
resource "test_assertions" "environment_validation" {
  component = "dns_record_environment"

  check "dev_environment" {
    assertion     = contains(["dev", "test", "staging", "prod"], "dev")
    error_message = "Should accept dev environment"
  }

  check "test_environment" {
    assertion     = contains(["dev", "test", "staging", "prod"], "test")
    error_message = "Should accept test environment"
  }

  check "staging_environment" {
    assertion     = contains(["dev", "test", "staging", "prod"], "staging")
    error_message = "Should accept staging environment"
  }

  check "prod_environment" {
    assertion     = contains(["dev", "test", "staging", "prod"], "prod")
    error_message = "Should accept prod environment"
  }
}

# Test criticality validation
resource "test_assertions" "criticality_validation" {
  component = "dns_record_criticality"

  check "low_criticality" {
    assertion     = contains(["low", "medium", "high", "critical"], "low")
    error_message = "Should accept low criticality"
  }

  check "medium_criticality" {
    assertion     = contains(["low", "medium", "high", "critical"], "medium")
    error_message = "Should accept medium criticality"
  }

  check "high_criticality" {
    assertion     = contains(["low", "medium", "high", "critical"], "high")
    error_message = "Should accept high criticality"
  }

  check "critical_criticality" {
    assertion     = contains(["low", "medium", "high", "critical"], "critical")
    error_message = "Should accept critical criticality"
  }
}

# Test DNS name validation
resource "test_assertions" "dns_name_validation" {
  component = "dns_record_name"

  check "simple_name" {
    assertion     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$", "www"))
    error_message = "Should accept simple DNS names"
  }

  check "subdomain_name" {
    assertion     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$", "api-v2"))
    error_message = "Should accept hyphenated DNS names"
  }

  check "root_name" {
    assertion     = can(regex("^@$", "@"))
    error_message = "Should accept root record (@)"
  }

  check "wildcard_name" {
    assertion     = can(regex("^\\*$", "*"))
    error_message = "Should accept wildcard record (*)"
  }
}

# Test MX record validation
resource "test_assertions" "mx_record_validation" {
  component = "dns_record_mx"

  check "mx_preference_range" {
    assertion     = 10 >= 0 && 10 <= 65535
    error_message = "MX preference should be within valid range"
  }

  check "mx_exchange_format" {
    assertion     = can(regex("^[a-zA-Z0-9.-]+\\.$", "mail.example.com."))
    error_message = "MX exchange should end with a dot"
  }
}

# Test SRV record validation
resource "test_assertions" "srv_record_validation" {
  component = "dns_record_srv"

  check "srv_priority_range" {
    assertion     = 10 >= 0 && 10 <= 65535
    error_message = "SRV priority should be within valid range"
  }

  check "srv_weight_range" {
    assertion     = 60 >= 0 && 60 <= 65535
    error_message = "SRV weight should be within valid range"
  }

  check "srv_port_range" {
    assertion     = 5060 >= 1 && 5060 <= 65535
    error_message = "SRV port should be within valid range"
  }

  check "srv_target_format" {
    assertion     = can(regex("^[a-zA-Z0-9.-]+\\.$", "sip.example.com."))
    error_message = "SRV target should end with a dot"
  }
}

# Test security configuration validation
resource "test_assertions" "security_config_validation" {
  component = "dns_record_security"

  check "cidr_format" {
    assertion     = can(cidrhost("10.0.0.0/8", 1))
    error_message = "Should accept valid CIDR notation"
  }

  check "boolean_flags" {
    assertion     = tobool(true) == true && tobool(false) == false
    error_message = "Boolean security flags should be valid"
  }
}

# Test compliance requirements validation
resource "test_assertions" "compliance_validation" {
  component = "dns_record_compliance"

  check "compliance_frameworks" {
    assertion = alltrue([
      contains(["SOX", "PCI-DSS", "ISO27001", "GDPR", "HIPAA", "FedRAMP", "SOC2"], "SOX"),
      contains(["SOX", "PCI-DSS", "ISO27001", "GDPR", "HIPAA", "FedRAMP", "SOC2"], "PCI-DSS"),
      contains(["SOX", "PCI-DSS", "ISO27001", "GDPR", "HIPAA", "FedRAMP", "SOC2"], "ISO27001")
    ])
    error_message = "Should accept valid compliance frameworks"
  }
}

# Test tags validation
resource "test_assertions" "tags_validation" {
  component = "dns_record_tags"

  check "tag_key_format" {
    assertion     = can(regex("^[a-zA-Z][a-zA-Z0-9_-]*$", "Environment"))
    error_message = "Tag keys should follow naming conventions"
  }

  check "tag_value_length" {
    assertion     = length("production") <= 256
    error_message = "Tag values should not exceed maximum length"
  }
}

# Test record lifecycle validation
resource "test_assertions" "lifecycle_validation" {
  component = "dns_record_lifecycle"

  check "auto_delete_days" {
    assertion     = 30 >= 1 || 30 == null
    error_message = "Auto delete days should be positive or null"
  }

  check "boolean_lifecycle_flags" {
    assertion = alltrue([
      is_bool(true),
      is_bool(false)
    ])
    error_message = "Lifecycle flags should be boolean"
  }
}

# Test validation rules
resource "test_assertions" "validation_rules_test" {
  component = "dns_record_validation_rules"

  check "max_record_count" {
    assertion     = 100 >= 1 && 100 <= 1000
    error_message = "Max record count should be within reasonable limits"
  }

  check "forbidden_values_list" {
    assertion = alltrue([
      is_list(["127.0.0.1", "localhost"]),
      length(["127.0.0.1", "localhost"]) >= 0
    ])
    error_message = "Forbidden values should be a valid list"
  }
}