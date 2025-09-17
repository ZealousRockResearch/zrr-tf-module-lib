# Azure Infrastructure DNS Record Module

A comprehensive Terraform module for managing Azure DNS records with enterprise-grade features including monitoring, compliance, security controls, and lifecycle management.

## Features

- **Dual Zone Support**: Public and private DNS zones
- **Comprehensive Record Types**: A, AAAA, CNAME, MX, NS, TXT, SRV, CAA
- **Enterprise Governance**: Monitoring, compliance, and security controls
- **Flexible Configuration**: Multiple zone reference patterns
- **Advanced Validation**: Strict format checking and validation rules
- **Lifecycle Management**: Backup, approval workflows, and scheduled updates

## Usage

### Basic Example

```hcl
module "dns_record" {
  source = "github.com/zrr-org/zrr-tf-module-lib//azure/infrastructure/dns-record"

  name        = "www"
  record_type = "A"
  records     = ["203.0.113.1", "203.0.113.2"]
  ttl         = 3600

  dns_zone_name               = "example.com"
  dns_zone_resource_group_name = "dns-rg"

  environment = "prod"
  criticality = "high"

  common_tags = {
    Environment = "prod"
    Project     = "website"
    Owner       = "web-team"
  }
}
```

### Advanced Example with Enterprise Features

```hcl
module "dns_record_enterprise" {
  source = "github.com/zrr-org/zrr-tf-module-lib//azure/infrastructure/dns-record"

  name        = "api"
  record_type = "A"
  records     = ["10.0.1.10", "10.0.1.11"]
  ttl         = 300

  private_dns_zone_name               = "internal.company.local"
  private_dns_zone_resource_group_name = "private-dns-rg"

  environment = "prod"
  criticality = "critical"

  # Enterprise Features
  enable_monitoring    = true
  health_check_enabled = true
  alert_on_changes     = true

  compliance_requirements = ["SOX", "PCI-DSS", "ISO27001"]

  security_config = {
    access_restrictions   = ["10.0.0.0/8", "172.16.0.0/12"]
    change_protection    = true
    audit_logging       = true
    encryption_in_transit = true
  }

  record_lifecycle = {
    auto_delete_after_days    = null
    backup_enabled           = true
    change_approval_required = true
    scheduled_updates        = false
  }

  validation_rules = {
    strict_format_checking = true
    allow_wildcard_records = false
    max_record_count      = 10
    forbidden_values      = ["127.0.0.1", "localhost"]
  }

  common_tags = {
    Environment    = "prod"
    Project        = "enterprise-infrastructure"
    Owner          = "platform-team"
    CostCenter     = "engineering"
    BusinessUnit   = "technology"
    Application    = "core-services"
    DataClass      = "internal"
    Compliance     = "required"
  }

  dns_record_tags = {
    Purpose       = "api-endpoint"
    ServiceTier   = "critical"
    Monitoring    = "enabled"
    Backup        = "daily"
    LoadBalanced  = "true"
    HealthCheck   = "enabled"
  }
}
```

### MX Records Example

```hcl
module "mx_record" {
  source = "github.com/zrr-org/zrr-tf-module-lib//azure/infrastructure/dns-record"

  name        = "mail"
  record_type = "MX"
  records     = []  # Not used for MX records
  ttl         = 3600

  mx_records = [
    {
      preference = 10
      exchange   = "mail1.example.com."
    },
    {
      preference = 20
      exchange   = "mail2.example.com."
    }
  ]

  dns_zone_name               = "example.com"
  dns_zone_resource_group_name = "dns-rg"

  environment = "prod"
  criticality = "high"
}
```

### SRV Records Example

```hcl
module "srv_record" {
  source = "github.com/zrr-org/zrr-tf-module-lib//azure/infrastructure/dns-record"

  name        = "_sip._tcp"
  record_type = "SRV"
  records     = []  # Not used for SRV records
  ttl         = 1800

  srv_records = [
    {
      priority = 10
      weight   = 60
      port     = 5060
      target   = "sip1.example.com."
    },
    {
      priority = 10
      weight   = 40
      port     = 5060
      target   = "sip2.example.com."
    }
  ]

  dns_zone_name               = "example.com"
  dns_zone_resource_group_name = "dns-rg"

  environment = "prod"
  criticality = "medium"
}
```

## DNS Zone Reference Patterns

The module supports multiple ways to reference DNS zones:

### 1. Zone Name and Resource Group (Recommended)
```hcl
dns_zone_name               = "example.com"
dns_zone_resource_group_name = "dns-rg"
```

### 2. Private DNS Zone
```hcl
private_dns_zone_name               = "internal.company.local"
private_dns_zone_resource_group_name = "private-dns-rg"
```

### 3. Zone ID (Direct Reference)
```hcl
dns_zone_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/dns-rg/providers/Microsoft.Network/dnsZones/example.com"
```

## Record Types

| Type  | Description | Example |
|-------|-------------|---------|
| A     | IPv4 address records | `["203.0.113.1", "203.0.113.2"]` |
| AAAA  | IPv6 address records | `["2001:db8::1", "2001:db8::2"]` |
| CNAME | Canonical name records | `["target.example.com."]` |
| MX    | Mail exchange records | See `mx_records` variable |
| NS    | Name server records | `["ns1.example.com.", "ns2.example.com."]` |
| TXT   | Text records | `["v=spf1 include:_spf.google.com ~all"]` |
| SRV   | Service records | See `srv_records` variable |
| CAA   | Certificate authority authorization | `["0 issue \"letsencrypt.org\""]` |

## Enterprise Governance

### Monitoring & Alerting
- Real-time DNS record monitoring
- Health checks with automatic failover
- Performance metrics and SLA tracking
- Custom alerting rules and notifications

### Security & Compliance
- Access restrictions and change protection
- Comprehensive audit logging
- Encryption in transit
- Multi-compliance framework support

### Lifecycle Management
- Change approval workflows
- Automated backup and recovery
- Scheduled maintenance windows
- Record validation and format checking

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_on_changes"></a> [alert\_on\_changes](#input\_alert\_on\_changes) | Enable alerts when DNS records are modified | `bool` | `false` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_compliance_requirements"></a> [compliance\_requirements](#input\_compliance\_requirements) | List of compliance frameworks that apply to this DNS record | `list(string)` | `[]` | no |
| <a name="input_criticality"></a> [criticality](#input\_criticality) | Criticality level of the DNS record | `string` | `"low"` | no |
| <a name="input_dns_record_tags"></a> [dns\_record\_tags](#input\_dns\_record\_tags) | Additional tags specific to the DNS record | `map(string)` | `{}` | no |
| <a name="input_dns_zone_id"></a> [dns\_zone\_id](#input\_dns\_zone\_id) | Full resource ID of the DNS zone (alternative to dns\_zone\_name + dns\_zone\_resource\_group\_name) | `string` | `null` | no |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | Name of the public DNS zone where the record will be created | `string` | `null` | no |
| <a name="input_dns_zone_resource_group_name"></a> [dns\_zone\_resource\_group\_name](#input\_dns\_zone\_resource\_group\_name) | Resource group name where the public DNS zone is located | `string` | `null` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enable monitoring for the DNS record | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment where the DNS record is deployed | `string` | `"dev"` | no |
| <a name="input_health_check_enabled"></a> [health\_check\_enabled](#input\_health\_check\_enabled) | Enable health checks for the DNS record endpoints | `bool` | `false` | no |
| <a name="input_mx_records"></a> [mx\_records](#input\_mx\_records) | MX records configuration (used when record\_type is MX) | <pre>list(object({<br>    preference = number<br>    exchange   = string<br>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the DNS record | `string` | n/a | yes |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Name of the private DNS zone where the record will be created | `string` | `null` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Resource group name where the private DNS zone is located | `string` | `null` | no |
| <a name="input_record_lifecycle"></a> [record\_lifecycle](#input\_record\_lifecycle) | Lifecycle management configuration for the DNS record | <pre>object({<br>    auto_delete_after_days    = number<br>    backup_enabled           = bool<br>    change_approval_required = bool<br>    scheduled_updates        = bool<br>  })</pre> | <pre>{<br>  "auto_delete_after_days": null,<br>  "backup_enabled": false,<br>  "change_approval_required": false,<br>  "scheduled_updates": false<br>}</pre> | no |
| <a name="input_record_type"></a> [record\_type](#input\_record\_type) | Type of DNS record to create | `string` | n/a | yes |
| <a name="input_records"></a> [records](#input\_records) | List of DNS record values | `list(string)` | n/a | yes |
| <a name="input_security_config"></a> [security\_config](#input\_security\_config) | Security configuration for the DNS record | <pre>object({<br>    access_restrictions   = list(string)<br>    change_protection    = bool<br>    audit_logging       = bool<br>    encryption_in_transit = bool<br>  })</pre> | <pre>{<br>  "access_restrictions": [],<br>  "audit_logging": true,<br>  "change_protection": false,<br>  "encryption_in_transit": true<br>}</pre> | no |
| <a name="input_srv_records"></a> [srv\_records](#input\_srv\_records) | SRV records configuration (used when record\_type is SRV) | <pre>list(object({<br>    priority = number<br>    weight   = number<br>    port     = number<br>    target   = string<br>  }))</pre> | `[]` | no |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | Time To Live (TTL) for the DNS record in seconds | `number` | `3600` | no |
| <a name="input_validation_rules"></a> [validation\_rules](#input\_validation\_rules) | Validation rules for the DNS record | <pre>object({<br>    strict_format_checking = bool<br>    allow_wildcard_records = bool<br>    max_record_count      = number<br>    forbidden_values      = list(string)<br>  })</pre> | <pre>{<br>  "allow_wildcard_records": true,<br>  "forbidden_values": [],<br>  "max_record_count": 100,<br>  "strict_format_checking": false<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_compliance_status"></a> [compliance\_status](#output\_compliance\_status) | Compliance status and requirements for the DNS record |
| <a name="output_dns_zone_type"></a> [dns\_zone\_type](#output\_dns\_zone\_type) | Type of DNS zone (public or private) |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | Fully qualified domain name of the DNS record |
| <a name="output_health_check_status"></a> [health\_check\_status](#output\_health\_check\_status) | Health check status and configuration |
| <a name="output_id"></a> [id](#output\_id) | ID of the DNS record |
| <a name="output_lifecycle_config"></a> [lifecycle\_config](#output\_lifecycle\_config) | Lifecycle configuration of the DNS record |
| <a name="output_monitoring_config"></a> [monitoring\_config](#output\_monitoring\_config) | Monitoring configuration and status |
| <a name="output_name"></a> [name](#output\_name) | Name of the DNS record |
| <a name="output_network_info"></a> [network\_info](#output\_network\_info) | Network and connectivity information |
| <a name="output_record_management"></a> [record\_management](#output\_record\_management) | Record management information including creation and modification details |
| <a name="output_record_type"></a> [record\_type](#output\_record\_type) | Type of the DNS record |
| <a name="output_security_posture"></a> [security\_posture](#output\_security\_posture) | Security configuration and posture |
| <a name="output_ttl"></a> [ttl](#output\_ttl) | TTL of the DNS record |
| <a name="output_validation_status"></a> [validation\_status](#output\_validation\_status) | Validation status and rules applied to the DNS record |

## Examples

See the [examples](./examples) directory for complete usage examples:

- [Basic Example](./examples/basic) - Simple DNS record creation
- [Advanced Example](./examples/advanced) - Enterprise features with monitoring and compliance

## Testing

The module includes comprehensive testing:

### Unit Tests
```bash
cd tests/unit
terraform test
```

### Integration Tests
```bash
cd tests/integration
go test -v
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_dns_a_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) | resource |
| [azurerm_dns_aaaa_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_aaaa_record) | resource |
| [azurerm_dns_caa_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_caa_record) | resource |
| [azurerm_dns_cname_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_cname_record) | resource |
| [azurerm_dns_mx_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_mx_record) | resource |
| [azurerm_dns_ns_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_ns_record) | resource |
| [azurerm_dns_srv_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_srv_record) | resource |
| [azurerm_dns_txt_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_txt_record) | resource |
| [azurerm_private_dns_a_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_aaaa_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_aaaa_record) | resource |
| [azurerm_private_dns_cname_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_cname_record) | resource |
| [azurerm_private_dns_mx_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_mx_record) | resource |
| [azurerm_private_dns_srv_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_srv_record) | resource |
| [azurerm_private_dns_txt_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_txt_record) | resource |
| [null_resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) for full details.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Support

For questions and support:

- Create an issue in this repository
- Contact the Platform Engineering team
- Refer to the [ZRR Terraform Module Library Documentation](../../README.md)